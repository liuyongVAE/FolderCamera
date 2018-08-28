//
//  FaceArea.swift
//  MyFirstGPUImage
//
//  Created by LiuYong on 2018/8/23.
//  Copyright © 2018年 LiuYong. All rights reserved.
//

import Foundation
import UIKit
import CoreImage

//脸部数据Area
struct FaceArea{
    let trackingID:Int32
    var bounds:CGRect
    
    init(faceFeature: CIFaceFeature, applyingRatio ratio: CGFloat,ifFront:Bool) {
        let bound = CGRect(
            x: faceFeature.bounds.origin.y * ratio,
            y: faceFeature.bounds.origin.x * ratio,
            width: faceFeature.bounds.size.height * ratio,
            height: faceFeature.bounds.size.width * ratio
        )
        self.trackingID = faceFeature.trackingID
        self.bounds = bound
        //判断是否是前置
        if ifFront{
           let bound = CGRect(
                x: (SCREEN_WIDTH/2 -  faceFeature.bounds.origin.y * ratio),
                y: faceFeature.bounds.origin.x * ratio,
                width: faceFeature.bounds.size.height * ratio,
                height: faceFeature.bounds.size.width * ratio
            )
            self.bounds = bound
        }
   
 
    }
    
    
    
}
