//
//  BannerView.swift
//  MyFirstGPUImage
//
//  Created by LiuYong on 2018/9/14.
//  Copyright © 2018年 LiuYong. All rights reserved.
//

import UIKit
import Photos

protocol BannerViewDelegate : class {
    func bannerViewDidSelectedItemAtIndex(_ image:UIImage)
    func hideNavi()
}

fileprivate var id = "bannerCell"

class BannerView: UIView {

    
    
    //取得的资源结果，用了存放的PHAsset
    var assetsFetchResults:PHFetchResult<PHAsset>?
    ///缩略图大小
    var assetGridThumbnailSize:CGSize!
    /// 带缓存的图片管理对象
    var imageManager:PHCachingImageManager!
    var lastX:CGFloat!
    var currentImage:PHAsset?
    var currentIndex = 0
    

    weak var delegate:BannerViewDelegate?
    var index:IndexPath!
    
    
    //MARK: lazy loading
    lazy var collectionView:UICollectionView = {
       let layout = BannerFlowLayout()
    
        //初始化Collectionview
        let collection = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collection.backgroundColor = UIColor.white
        collection.bounces = false
        collection.isPagingEnabled = true
        collection.dataSource = self
        collection.delegate = self
        collection.register(BannerCollectionViewCell.self, forCellWithReuseIdentifier: id)
        collection.showsHorizontalScrollIndicator = false
        
        //为collectionView添加点击手势
        let tap = UITapGestureRecognizer(target: self, action: #selector(touchAndHidden))
        collection.addGestureRecognizer(tap)
        
        
        return collection
    }()
    //确认选择按钮
    lazy var confirmButton:UIButton = {
        let btn = UIButton()
        //btn.setImage(#imageLiteral(resourceName: "确认 "), for: .normal)
        btn.backgroundColor = naviColor
        btn.setTitleColor(UIColor.white, for: .normal)
        btn.setTitle("选择照片", for: .normal)
        btn.addTarget(self, action: #selector(touchConfirm), for: .touchUpInside)
        return btn
    }()
    //删除按钮
    lazy var deleteButton:UIButton = {
        let btn = UIButton()
        btn.setImage(#imageLiteral(resourceName: "删除"), for: .normal)
        btn.backgroundColor = naviColor
        btn.setTitleColor(UIColor.white, for: .normal)
        btn.addTarget(self, action: #selector(touchDelete), for: .touchUpInside)
        btn.imageEdgeInsets = UIEdgeInsets(top: 10, left: 31, bottom: 10, right: 31)
        return btn
    }()
    
    //按钮背景view
    lazy var bgBottomView:UIView = {
        let v = UIView()
        return  v
    }()

    
    init(index:IndexPath) {
        super.init(frame: CGRect.zero)
        self.index = index
        currentIndex = index.item
        print("当前index",currentIndex)
        dealWithImageAsset()
        setUI()
    
    }
    

    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        //collectionView.contentOffset.x = CGFloat((index?.item)!)*SCREEN_WIDTH
        collectionView.scrollToItem(at: index!, at: .right, animated: false)
        lastX = collectionView.contentOffset.x

       // print(index?.item,collectionView.contentOffset.x)

    }
    
  
    
    
}

// MARK: - 逻辑处理
extension BannerView{
    func setUI(){
        
        let bglabel = UIView()//分割线

        addSubview(collectionView)
        addSubview(bgBottomView)
        //self.isUserInteractionEnabled = false
   

        bglabel.backgroundColor = UIColor.white
    
        collectionView.snp.makeConstraints({
            make in
            make.left.top.right.bottom.equalToSuperview()
            make.height.equalToSuperview()
        })
       //let z =  collectionView.collectionViewLayout
        
   
        
        bgBottomView.snp.makeConstraints({
            make in
            make.bottom.equalToSuperview()
            make.width.equalTo(SCREEN_WIDTH)
            make.height.equalTo(50)
            make.right.equalToSuperview()
        })
        
        bgBottomView.addSubview(confirmButton)
        bgBottomView.addSubview(deleteButton)
        bgBottomView.addSubview(bglabel)
        
        
        confirmButton.snp.makeConstraints({
            make in
            make.bottom.equalToSuperview()
            make.width.equalTo(SCREEN_WIDTH*3/4)
            make.height.equalTo(50)
            make.right.equalToSuperview()
        })
        
        deleteButton.snp.makeConstraints({
            make in
            make.bottom.equalToSuperview()
            make.height.equalTo(50)
            make.width.equalTo(SCREEN_WIDTH/4)
            make.left.equalToSuperview()
        })
        bglabel.snp.makeConstraints({
            make in
            make.centerY.equalTo(deleteButton.snp.centerY)
            make.width.equalTo(1)
            make.left.equalTo(deleteButton.snp.right).offset(1)
            make.height.equalTo(30)
        })

    }
    
    
    func dealWithImageAsset(){
        // 如果没有传入值 则获取所有资源
        //if assetsFetchResults == nil {
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
           // print(self.assetsFetchResults?.count)

        //}
        
        // 初始化和重置缓存
        self.imageManager = PHCachingImageManager()
        imageManager.stopCachingImagesForAllAssets()

        //根据单元格的尺寸计算我们需要的缩略图大小

        assetGridThumbnailSize = CGSize(width: 768, height: 1024)//
    }
    
    
    /// 点击手势，收起选择栏和导航栏
    @objc func touchAndHidden(){
           self.bgBottomView.isHidden = !bgBottomView.isHidden
           delegate?.hideNavi()
    }
    
    @objc func touchConfirm(){
        imageManager.stopCachingImagesForAllAssets()
        imageManager.requestImageData(for: currentImage ?? assetsFetchResults![index!.item], options: nil, resultHandler: {
            (data,_,_,path)  in
            if let image = UIImage(data: data!){
                //删除图片操作
                if let url = path!["PHImageFileURLKey"] as? URL{
                    let uu = url
                    print(uu)
                    //向library申请变更
                    PHPhotoLibrary.shared().performChanges({
                        //获取图片Asset
                        
                        let imageAssetToDelete = PHAsset.fetchAssets(withALAssetURLs: [uu], options: nil)
                        PHAssetChangeRequest.deleteAssets(imageAssetToDelete)
                        //完成闭包
                    }, completionHandler: {
                        success,error in
                        print(error as Any,success)
                    })
                    
                }
                
                 self.delegate?.bannerViewDidSelectedItemAtIndex(image)
            }
            
        })
    }
    
    
    /// 删除图片
    @objc func touchDelete(){
        //申请修改
        PHPhotoLibrary.shared().performChanges({
            //获取相册的照片
            let imaged = [self.assetsFetchResults![self.currentIndex]]
            PHAssetChangeRequest.deleteAssets(imaged as NSFastEnumeration)
        }, completionHandler: { success, error in
            //删除对应Item
            if (self.assetsFetchResults?.count)! > 1{
                //删除后重新获取asset，刷新视图
                self.dealWithImageAsset()
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                    //发送刷新相册数据源通知
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "albumRefresh"), object: self, userInfo: ["go":"refresh"])
                }
            }
        }
        )
    }
    
    
    
}


