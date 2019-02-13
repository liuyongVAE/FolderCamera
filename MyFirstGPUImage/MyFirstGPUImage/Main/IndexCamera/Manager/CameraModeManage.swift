//
//  cameraTypeManage.swift
//  MyFirstGPUImage
//
//  Created by 刘勇 on 2019/2/13.
//  Copyright © 2019 LiuYong. All rights reserved.
//

import Foundation



enum CameraMode:Int {
    case CameraModeMovie = 0 ,
    CameraModePeople,
    CameraModeScenery,
    CameraModeFood,
    CameraModeFilm,
    CameraModeCount
}

class CameraModeManage {
    

    static let shared:CameraModeManage = {
        return CameraModeManage.init()
    }()
    
    var currentMode:CameraMode {
        didSet{
            self.cameraModeDidChanged()
        }
    }
    var currentBackImageView:UIImageView = {
        let z = UIImageView.init()
        z.image = UIImage(named: "faceModeBackground");
        return z
    }()
    
    
    private init(){

        self.currentMode = CameraMode.CameraModeMovie
    }
    
    private func cameraModeDidChanged(){
        
        var backImage = UIImage()
        switch currentMode {
        case .CameraModeMovie:
            backImage = UIImage(named: "movieModeBack")!;
        case .CameraModePeople:
            backImage = UIImage(named: "faceModeBackground")!;
        case .CameraModeScenery:
            backImage = UIImage(named: "landscapeModeBack")!;
        case .CameraModeFood:
            backImage = UIImage(named: "foodModeback")!;
        case .CameraModeFilm:
            backImage = UIImage(named: "filmModeBack")!;
        default:
            break;
        }
        
        self.currentBackImageView.image = backImage;
        
        let notify = Notification.Name.init("CameraModeDidChanged")
        NotificationCenter.default.post(name: notify, object: self)
        
    
    }
    
    
    
}

