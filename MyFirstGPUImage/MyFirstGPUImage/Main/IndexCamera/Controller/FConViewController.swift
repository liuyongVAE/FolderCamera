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
    
    //UI
    lazy var shotButton:UIButton = {
        let widthofme = getWidth(210)
        var btn = UIButton(frame: CGRect(x: SCREEN_WIDTH/2 - widthofme/2 , y: getHeight(1543), width: widthofme, height: widthofme))
        btn.layer.cornerRadius = widthofme/2
        btn.setImage(#imageLiteral(resourceName: "圆圈") , for: .normal)
        btn.addTarget(self, action: #selector(self.takePhoto), for: .touchUpInside)
        return btn
    }()
    
    lazy var defaultBottomView:UIView = {
        let v = DefaultBotomView()
        v.delegate = self
        
        return v
    }()
    
    lazy var cameraFillterView:FillterSelectView = {
        let v = FillterSelectView(frame: FloatRect(0, SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT/4))
        v.backgroundColor = UIColor.white

        v.filterDelegate = self
        return v
    }()
    
    lazy var turnCameraButton:UIButton = {
         let widthofme = getWidth(100)
        var btn = UIButton(frame: CGRect(x: SCREEN_WIDTH - widthofme*2 , y: getHeight(35), width: widthofme, height: widthofme))
        btn.layer.cornerRadius = widthofme/2
        btn.setImage(#imageLiteral(resourceName: "转换"), for: .normal)
        btn.addTarget(self, action: #selector(self.turnCamera(_:)), for: .touchUpInside)
        return btn
    }()
    
    
    //属性
    var mCamera:GPUImageStillCamera!
    var mFillter:GPUImageFilter!
    var mGpuimageView:GPUImageView!
    var beginScale:CGFloat!
    var endScale:CGFloat?

    
   

    override func viewDidLoad() {
        super.viewDidLoad()
    
       setCamera()
       setDefaultView()
    
        // Do any additional setup after loading sthe view.
    }

    
    @objc func  takePhoto(){
        mCamera.capturePhotoAsJPEGProcessedUp(toFilter: mFillter, withCompletionHandler: {
            processedJPEG, error in
            
            if let aJPEG = processedJPEG {
                guard let imageview = UIImage(data: aJPEG) else{  return }
            
                self.present(CheckViewController(image: imageview), animated: false, completion: nil)
                
            }
            
        })
        
        
    }
    
    
    //保存图片
    
    func saveImage(){
  
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


//MARK: - UI工厂方法
extension FConViewController{
    //初始化View布局
    func setDefaultView(){
        view.addSubview(defaultBottomView)
        view.addSubview(shotButton)
        view.addSubview(turnCameraButton)
        
    }
    
    //初始化相机和默认滤镜
    
    func setCamera(){
        mCamera = GPUImageStillCamera(sessionPreset:AVCaptureSession.Preset.vga640x480.rawValue , cameraPosition: AVCaptureDevice.Position.front)
        mCamera.outputImageOrientation = UIInterfaceOrientation.portrait
        mCamera.horizontallyMirrorFrontFacingCamera = true
        //滤镜
        mFillter = GPUImageFilter()
        
        mGpuimageView = GPUImageView(frame: FloatRect(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT*3/4))
        
        mCamera.addTarget(mFillter)
        mFillter.addTarget(mGpuimageView)
        mCamera.startCapture()
        view.addSubview(mGpuimageView)
    }
    
    func resetCamera(){
        mCamera.outputImageOrientation = UIInterfaceOrientation.portrait
        mCamera.horizontallyMirrorFrontFacingCamera = true
        mCamera.addTarget(mFillter)
        mFillter.addTarget(mGpuimageView)
        mCamera.startCapture()
    }
    
    
    
    func addFillter(){
        
        var  fArray = [UIImage]()
        for _ in 0...7{
            let v = #imageLiteral(resourceName: "FilterBeauty")
            fArray.append(v)
        }
        cameraFillterView.picArray = fArray
        view.addSubview(cameraFillterView)
    }
    
   @objc func turnCamera(_ btn:UIButton){
        btn.isSelected = !btn.isSelected
        if btn.isSelected{
           mCamera = GPUImageStillCamera(sessionPreset:AVCaptureSession.Preset.vga640x480.rawValue , cameraPosition: AVCaptureDevice.Position.back)
           resetCamera()
        }else{
            mCamera = GPUImageStillCamera(sessionPreset:AVCaptureSession.Preset.vga640x480.rawValue , cameraPosition: AVCaptureDevice.Position.front)
            resetCamera()
            
        }
    

        
    }
    
    
    
    
}


//MARK: - 协议实现

extension FConViewController:FillterSelectViewDelegate,DefaultBottomViewDelegate{
    
    
    //MARK: - 切换滤镜的方法
    
    func switchFillter(index: Int) {
        mCamera.removeAllTargets()
        
        switch index {
        case 0:
            mFillter = GPUImageFilter()
        case 1:
            mFillter = GPUImageSingleComponentGaussianBlurFilter()
        case 2:
            mFillter = GPUImageErosionFilter()
        case 3:
            mFillter = GPUImageZoomBlurFilter()
        case 4:
            mFillter = GPUImageHueFilter()
        case 5:
            mFillter = GPUImageColorInvertFilter()
        case 6:
            mFillter = GPUImageSepiaFilter()////老照片
        case 7:
            mFillter = GPUImageToonFilter()////卡通效果
        default:
            mFillter = GPUImageFilter()

        }
        mCamera.addTarget(mFillter)
        mFillter.addTarget(mGpuimageView)
        mCamera.startCapture()
       
    }
    
    func changeFillter() {
        
        addFillter()
        view.bringSubview(toFront: shotButton)
        UIView.animate(withDuration: 0.2, animations: {
            self.cameraFillterView.center.y = SCREEN_HEIGHT*7/8
            self.shotButton.center.y =  self.shotButton.center.y*16/15
            
        })
        cameraFillterView.mb = {
             self.shotButton.center.y =  SCREEN_HEIGHT*7/8
        }
        
        
    }
    
    func beauty(_ btn:UIButton) {
        
        
        if btn.isSelected{
            print("美颜")
            mCamera.removeAllTargets()
            //亮度(GPUImageBrightnessFilter)和双边滤波(GPUImageBilateralFilter)这两个滤镜达到美颜效果
            let filterGroup = GPUImageFilterGroup()//创建滤镜组
            let bilateralFilter = GPUImageBilateralFilter()//磨皮
            let brightFilter = GPUImageBrightnessFilter()//美白

            //添加滤镜组链
            filterGroup.addTarget(bilateralFilter)
            filterGroup.addTarget(brightFilter)
            bilateralFilter.addTarget(brightFilter)
            filterGroup.initialFilters = [bilateralFilter]
            filterGroup.terminalFilter = brightFilter
        
            mCamera.addTarget(filterGroup)
            filterGroup.addTarget(mGpuimageView)
            mCamera.startCapture()
        }else{
            mCamera.removeAllTargets()
            resetCamera()
            
        }
    }
    
    
    
}