// MARK: - CollectionDelegate
extension BannerView:UICollectionViewDelegate,UICollectionViewDataSource{
 
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assetsFetchResults?.count  ?? 0
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell : BannerCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: id, for: indexPath) as! BannerCollectionViewCell
        
    
        guard let asset = self.assetsFetchResults?[indexPath.row] else{
            return cell
        }
        //获取缩略图
        self.imageManager.requestImage(for: asset, targetSize: assetGridThumbnailSize,
                                       contentMode: PHImageContentMode.aspectFill,
                                       options: nil) { (image, nfo) in
                                        cell.image = image
                                        //print(image)
        }
        return cell
    }
    
    
    
    
    /// 滑动时，记录当前图片
    ///
    /// - Parameter scrollView: 滑动结束监听
//    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {

        print("scorll_end")
       
        //下一个
        print("现在位置：",scrollView.contentOffset.x,"上次位置：",lastX,scrollView.contentOffset.x/SCREEN_WIDTH)
        //重新计算Index
        currentIndex = Int(scrollView.contentOffset.x/SCREEN_WIDTH)
        if currentIndex >= (assetsFetchResults?.count)!{
            return
        }
        guard let cu = assetsFetchResults?[currentIndex] else{
            return
        }
        currentImage = cu
        
        print("现在的index：",currentIndex,"数组长度：",assetsFetchResults?.count ?? 0)

   

        
    }
    
  
    
    
    
}
