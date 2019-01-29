//
//  AlbumItem.swift
//  MyFirstGPUImage
//
//  Created by LiuYong on 2018/9/12.
//  Copyright © 2018年 LiuYong. All rights reserved.
//

import Foundation
import Photos

//相簿列表项
class AlbumItem {
    //相簿名称
    var title:String?
    //相簿内的资源
    var fetchResult:PHFetchResult<PHAsset>
    var coverImage:UIImage?
    init(title:String?,fetchResult:PHFetchResult<PHAsset>){
        self.title = title
        self.fetchResult = fetchResult
        PHImageManager().requestImage(for: fetchResult[0], targetSize: CGSize(width: 64, height: 64), contentMode: .aspectFill, options: nil, resultHandler: {(image, nfo) in
            self.coverImage = image
        })
    }
}
