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
                self.previewRect = CGRect(x: 0, y: topHegiht, width: SCREEN_WIDTH, height: (4*SCREEN_WIDTH)/3)
            case .CameraScale11:
                self.topHegiht = (SCREEN_HEIGHT-SCREEN_WIDTH)/2
                self.cropRect = CGRect(x: 0, y: topHegiht/SCREEN_HEIGHT, width: 1, height: SCREEN_WIDTH/SCREEN_HEIGHT)
                 self.previewRect = CGRect(x: 0, y: topHegiht, width: SCREEN_WIDTH, height: SCREEN_WIDTH)
            default:
                break;
            }
        }
    }
    var cropRect:CGRect!
    var previewRect:CGRect!
    var topHegiht:CGFloat = {
        return 47 + topFix*2;
    }()
    //(95/1334)*SCREEN_HEIGHT + topFix
    
    var bottomHeight:CGFloat = {
        let z =  47 + topFix*2
        //iF Ipad
        if (SCREEN_HEIGHT - (4*SCREEN_WIDTH)/3 - z) < 0 {
            return SCREEN_HEIGHT - SCREEN_WIDTH
        }
        
        return SCREEN_HEIGHT - (4*SCREEN_WIDTH)/3 - z;
    }()
        //SCREEN_HEIGHT - (4*SCREEN_WIDTH)/3 - (95/1334)*SCREEN_HEIGHT - topFix

    
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
