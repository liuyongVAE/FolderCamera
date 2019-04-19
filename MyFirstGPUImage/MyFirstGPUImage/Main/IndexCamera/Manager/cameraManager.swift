//
//  cameraManager.swift
//  MyFirstGPUImage
//
//  Created by 刘勇 on 2019/2/12.
//  Copyright © 2019 LiuYong. All rights reserved.
//

import Foundation


//相机的垃圾桶
class cameraManager {
    
    /// 检查相机权限

    class func checkAlbumAndCameraAuthority() {
        
        let authStatus = AVCaptureDevice.authorizationStatus(for: .video)
        if authStatus == .notDetermined{
            AVCaptureDevice.requestAccess(for: .video, completionHandler: ({
                status in
                if status{
                    print("同意")
                }else{
                    print("不同意")
                }
            }))
        }else if (authStatus == .authorized ){
            return
        }else{
            let alertController = UIAlertController(title: "提示", message: "您已经关闭相机权限，该功能无法使用，请点击系统设置设置", preferredStyle: .alert)
            
            let alertAction1 = UIAlertAction(title: "取消", style: .default, handler: nil)
            let alertAction2 = UIAlertAction(title: "系统设置", style: .default, handler: { (action) in
                let url = URL(string: UIApplicationOpenSettingsURLString)
                if(UIApplication.shared.canOpenURL(url!)) {
                    UIApplication.shared.openURL(url!)
                }
            })
            alertController.addAction(alertAction1)
            alertController.addAction(alertAction2)
            RoutingService.presentVC(vc: alertController)
        }
        
        
        
    }

    
    
    
}
