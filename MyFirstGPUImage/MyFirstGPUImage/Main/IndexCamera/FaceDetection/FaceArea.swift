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
    let bounds:CGRect
    
    init(faceFeature: CIFaceFeature, applyingRatio ratio: CGFloat) {
        let bound = CGRect(
            x: faceFeature.bounds.origin.y * ratio,
            y: faceFeature.bounds.origin.x * ratio,
            width: faceFeature.bounds.size.height * ratio,
            height: faceFeature.bounds.size.width * ratio
        )
        
        self.trackingID = faceFeature.trackingID
        self.bounds = bound
    }
    
    
    
}
