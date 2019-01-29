//
//  AlbumDataSource.swift
//  MyFirstGPUImage
//
//  Created by LiuYong on 2018/9/18.
//  Copyright © 2018年 LiuYong. All rights reserved.
//

import Foundation
import Photos

class AlbumDataSource:NSObject,UICollectionViewDataSource{
    
    //取得的资源结果，用了存放的PHAsset
    var assetsFetchResults:PHFetchResult<PHAsset>!
    var imageManager:PHCachingImageManager!
    var assetGridThumbnailSize:CGSize!


    var count:Int!
    //单例
    static var shared:AlbumDataSource = {
      let ass = AlbumDataSource()
      return ass
    }()
    
    
    private override init(){
        super.init()
        getAsst()
    }
    
    fileprivate func getAsst(){
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
        count = assetsFetchResults.count
        // 初始化和重置缓存
        self.imageManager = PHCachingImageManager()
        imageManager.stopCachingImagesForAllAssets()
        
        //根据单元格的尺寸计算我们需要的缩略图大小
        
       // assetGridThumbnailSize = CGSize(width: 768, height: 1024)//
    }

    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assetsFetchResults?.count  ?? 0
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell : ItemCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "itemCell", for: indexPath) as! ItemCollectionViewCell
        
        
        guard let asset = self.assetsFetchResults?[indexPath.row] else{
            return cell
        }
        //根据单元格的尺寸计算我们需要的缩略图大小
        let scale = UIScreen.main.scale
        let cellSize = (collectionView.collectionViewLayout as! UICollectionViewFlowLayout).itemSize
        assetGridThumbnailSize = CGSize(width:cellSize.width*scale ,
                                        height:cellSize.height*scale)
        //获取缩略图
        self.imageManager.requestImage(for: asset, targetSize: assetGridThumbnailSize,
                                       contentMode: PHImageContentMode.aspectFill,
                                       options: nil) { (image, nfo) in
                                        cell.imageView.image = image
        }
        return cell
    }
    
    
    

}

