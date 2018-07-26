//
//  FConViewController.swift
//  MyFirstGPUImage
//
//  Created by LiuYong on 2018/7/25.
//  Copyright © 2018年 LiuYong. All rights reserved.
//

import UIKit
import Photos
import GPUImage


class FConViewController: UIViewController {
    
    var mCamera:GPUImageStillCamera!
    var mFillter:GPUImageFilter!
    var mGpuimageView:GPUImageView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        mCamera = GPUImageStillCamera(sessionPreset:AVCaptureSession.Preset.vga640x480.rawValue , cameraPosition: AVCaptureDevice.Position.back)
        
        mCamera.outputImageOrientation = UIInterfaceOrientation.portrait
        
        //滤镜
        mFillter = GPUImageSingleComponentGaussianBlurFilter()
        
        mGpuimageView = GPUImageView(frame:view.bounds)
        
        mCamera.addTarget(mFillter)
        mFillter.addTarget(mGpuimageView)
        view.addSubview(mGpuimageView)
        mCamera.startCapture()
        
        var btn = UIButton(frame: CGRect(x: (view.bounds.size.width - 80) * 0.5, y: view.bounds.size.height - 60, width: 80, height: 40))
        btn.backgroundColor = UIColor.red
        btn.setTitle("拍照", for: .normal)
        view.addSubview(btn)
        btn.addTarget(self, action: #selector(self.takePhoto), for: .touchUpInside)
    
        // Do any additional setup after loading the view.
    }

    
    @objc func  takePhoto(){
        mCamera.capturePhotoAsJPEGProcessedUp(toFilter: mFillter, withCompletionHandler: {
            processedJPEG, error in
            
            
            
            if let aJPEG = processedJPEG {
                let imageview = UIImage(data: aJPEG)
                UIImageWriteToSavedPhotosAlbum(imageview!, nil, nil, nil)
                
            }
            
 
            
            
        })
        
        
        
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
