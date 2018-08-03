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
//  拍照按钮
    lazy var shotButton:UIButton = {
        let widthofme:CGFloat = 75
        var btn = UIButton()
        btn.layer.cornerRadius = widthofme/2
        btn.setImage(#imageLiteral(resourceName: "圆圈") , for: .normal)
        btn.addTarget(self, action: #selector(self.takePhoto), for: .touchUpInside)
        return btn
    }()
//  底部白色VIEW
    lazy var defaultBottomView:UIView = {
        let v = DefaultBotomView()
        v.delegate = self
        return v
    }()
//    选择滤镜view
    lazy var cameraFillterView:FillterSelectView = {
        let v = FillterSelectView()
        v.backgroundColor = UIColor.white
    
        v.filterDelegate = self
        return v
    }()
//  转换摄像头
    lazy var turnCameraButton:UIButton = {
        let widthofme:CGFloat = 50
        var btn = UIButton()
        btn.layer.cornerRadius = widthofme/2
        btn.setImage(#imageLiteral(resourceName: "转换"), for: .normal)
        btn.addTarget(self, action: #selector(self.turnCamera(_:)), for: .touchUpInside)
        return btn
    }()
//    转换拍照比例
    lazy var turnScaleButton:UIButton = {
        let widthofme:CGFloat = 50
        var btn = UIButton()
        btn.layer.cornerRadius = widthofme/2
        btn.setImage(#imageLiteral(resourceName: "屏幕比例"), for: .normal)
        btn.addTarget(self, action: #selector(self.turnScale), for: .touchUpInside)
        return btn
    }()
    
//    lazy var Beautyslider:UISlider = {
//        let slider = UISlider()
//        slider.tintColor = naviColor
//        slider.minimumValue = 0
//        slider.maximumValue = 2
//        slider.addTarget(self, action: #selector(self.sliderChange), for: .valueChanged)
//        slider.isContinuous = false
//        return slider
//    }()
//
//
    
    //MAKR: - 属性
    var mCamera:GPUImageStillCamera!
    var mFillter:GPUImageFilter!
    var ifFilter:IFImageFilter!
    var mGpuimageView:GPUImageView!
    /*
     拍摄比例
     0表示4:3,表示16:9
     在setCamera初始化
     */
    var scaleRate:Int?
    var beautyFilter:GPUImageBeautifyFilter?
    var isBeauty = false
    //焦距缩放
    var beginGestureScale:CGFloat!
    var effectiveScale:CGFloat!
    //聚焦层
    var focusLayer:CALayer?
    
    
    //MARK: - 页面生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
        beginGestureScale = 1
        effectiveScale = 1
        setCamera()
        //设置底部view
        setDefaultView()
        //设置聚焦图片
        setFocusImage(#imageLiteral(resourceName: "聚焦 "))
        // Do any additional setup after loading sthe view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        //检测相册权限
        checkCameraAuthorization()

        //检测比例显示问题
        if scaleRate != 0{
            scaleRate = 0
            turnScale()
        }
        //FIXME:不完美的黑屏解决方案
        switchFillter(index: 0)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - 自定义方法
    /// 拍照动作
    @objc func  takePhoto(){
        if !isBeauty{
            mCamera.capturePhotoAsJPEGProcessedUp(toFilter: ifFilter, withCompletionHandler: {
                processedJPEG, error in
                if let aJPEG = processedJPEG {
                    guard let imageview = UIImage(data: aJPEG) else{  return }
                    self.present(CheckViewController(image: self.normalizedImage(image: imageview)), animated: false, completion: nil)
                }
            })
        }else{
            mCamera.capturePhotoAsJPEGProcessedUp(toFilter: beautyFilter!, withCompletionHandler: {
                processedJPEG, error in
                if let aJPEG = processedJPEG {
                    guard let imageview = UIImage(data: aJPEG) else{  return }
                    self.present(CheckViewController(image: self.normalizedImage(image: imageview)), animated: false, completion: nil)
                }
            })
        }
    }
    
    
    /// 检查相机权限
    func checkCameraAuthorization(){
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
            self.present(alertController, animated: true, completion: nil)
            
        }
        
        
        
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
        view.addSubview(turnScaleButton)
        view.addSubview(cameraFillterView)
        // view.addSubview(Beautyslider)
        defaultBottomView.snp.makeConstraints({
            make in
            make.bottom.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(SCREEN_HEIGHT*1/4)
        })
        
        let widthOfShot:CGFloat = 75
        shotButton.snp.makeConstraints({
            make in
            make.center.equalTo(defaultBottomView)
            make.width.height.equalTo(widthOfShot)
        })
        
        let widthOfTop:CGFloat = 30

        turnScaleButton.snp.makeConstraints({
            make in
            make.width.height.equalTo(widthOfTop)
            make.left.equalToSuperview().offset(20)
            make.top.equalToSuperview().offset(15)
        })
        
        turnCameraButton.snp.makeConstraints({
            make in
            make.width.height.equalTo(widthOfTop)
            make.right.equalToSuperview().offset(-20)
            make.top.equalToSuperview().offset(15)
        })
        cameraFillterView.snp.makeConstraints({
            make in
            make.top.equalTo(SCREEN_HEIGHT)
            make.width.equalToSuperview()
            make.height.equalTo(SCREEN_HEIGHT*1/4)
        })
        mGpuimageView.snp.makeConstraints({
            make in
            make.top.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(SCREEN_HEIGHT*3/4)
        })
        
//        Beautyslider.isHidden = true
//        Beautyslider.snp.makeConstraints({
//            make in
//            make.height.equalTo(20)
//            make.width.equalTo(300)
//            make.centerX.equalToSuperview()
//            make.top.equalTo(defaultBottomView).offset(-40)
//
//        })
        
        
    }
    
    //初始化相机和默认滤镜
    func setCamera(){
        scaleRate = 0//默认设置为640大小比例
        mCamera = GPUImageStillCamera(sessionPreset:AVCaptureSession.Preset.vga640x480.rawValue , cameraPosition: AVCaptureDevice.Position.front)
        mCamera.outputImageOrientation = UIInterfaceOrientation.portrait
        mCamera.horizontallyMirrorFrontFacingCamera = true
        //滤镜
        ifFilter = IFNormalFilter()
        ifFilter.useNextFrameForImageCapture()
        mGpuimageView = GPUImageView()
        view.addSubview(mGpuimageView)
        mCamera.addTarget(ifFilter)
        ifFilter.addTarget(mGpuimageView)
        mCamera.startCapture()
    }
    
    
    //获取所有滤镜
    func addFillter(){
       
       // cameraFillterView.collectionView.reloadData()
    }
    
    @objc func turnCamera(_ btn:UIButton){
        mCamera.rotateCamera()
        beginGestureScale = 1 ; effectiveScale = 1
    }
    
    //拍照比例切换
    @objc func turnScale(){
        
        scaleRate = (scaleRate!+1)%2
        switch scaleRate {
        case 0:
            //设置为640x480的大小
            mCamera.captureSession.beginConfiguration()
            let pre = AVCaptureSession.Preset.vga640x480
            mCamera.captureSession.sessionPreset = pre
            mCamera.captureSession.commitConfiguration()
            UIView.animate(withDuration: 0.2, animations: {
                self.mGpuimageView.transform = CGAffineTransform.identity
                self.mGpuimageView.snp.remakeConstraints({
                    make in
                    make.height.equalTo(SCREEN_HEIGHT*3/4)
                    make.width.left.top.equalToSuperview()
                })
                self.view.layoutIfNeeded()
                self.defaultBottomView.center.y = SCREEN_HEIGHT*7/8
            })
        case 1:
            //设置为1280x720的大小
            mCamera.captureSession.beginConfiguration()
            let pre = AVCaptureSession.Preset.hd1280x720
            mCamera.captureSession.sessionPreset = pre
            mCamera.captureSession.commitConfiguration()
            UIView.animate(withDuration: 0.2, animations: {
                //刷新预览视图布局
                self.mGpuimageView.snp.remakeConstraints({
                    make in
                    make.width.height.equalToSuperview()
                    make.left.top.equalToSuperview()
                })
                //刷新
                self.view.layoutIfNeeded()
                self.defaultBottomView.center.y = SCREEN_HEIGHT*9/8
            })
            
        case 2:
            break
        default:
            break
            
        }
        
    }
    
    //修正拍照角度
    ///
    /// - Parameter image: 传入要调整的image
    /// - Returns: 调整完毕的image
    func normalizedImage(image:UIImage) -> UIImage{
        var img = image
        if img.imageOrientation == .up{
            return img
        }
        // 原始图片可以根据照相时的角度来显示，但UIImage无法判定，于是出现获取的图片会向左转９０度的现象。
        // 以下为调整图片角度的部分
        UIGraphicsBeginImageContext(image.size)
        img.draw(in: CGRect.init(x: 0, y: 0, width: image.size.width, height: image.size.height))
        img = UIGraphicsGetImageFromCurrentImageContext() ?? image
        UIGraphicsEndImageContext()
        // 调整图片角度完毕
        
        return img
    }
    
    
    

}


//MARK: - 协议实现

extension FConViewController:FillterSelectViewDelegate,DefaultBottomViewDelegate{
    //MARK: - 切换滤镜的方法
    ///
    /// - Parameter index: 滤镜代码
    func switchFillter(index: Int) {
        //使用INS自定义滤镜
        mCamera.removeAllTargets()
        ifFilter = FilterGroup.getFillter(filterType: index)
        ifFilter.addTarget(mGpuimageView)
        mCamera.addTarget(ifFilter)
        mCamera.startCapture()

    }
    
    
    
    /// 切换滤镜方法
    func changeFillter() {
        isBeauty = false
        view.bringSubview(toFront: shotButton)
        //记录两个view的center点
        let centerBottom = cameraFillterView.center
        let centerReset = defaultBottomView.center
        let yB = cameraFillterView.frame.origin.y
        let yR = defaultBottomView.frame.origin.y/2
        //对两个底部View做动画平移,交换位置
    
        cameraFillterView.addObserver(self, forKeyPath: "center", options: [.new,.old], context: nil)
        
        UIView.animate(withDuration: 0.2, animations: {
            self.cameraFillterView.center = centerReset
            self.shotButton.center.y =  self.defaultBottomView.center.y*16/15
        })
        
        cameraFillterView.mb = {
            self.shotButton.center =  centerBottom
            self.cameraFillterView.center  = centerReset
        }
        
        
    }
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        print(keyPath ?? "")
        print("完成回调 -- \(String(describing: cameraFillterView.value(forKey: keyPath!)))")

    }
    
    
    /// 美颜按钮
    ///
    /// - Parameter btn: 按钮
    func beauty(_ btn:UIButton) {
        if btn.isSelected{
            isBeauty = true
            //FIXME: 有问题的滑动条
           // Beautyslider.isHidden = false
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
            filterGroup.addTarget(mGpuimageView)
            //使用第三方美颜滤镜
            beautyFilter = GPUImageBeautifyFilter()
            //将美颜滤镜加入相机
            mCamera.addTarget(beautyFilter!)
            beautyFilter!.addTarget(mGpuimageView)
            mCamera.startCapture()
            
            
        }else{
            //取消美颜
//            Beautyslider.isHidden = true
            isBeauty = false
            mCamera.removeAllTargets()
            mCamera.addTarget(ifFilter)
            mCamera.startCapture()
        }
    }
    
    @objc func  sliderChange(){
//        print(Beautyslider.value)
//        beautyFilter?.setBrightness(CGFloat(Beautyslider.value), saturation: 1.05)
        
    }
    
}


//MARK: - 手势代理调整焦距
extension FConViewController:UIGestureRecognizerDelegate,CAAnimationDelegate{
   
    
    
    /// 设置聚焦图片，添加聚焦层Layer
    ///
    /// - Parameter focusImage: 图片
    func setFocusImage(_ focusImage:UIImage){
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: focusImage.size.width/3, height: focusImage.size.height/3))
        imageView.image = focusImage
        let layer = imageView.layer
        layer.isHidden = true
        mGpuimageView.layer.addSublayer(layer)
        focusLayer = layer
        if focusLayer != nil{
            mGpuimageView.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(Focus(_:)))
            mGpuimageView.addGestureRecognizer(tap)
            let pinch = UIPinchGestureRecognizer(target: self, action: #selector(focusDistance(pinch:)))
            mGpuimageView.addGestureRecognizer(pinch)
            pinch.delegate = self
        }
    
    }
    
    
    
    //对焦动画
    func layerAnimation(with point: CGPoint) {
        if (focusLayer != nil) {
            ///聚焦点聚焦动画设置
            let focusLayer: CALayer? = self.focusLayer
            focusLayer?.isHidden = false
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            focusLayer?.position = point
            focusLayer?.transform = CATransform3DMakeScale(2.0, 2.0, 1.0)
            CATransaction.commit()
            let animation = CABasicAnimation(keyPath: "transform")
            animation.toValue = NSValue(caTransform3D: CATransform3DMakeScale(1.0, 1.0, 1.0))
            animation.delegate = self
            animation.duration = 0.3
            animation.repeatCount = 1
            animation.isRemovedOnCompletion = false
            animation.fillMode = kCAFillModeForwards
            focusLayer?.add(animation, forKey: "animation")
        }
    }

    
    //对焦
    @objc func Focus(_ tap:UITapGestureRecognizer){
        mGpuimageView.isUserInteractionEnabled = false
        var touchPoint: CGPoint = tap.location(in: tap.view)
        layerAnimation(with: touchPoint)
        /**
         *下面是照相机焦点坐标轴和屏幕坐标轴的映射问题，以下是最简单的解决方案也是最准确的坐标转换方式
         后置摄像头和前置要分别处理
         */
        if mCamera.cameraPosition() == AVCaptureDevice.Position.back {
            touchPoint = CGPoint(x: (touchPoint.y) / (tap.view?.bounds.size.height )!, y: 1 - (touchPoint.x ) / (tap.view?.bounds.size.width)!)
        } else {
            touchPoint = CGPoint(x: (touchPoint.y ) / (tap.view?.bounds.size.height)!, y: (touchPoint.x ) / (tap.view?.bounds.size.width)!)
        }
        /*以下是相机的聚焦和曝光设置，前置不支持聚焦但是可以曝光处理，后置相机两者都支持，下面的方法是通过点击一个点同时设置聚焦和曝光，当然根据需要也可以分开进行处理
        */
        if mCamera.inputCamera.isExposurePointOfInterestSupported && mCamera.inputCamera.isExposureModeSupported(.continuousAutoExposure) {
            do{
                try mCamera.inputCamera.lockForConfiguration()
                mCamera.inputCamera.exposurePointOfInterest = touchPoint
                mCamera.inputCamera.exposureMode = .continuousAutoExposure
                if mCamera.inputCamera.isFocusPointOfInterestSupported && mCamera.inputCamera.isFocusModeSupported(.autoFocus) {
                    mCamera.inputCamera.focusPointOfInterest = touchPoint
                    mCamera.inputCamera.focusMode = .autoFocus
                }
                mCamera.inputCamera.unlockForConfiguration()
            } catch {
                print(error)
            }
        }
        
        
    }
    //焦距变换
    @objc func focusDistance(pinch:UIPinchGestureRecognizer){
        self.effectiveScale = self.beginGestureScale*(pinch.scale)
        if effectiveScale<1.0{
            effectiveScale = 1.0
        }
        let maxScale:CGFloat = 3.0
        // 最大倍数
        if effectiveScale>maxScale{
            effectiveScale = 3.0
        }
        CATransaction.begin()
        CATransaction.setAnimationDuration(0.025)
        //解锁并开始配置
        if ((try? mCamera.inputCamera.lockForConfiguration()) != nil) {
            mCamera.inputCamera.videoZoomFactor = effectiveScale
            mCamera.inputCamera.unlockForConfiguration()
        }else{
            print("tansmation error")
            
        }
        CATransaction.commit()
        
    }
    //重置Foucslayer
    @objc func focusLayerReset(){
        self.mGpuimageView.isUserInteractionEnabled = true
        focusLayer?.isHidden = true
    }
    
    //手势代理
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer is UIPinchGestureRecognizer{
            beginGestureScale = effectiveScale
        }
        return true
    }
    //动画代理
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
     
        perform(#selector(focusLayerReset), with: self, afterDelay: 0.5)
    }
   
    
    
    
}
