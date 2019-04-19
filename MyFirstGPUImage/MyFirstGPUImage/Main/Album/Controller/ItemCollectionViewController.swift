//
//  ItemCollectionViewController.swift
//  MyFirstGPUImage
//
//  Created by LiuYong on 2018/9/12.
//  Copyright © 2018年 LiuYong. All rights reserved.
//

import UIKit
import Photos
private let reuseIdentifier = "itemCell"

class ItemCollectionViewController: UICollectionViewController {
    //取得的资源结果，用了存放的PHAsset
    var assetsFetchResults:PHFetchResult<PHAsset>!
    ///缩略图大小
    var assetGridThumbnailSize:CGSize!
    /// 带缓存的图片管理对象
    var imageManager:PHCachingImageManager!
    //图片数组
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("实际上的大小",assetsFetchResults.count)
        
        
        // 初始化和重置缓存
        self.imageManager = PHCachingImageManager()
        self.resetCachedAssets()
        //根据单元格的尺寸计算我们需要的缩略图大小
        let scale = UIScreen.main.scale
        let cellSize = (self.collectionViewLayout as! UICollectionViewFlowLayout).itemSize
        assetGridThumbnailSize = CGSize(width:cellSize.width*scale ,
                                        height:cellSize.height*scale)
        
        
        
        registerNotifi()//注册通知
        // Register cell classes
        self.collectionView!.register(UINib(nibName: "ItemCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)//注册cell
        //self.collectionView?.dataSource = AlbumDataSource.shared

        self.collectionView?.backgroundColor = UIColor.white
  
    }
    
    override func viewDidAppear(_ animated: Bool) {

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Basic Func
    
    //重置缓存
    func resetCachedAssets(){
        self.imageManager.stopCachingImagesForAllAssets()
    }
    
    
    
    func getAssets(){
        //则获取所有资源
        let allPhotosOptions = PHFetchOptions()
        //按照创建时间倒序排列
        allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate",
                                                             ascending: false)]
        //只获取图片
        allPhotosOptions.predicate = NSPredicate(format: "mediaType = %d",
                                                 PHAssetMediaType.image.rawValue)
        assetsFetchResults = PHAsset.fetchAssets(with: PHAssetMediaType.image,
                                                 options: allPhotosOptions)
        
        // Do any additional setup after loading the view.
    }
    
    
    /// 注册相册刷新通知
    func registerNotifi(){
        NotificationCenter.default.addObserver(self, selector: #selector(albumRefresh), name: NSNotification.Name(rawValue:"albumRefresh"), object: nil)

    }
    
    /// 相册刷新
    @objc func albumRefresh(nofi : Notification){
        let str = nofi.userInfo!["go"]
        print(String(describing: str!) + "this notifi")
        getAssets()
        self.collectionView?.reloadData()
    }

    
    /// 移除通知
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    
    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return self.assetsFetchResults.count
    }


    // 获取单元格
    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //print(indexPath.section,indexPath.row)
        // 获取设计的单元格，不需要再动态添加界面元素
        let cell = (self.collectionView?.dequeueReusableCell(
            withReuseIdentifier: reuseIdentifier, for: indexPath))! as! ItemCollectionViewCell
        let asset = self.assetsFetchResults[indexPath.row]
        //获取缩略图
        self.imageManager.requestImage(for: asset, targetSize: assetGridThumbnailSize,
                                       contentMode: PHImageContentMode.aspectFill,
                                       options: nil) { (image, nfo) in
                                        cell.imageView.image = image
                                        //print(image)
        }
        return cell
    }
    
    // 单元格点击响应
    override func collectionView(_ collectionView: UICollectionView,
                                 didSelectItemAt indexPath: IndexPath) {
        //let myAsset = self.assetsFetchResults[indexPath.row]
        let vc = ImageDetailViewController()
        vc.assetsFetchResults = assetsFetchResults
        vc.indexPath = indexPath
        self.navigationController?.pushViewController(vc, animated: true)
        
        
        
    }

}
