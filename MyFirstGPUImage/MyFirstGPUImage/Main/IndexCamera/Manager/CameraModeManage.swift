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
        let this = UIImageView.init()
        return this
    }()
    
    var currentCameraFrame:UIImageView = {
        let imageview = UIImageView.init()
        imageview.isHidden = true;
        imageview.contentMode = .scaleToFill
        return imageview
    }()
    
    
    var currentFilterButton:UIButton = {
        let button = UIButton()
        return button;
    }()
    
    private init(){

        self.currentMode = CameraMode.CameraModePeople
    }
    
    private func cameraModeDidChanged(){
        
        var backImage = UIImage()
        var filterImage = UIImage()

        var frameImage:UIImage?
        switch currentMode {
        case .CameraModeMovie:
            backImage = UIImage(named: "movieModeBack")!;
            filterImage = UIImage(named: "滤镜movie")!;
            frameImage = UIImage(named: "movieFrame")!;
        case .CameraModePeople:
            backImage = UIImage(named: "faceModeBackground")!;
            filterImage = UIImage(named: "滤镜")!;
        case .CameraModeScenery:
            backImage = UIImage(named: "landscapeModeBack")!;
            filterImage = UIImage(named: "滤镜landscape")!;
        case .CameraModeFood:
            backImage = UIImage(named: "foodModeback")!
            filterImage = UIImage(named: "滤镜food")!;
        case .CameraModeFilm:
            backImage = UIImage(named: "filmModeBack")!;
            filterImage = UIImage(named: "滤镜film")!;
            frameImage = UIImage(named: "filmFrame")!;
        default:
            break;
        }
        
        self.currentBackImageView.image = backImage;
        self.currentFilterButton.setImage(filterImage, for: .normal);
        if let currentFrame = frameImage {
            self.currentCameraFrame.image = currentFrame;
            currentCameraFrame.isHidden = false;
        } else {
            currentCameraFrame.isHidden = true;
        }
            
        let notify = Notification.Name.init("CameraModeDidChanged")
        NotificationCenter.default.post(name: notify, object: self)
        
    
    }
    
    
    
}

