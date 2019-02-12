//
//  CameraEnum.swift
//  MyFirstGPUImage
//
//  Created by 刘勇 on 2019/2/12.
//  Copyright © 2019 LiuYong. All rights reserved.
//

import Foundation



enum CameraScale:Int {
    case CameraScale43 = 0 ,CameraScale11, CameraScale169
}

struct CameraScaleRect{
    var scaleRate:CameraScale {
        didSet {
            switch scaleRate {
            case .CameraScale43:
                self.cropRect = CGRect(x: 0, y: topHegiht/SCREEN_HEIGHT, width: 1, height: 3/4)
                self.previewRect = CGRect(x: 0, y: topHegiht, width: SCREEN_WIDTH, height: (3*SCREEN_HEIGHT )/4)
            case .CameraScale11:
                self.topHegiht = (SCREEN_HEIGHT-SCREEN_WIDTH)/2
                self.cropRect = CGRect(x: 0, y: topHegiht/SCREEN_HEIGHT, width: 1, height: SCREEN_WIDTH/SCREEN_HEIGHT)
                 self.previewRect = CGRect(x: 0, y: topHegiht, width: SCREEN_WIDTH, height: SCREEN_HEIGHT)
            default:
                break;
            }
        }
    }
    var cropRect:CGRect!
    var previewRect:CGRect!
    var topHegiht:CGFloat = 95
    var bottomHeight:CGFloat = (1/4)*SCREEN_HEIGHT - 95

    
    init(scaleRate:CameraScale, cropRect: CGRect?,previewRect:CGRect?) {
        self.scaleRate = scaleRate;
        if let zz =  cropRect {
            self.cropRect = zz
        }
        if let ss =  previewRect {
            self.previewRect = ss
        } 
        
    }
    
    
}
