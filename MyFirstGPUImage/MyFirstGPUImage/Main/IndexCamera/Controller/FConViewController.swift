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
import ProgressHUD
import CoreMotion
import CoreML

class FConViewController: UIViewController {
    
    //UI
    //  拍照按钮
    lazy var shotButton:RoundProgressButtonView = {
        let widthofme:CGFloat = 75
        var btn = RoundProgressButtonView(frame: CGRect(x: 0, y: 0, width: widthofme, height: widthofme))
        btn.layer.cornerRadius = widthofme/2
        btn.delegate = self
        //btn.frame = CGRect.init(x: 0, y: 0, width: widthofme, height: widthofme)
        btn.center = self.defaultBottomView.center
        return btn
    }()
    //  底部白色VIEW
    lazy var defaultBottomView:DefaultBotomView = {
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
    lazy var topView:TopView = {
        let v = TopView(upView: self.view)
        v.backgroundColor = UIColor.clear
        v.delegate = self
        return v
    }()

    lazy var Beautyslider:UISlider = {
        let slider = UISlider()
        slider.tintColor = naviColor
        // slider.backgroundColor = UIColor.brown
        slider.minimumValue = 0.0
        slider.maximumValue = 0.8
        slider.addTarget(self, action: #selector(self.sliderChange), for: .valueChanged)
        slider.isContinuous = false
        slider.value = 0.5
        return slider
    }()
    
    lazy var tipLabel:UILabel = {
        let label = UILabel();
        label.textColor = UIColor.orange;
        return label;
    }()
    
 

    
    //MAKR: - 属性
    var mCamera:GPUImageStillCamera!
    //拍摄视频camera
    var movieWriter:GPUImageMovieWriter?
    var videoUrl:URL?
    //长视频
    var videoUrls = [URL]()
    var saveManager:SaveVieoManager?

   // var mFillter:GPUImageFilterGroup!
    var ifFilter:GPUImageFilterGroup!
    var mGpuimageView:GPUImageView!
    /*
     拍摄比例
     0表示4:3,表示16:9
     在setCamera初始化
     */
    var scaleRate:Int?
    var ifaddFilter:Bool!
    var beautyFilter:GPUImageBeautifyFilter?
    var isBeauty = false
    //焦距缩放
    var beginGestureScale:CGFloat!
    var effectiveScale:CGFloat!
    //聚焦层
    var focusLayer:CALayer?
    //人脸识别层
    lazy var layersView: FaceLayerView = {
        let view = FaceLayerView(frame: mGpuimageView.frame)
        return view
    }()
    
    lazy var detector: CIDetector = {
        let context = CIContext()
        let options: [String : Any] = [
            CIDetectorAccuracy: CIDetectorAccuracyHigh,
            CIDetectorTracking: true
        ]
        let detector = CIDetector(ofType: CIDetectorTypeFace, context: context, options: options)!
        return detector
    }()
    
    //陀螺仪判断屏幕方向
    var motionManager = CMMotionManager()
    var result = "unknown"
    var timer:Timer!
    
    //判断是否正在拍摄livePhoto
    var isLivePhoto = false
    var liveTimer:Timer?
    var liveTimer2:Timer?
    var liveCounter:Double = 0.5;
    var liveCounter2:Double = 0.5;
    var liveUrl:URL!
    
    //model
    lazy var mlModel:Inceptionv3  = {
        return Inceptionv3()
    }()
    

    
    //MARK: - 页面生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        beginGestureScale = 1
        effectiveScale = 1
        setCamera()
        //设置底部view
        setDefaultView()
        //设置聚焦图片
        setFocusImage(#imageLiteral(resourceName: "聚焦 "))
        setFaceDetectionImage()
        // Do any additional setup after loading sthe view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
      self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        //检测相册权限
        checkCameraAuthorization()
        //检测比例显示问题
        //FIXME:不完美的黑屏解决方案
        if !ifaddFilter{
            //默认美颜滤镜
            switchFillter(index:0);
        }
        
        //self.present(UINavigationController(rootViewController: AlbumViewController()), animated: true, completion: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if cameraFillterView.mb != nil{
            UIView.animate(withDuration: 0.3, animations: {
                self.cameraFillterView.mb!()
                self.view.layoutIfNeeded()
                
            })
        }
    }
    
    //MARK: - 析构注销函数()
    deinit{
        timer.invalidate()
        motionManager.stopGyroUpdates()
        motionManager.stopDeviceMotionUpdates()
        motionManager.stopAccelerometerUpdates()
        motionManager.stopMagnetometerUpdates()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - 自定义方法
    
    /// 拍照动作
    @objc func  takePhoto(){
        weak var  weakSelf = self
   
        
        mCamera.capturePhotoAsJPEGProcessedUp(toFilter: ifFilter, withCompletionHandler: {
            processedJPEG, error in
            if let aJPEG = processedJPEG {
                guard let imageview = UIImage(data: aJPEG) else{  return }
                let vc  = CheckViewController(image: self.normalizedImage(image: imageview),type:0)
                vc.willDismiss = {
                    //将美颜状态重置
                    if (weakSelf?.isBeauty)!{
                        weakSelf?.isBeauty = false
                       weakSelf?.defaultBottomView.beautyButton.isSelected = false
                        // weakSelf?.beauty()
                    }
                    //使用闭包，在vc返回时将底部隐藏，点击切换时在取消隐藏

                    if weakSelf?.scaleRate != 0{
                        //weakSelf?.scaleRate = 0
                        weakSelf?.defaultBottomView.isHidden = true

                    }
                }
                weakSelf?.present(vc, animated: true, completion: nil)
            }
        })
      
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
    
}


//MARK: - UI工厂方法
extension FConViewController{
    
    //初始化View布局
    func setDefaultView(){
        view.addSubview(defaultBottomView)
        view.addSubview(shotButton)
        view.addSubview(topView)
        view.addSubview(cameraFillterView)
        view.addSubview(Beautyslider)
        view.addSubview(tipLabel)
        
        defaultBottomView.snp.makeConstraints({
            make in
            make.centerX.equalToSuperview()
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
        
        topView.snp.makeConstraints({
            make in
            make.top.equalTo(isiPhoneX() ? IPHONEX_TOP_FIX : 0 )
            make.left.right.equalToSuperview()
            make.height.equalTo(55)
        })
        
        Beautyslider.isHidden = true
        Beautyslider.snp.makeConstraints({
            make in
            make.height.equalTo(40)
            make.width.equalTo(300)
            make.centerX.equalToSuperview()
            make.top.equalTo(defaultBottomView).offset(-40)
        })
        
        tipLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
   
    }
    
    //初始化相机和默认滤镜
    func setCamera(){
        scaleRate = 0//默认设置为640大小比例
        mCamera = GPUImageStillCamera(sessionPreset:AVCaptureSession.Preset.hd1280x720.rawValue , cameraPosition: AVCaptureDevice.Position.front)
        mCamera.outputImageOrientation = UIInterfaceOrientation.portrait
        //MARK: - 开启镜面，人脸识别正常
        mCamera.horizontallyMirrorFrontFacingCamera = true
        //滤镜
        ifFilter = IFNormalFilter()
        ifFilter.useNextFrameForImageCapture()
        mGpuimageView = GPUImageView()
        mGpuimageView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill
        view.addSubview(mGpuimageView)
        mCamera.addTarget(ifFilter)
        //更改比例预定
        //ifFilter = GPUImageCropFilter.init(cropRegion: )
        ifFilter.addTarget(mGpuimageView)
        mCamera.startCapture()
        ifaddFilter = false
        mCamera.addAudioInputsAndOutputs()//避免录制第一帧黑屏

        mCamera.delegate = self


    }
    
    
    //获取所有滤镜
    func addFillter(){
        
        // cameraFillterView.collectionView.reloadData()
    }
    
    
    
    //修正拍照角度
    ///
    /// - Parameter image: 传入要调整的image
    /// - Returns: 调整完毕的image
    func normalizedImage(image:UIImage) -> UIImage{
        var img = image
        print(img.imageOrientation)
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
    
    func finishLongVideoRecord() {
          finishRecordLongVideo()
    }
    
    func deletePrevious() {
        print("删除上段")
        deletePreviousImple()
    }
    
    
    
    /// 跳转到视频拍摄
    ///
    /// - Parameter btn: 点击页面上的视频按钮
    func pushVideo(isRecord:Bool) {
        shotButton.ifLongRecord = isRecord
        shotButton.tipLabel.isHidden = isRecord
        topView.liveButton.isHidden = true

        if !isRecord{
          shotButton.stop()
          shotButton.ifLongRecord = false
          topView.liveButton.isHidden = false

        }
    }
    //MARK: - 切换滤镜的方法
    ///
    /// - Parameter index: 滤镜代码
    func switchFillter(index: Int) {
        //隐藏滑动条，重置美颜
        Beautyslider.isHidden = true
        isBeauty = false
        //defaultBottomView.beautyButton.isSelected = false
        //使用INS自定义滤镜
        mCamera.removeAllTargets()
        let filterGroup = GPUImageFilterGroup()//创建滤镜组
        beautyFilter = GPUImageBeautifyFilter()//美颜
        let ifFilter2 = FilterGroup.getFillter(filterType: index)

        //添加滤镜组链
        filterGroup.addTarget(beautyFilter!)
        filterGroup.addTarget(ifFilter2)
        beautyFilter?.addTarget(ifFilter2)
        filterGroup.initialFilters = [beautyFilter!]
        filterGroup.terminalFilter = ifFilter2
        ifFilter = filterGroup
        //ifFilter.addFilter(GPUImageBeautifyFilter())
        //自定义滤镜
        if index == 13{
            let f = GPUImageLookupFilter()
            let lookup =  GPUImagePicture.init(image:UIImage.init(named: "testlookup"));
            lookup?.addTarget(f, atTextureLocation: 0);
            f.useNextFrameForImageCapture()
            f.addTarget(mGpuimageView)
            mCamera.addTarget(f)
        }
        ifFilter.addTarget(mGpuimageView)
        ifaddFilter = true
        mCamera.addTarget(ifFilter)
        mCamera.startCapture()
        
    }
    /// 切换滤镜方法
    func changeFillter() {
        isBeauty = false
        defaultBottomView.beautyButton.isSelected = isBeauty
        view.bringSubview(toFront: shotButton)
        
        self.shotButton.tipLabel.isHidden = true
        //记录两个view的center点
        let centerBottom = cameraFillterView.center
        let centerReset = defaultBottomView.center
        //对两个底部View做动画平移,交换位置
        UIView.animate(withDuration: 0.2, animations: {
            self.cameraFillterView.snp.remakeConstraints({
                make in
                make.width.height.top.left.equalTo(self.defaultBottomView)
            })
            self.shotButton.snp.remakeConstraints({
                make in
                make.width.height.equalTo(75)
                make.centerX.equalToSuperview()
                make.centerY.equalTo(centerReset.y*16/15)
            })
            self.shotButton.moveLine()
            self.view.layoutIfNeeded()
        })
        cameraFillterView.mb = {
            self.shotButton.tipLabel.isHidden = false
            self.cameraFillterView.snp.remakeConstraints({
                make in
                make.center.equalTo(centerBottom)
                make.width.equalToSuperview()
                make.height.equalTo(SCREEN_HEIGHT*1/4)
            })
            self.shotButton.snp.remakeConstraints({
                make in
                make.width.height.equalTo(75)
                make.centerX.equalToSuperview()
                make.centerY.equalTo(centerReset.y)
            })
            self.shotButton.reSetLine()
            self.view.layoutIfNeeded()
            self.defaultBottomView.layoutIfNeeded()
        }
        
        
    }
    
    
    /// 美颜按钮
    ///
    /// - Parameter btn: 按钮
    func beauty() {
        print(isBeauty)
        if !isBeauty{
            //初始化滑动条
            Beautyslider.value = 0.5
            isBeauty = true
             Beautyslider.isHidden = false
            
        }else{
            //取消美颜
            Beautyslider.isHidden = true
            isBeauty = false

        }
    }
    
    
    //滑动条事件
    @objc func  sliderChange(){
        //print(beautyFilter?.getCom())
        let newCom:CGFloat = CGFloat(Beautyslider.value)

        if  beautyFilter != nil{
            beautyFilter?.setCom(newCom)
        }
        //beautyFilter?.setBrightness(CGFloat(Beautyslider.value), saturation: 1.05)
        
        
    }
    
}


//MARK: - topViewDelegate
extension FConViewController:topViewDelegate{
    //切换闪光灯
    func flashMode() {
        
        if mCamera.inputCamera.hasFlash && mCamera.inputCamera.hasTorch{
        switch mCamera.inputCamera.flashMode {
        case .off:
            if (try? mCamera.inputCamera.lockForConfiguration()) != nil{
                mCamera.inputCamera.flashMode = .on
                mCamera.inputCamera.torchMode = .auto
                mCamera.inputCamera.unlockForConfiguration()
                topView.flashButton.setImage(#imageLiteral(resourceName: "闪光灯打开"), for: .normal)
            }
        case .on:
            
            if (try? mCamera.inputCamera.lockForConfiguration()) != nil{
                mCamera.inputCamera.flashMode = .auto
                mCamera.inputCamera.torchMode = .auto
                mCamera.inputCamera.unlockForConfiguration()
                topView.flashButton.setImage(#imageLiteral(resourceName: "闪光灯自动"), for: .normal)
            }
            
        case .auto:
            
            if (try? mCamera.inputCamera.lockForConfiguration()) != nil{
                mCamera.inputCamera.flashMode = .off
                mCamera.inputCamera.torchMode = .off
                topView.flashButton.setImage(#imageLiteral(resourceName: "闪光灯关闭"), for: .normal)
                mCamera.inputCamera.unlockForConfiguration()
            }
        }
        //
        }else{
            ProgressHUD.showError("仅后置摄像头支持闪光灯哦")
        }
}
    
    
    func turnCamera(){
        mCamera.rotateCamera()
        beginGestureScale = 1 ; effectiveScale = 1
    }
    
    func liveMode(){
        setLiveMode()
    }
    
    //拍照比例切换
     func turnScale(){
        
        let duration:Double? = 0.2
        scaleRate = (scaleRate!+1)%2
        switch scaleRate {
        case 0:
            //设置为640x480的大小
            defaultBottomView.isHidden = false
            mCamera.captureSession.beginConfiguration()
            let pre = AVCaptureSession.Preset.vga640x480
            mCamera.captureSession.sessionPreset = pre
            mCamera.captureSession.commitConfiguration()
            
            UIView.animate(withDuration: duration ?? 0.2, animations: {
                self.mGpuimageView.transform = CGAffineTransform.identity
                self.mGpuimageView.snp.remakeConstraints({
                    make in
                    make.height.equalTo(SCREEN_HEIGHT*3/4)
                    make.width.left.top.equalToSuperview()
                })
                self.view.layoutIfNeeded()
                self.defaultBottomView.hideMyself(isHidden: false)
                //self.defaultBottomView.center.y = SCREEN_HEIGHT*7/8
                
            })
        case 1:
            //设置为1280x720的大小
            mCamera.captureSession.beginConfiguration()
            let pre = AVCaptureSession.Preset.hd1280x720
            mCamera.captureSession.sessionPreset = pre
            mCamera.captureSession.commitConfiguration()
            // mCamera.forceProcessing(at: CGSize(width: SCREEN_WIDTH, height: SCREEN_HEIGHT))
            
            UIView.animate(withDuration: duration ?? 0.2, animations: {
                //刷新预览视图布局
                self.mGpuimageView.snp.remakeConstraints({
                    make in
                    make.width.height.equalToSuperview()
                    make.left.top.equalToSuperview()
                })
                //刷新
                self.view.layoutIfNeeded()
                self.defaultBottomView.hideMyself(isHidden: true)
                //self.defaultBottomView.center.y = SCREEN_HEIGHT*9/8
            })
            
        case 2:
            break
        default:
            break
            
        }
    }
    
    //跳转到下一页
    func push(_ vc: UIViewController) {
        setNavi(nav: navigationController!)
        
        navigationController?.pushViewController(vc, animated: true)
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


//MARK: - 拍照按钮代理,视频拍摄工厂方法
extension FConViewController:ProgresssButtonDelegate{
   
    func videoControl(control: RoundProgressButtonView, gest: UIGestureRecognizer) {
        //
        print(gest.state.hashValue)
        switch gest.state {
        case .began:
             control.tipLabel.isHidden = true
             defaultBottomView.recordBackView.isHidden = false
             control.ifRecord = true
             startRecord()
        case.ended:
            if control.ifRecord {
                recordBtnFinish()
                defaultBottomView.recordBackView.isHidden = true
                control.tipLabel.isHidden = false
                control.ifRecord = false
            }else if isLivePhoto{
                finishLiveRecord()
            }else{
                takePhoto()

            }
        default:
            break
        }
        
    }
    
    func startRecord(){
        shotButton.reStartCount()
        //shotButton.ifLivePhoto  = isLivePhoto
        let name = Date().timeIntervalSince1970
        videoUrl = URL(fileURLWithPath: "\(NSTemporaryDirectory())folder_demo\(name).mp4")
        unlink(videoUrl?.path)
        //获取视频大小，作为size
        var size = CGSize(width: 480, height: 640)
        if scaleRate == 1{
            size = CGSize(width: 720, height: 1280)
        }
        
//        let orientation: UIInterfaceOrientation = UIApplication.shared.statusBarOrientation
//        if orientation == .portrait || orientation == .portraitUpsideDown {
//        } else {
//            size = CGSize.init(width: size.width, height: size.height)
//        }
        //解决Size不是16的倍数，出现绿边
//        while (size.width.truncatingRemainder(dividingBy: 16) > 0) {
//            print(size.width)
//            size.width = size.width+1
//        }
//        while (size.height.truncatingRemainder(dividingBy: 16) > 0) {
//            size.height = size.height+1
//        }
        //CGSize(width: 480, height: 640)
        movieWriter = GPUImageMovieWriter(movieURL:videoUrl, size:size )
       //解决录制MP4帧失败的问题
        movieWriter?.assetWriter.movieFragmentInterval = kCMTimeInvalid
        movieWriter?.encodingLiveVideo = true
        movieWriter?.setHasAudioTrack(true, audioSettings: nil)
        //movieWriter?.shouldPassthroughAudio = true
        ifFilter.addTarget(movieWriter)
        self.mCamera.audioEncodingTarget = self.movieWriter
        self.movieWriter?.startRecording()
    }
    
    
    func recordBtnFinish() {
        // 录像状态结束
        //ProgressHUD.show("保存中")
        movieWriter?.finishRecording()
        let vc:CheckViewController = {
            if isLivePhoto {
                //LivePhoto拍摄
                return CheckViewController(image: nil, type: 2)
                
            } else {
                return CheckViewController(image: nil, type: 1)
            }

        }()

        
        vc.videoUrl = videoUrl
        //self.navigationController?.navigationBar.isHidden = false
        vc.videoScale = self.scaleRate
        weak var weakSelf = self
        vc.willDismiss = {
            
            if (weakSelf?.isLivePhoto ?? false) {
                weakSelf?.liveTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.updateLiveCounter), userInfo: nil, repeats: true)
            }
            
            //将美颜状态重置
            if (weakSelf?.isBeauty)!{
                weakSelf?.isBeauty = false
                weakSelf?.defaultBottomView.beautyButton.isSelected = false
                // weakSelf?.beauty()
            }
            //使用闭包，在vc返回时将底部隐藏，点击切换时在取消隐藏
            
            if weakSelf?.scaleRate != 0{
               // weakSelf?.scaleRate = 0
                weakSelf?.defaultBottomView.isHidden = true
            }
        }
        
    
        self.present(vc, animated: true, completion: nil)

    }
  
    //MARK: - 拍摄分段长视频
    func touchRecordButton(isRecord:Bool) {
        weak var weakSelf = self
        if isRecord{
            //录制时升起空白页
          weakSelf?.defaultBottomView.recordBackView.isHidden = false
          weakSelf?.topView.turnScaleButton.isHidden = true
                startRecord()
                videoUrls.append(videoUrl!)
        }else{
            weakSelf?.topView.turnScaleButton.isHidden = false

            weakSelf?.defaultBottomView.recordBackView.isHidden = true
            movieWriter?.finishRecording()
        }
    }
    

    func finishRecordLongVideo() {
        shotButton.stop()
        if videoUrls.count <= 0{
            shotButton.stop()
            shotButton.ifLongRecord = false
            defaultBottomView.selectionView.swipRight()
            defaultBottomView.transmationAction(isSelected: false)
            defaultBottomView.startLongRecord(isRecord: false)
            return
        }
        //视频合成
        ProgressHUD.show("合成中")
        saveManager = SaveVieoManager(urls: videoUrls)
        let newUrl = URL(fileURLWithPath: "\(NSTemporaryDirectory())folder_all.mp4")
        unlink(newUrl.path)
        if let com =  saveManager?.combineVideos(){
            saveManager?.store(com, storeUrl: newUrl, success: {
                print("combine success")
               
                DispatchQueue.main.async {
                    let vc =  CheckViewController()
                    vc.videoUrl = newUrl
                    vc.videoScale = self.scaleRate
                    weak var weakSelf = self
                    vc.willDismiss = {
                        //将美颜状态重置
                        if (weakSelf?.isBeauty)!{
                            weakSelf?.isBeauty = false
                            weakSelf?.defaultBottomView.beautyButton.isSelected = false
                            // weakSelf?.beauty()
                        }
                        //使用闭包，在vc返回时将底部隐藏，点击切换时在取消隐藏
                        if weakSelf?.scaleRate != 0{
                            // weakSelf?.scaleRate = 0
                            weakSelf?.defaultBottomView.backgroundColor = UIColor.clear
                        }
                    }
                    ProgressHUD.showSuccess("合成成功")
                    weakSelf?.videoUrls.removeAll()
                    self.present(vc, animated: true, completion: nil)
                }
            })
            
        }
    }
    
    //删除上段方法实现
    func deletePreviousImple(){
        if videoUrls.count>0{
            videoUrls.removeLast()
            shotButton.deletrLast()
        }else{
            shotButton.stop()
            shotButton.ifLongRecord = false
            defaultBottomView.selectionView.swipRight()
            defaultBottomView.transmationAction(isSelected: false)
            defaultBottomView.startLongRecord(isRecord: false)
        }
    }
}

// MARK: - coreMl拍摄识别
extension FConViewController{
    
    func classifier(image:UIImage){
        //修改图片sizes到model大小
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 299, height: 299), true, 2.0)
        image.draw(in: CGRect(x: 0, y: 0, width: 299, height: 299))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        var pixelBuffer : CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(newImage.size.width), Int(newImage.size.height), kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)
        guard (status == kCVReturnSuccess) else {
            return
        }
        
        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)
        
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: pixelData, width: Int(newImage.size.width), height: Int(newImage.size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue) //3
        
        context?.translateBy(x: 0, y: newImage.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)
        
        UIGraphicsPushContext(context!)
        newImage.draw(in: CGRect(x: 0, y: 0, width: newImage.size.width, height: newImage.size.height))
        UIGraphicsPopContext()
        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        
        // Core ML
        guard let prediction = try? mlModel.prediction(image: pixelBuffer!) else {
            return
        }
        print(prediction.classLabel)
       //tipLabel.text = "I think this is a \(prediction.classLabel)."
    }
    
    
}

//MARK: - 人脸识别
extension FConViewController:GPUImageVideoCameraDelegate{
    
    func willOutputSampleBuffer(_ sampleBuffer: CMSampleBuffer!) {
       // print(self.mCamera.inputCamera.iso);

        // 创建buffer的拷贝
        var bufferCopy:CMSampleBuffer?
        let err = CMSampleBufferCreateCopy(kCFAllocatorDefault, sampleBuffer, &bufferCopy)
        if err == noErr{
            detect(bufferCopy!)
        }
    }
    
    
    func  setFaceDetectionImage(){
        self.mGpuimageView.addSubview(layersView)
        getOrientation()
    }
    
    func detect(_ sampleBuffer: CMSampleBuffer) {
        
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
        else {return}
        let personciImage = CIImage.init(cvPixelBuffer: pixelBuffer)
        let testImage = UIImage.init(ciImage: personciImage)
        //ML
        //self.classifier(image: testImage)
        
        
       // print(testImage.imageOrientation.rawValue)
        
        let cvImageHeight = CGFloat(CVPixelBufferGetHeight(pixelBuffer))
        let ratio = mGpuimageView.frame.width/cvImageHeight
        //使用陀螺仪判断屏幕旋转方向，然后给ciimage设置图片方向
        let featureDetectorOptions: [String : Any] = {
            return getRow_Col().0
        }() 
        let iffront:Bool = {
           return getRow_Col().1
        }()
        
        let faceAreas = detector
            .features(in: personciImage, options: featureDetectorOptions)
            .compactMap{$0 as? CIFaceFeature}
            .map{ FaceArea(faceFeature: $0, applyingRatio: ratio, ifFront: iffront) }
        
        if faceAreas.count == 0 {
            //没有人脸时候全屏美颜
            let fullRect = CGRect(x: self.view.frame.origin.x, y: self.view.frame.origin.y*2, width: self.view.frame.width*2, height: (self.view.frame.height*2))
            beautyFilter?.updateMask(fullRect)
        }
        
        for i in faceAreas {
            //扩大识别范围给美颜滤镜工作 用
           // print(i.bounds)
            let rect:CGRect = {
                //如果是全屏模式
               // if scaleRate = 1{
                    return CGRect(x: i.bounds.origin.x, y: i.bounds.origin.y*2, width: i.bounds.width*2, height: (i.bounds.height*2))
//                }else{
//                    return CGRect(x: i.bounds.origin.x, y: i.bounds.origin.y, width: i.bounds.width*3/2, height: (i.bounds.height*3/2 + 10))
//                }
            }()
            beautyFilter?.updateMask(rect)
        }
        
        //主线程刷新UI并设置延迟
        DispatchQueue.main.async {
            //判断是否开启识别框
            guard let flag = UserDefaults.standard.value(forKey: "isFaceLayer")else{
                self.layersView.update(areas: faceAreas)
                return
            }
            if flag as! Bool {
                self.layersView.update(areas: faceAreas)
            }else{
                self.layersView.removeAll()
            }
        }
    }
    
    
    //注册陀螺仪和timer
    func getOrientation(){
        motionManager.startAccelerometerUpdates()
        motionManager.startGyroUpdates()
        motionManager.startMagnetometerUpdates()
        motionManager.startDeviceMotionUpdates()
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(update), userInfo: nil, repeats: true)
    }
    
    
    func getRow_Col()->([String : Any],Bool){
        var emumIndex = 6
        let isFront = mCamera.cameraPosition() == .front
        if isFront{
            switch result{
            case "left":
                emumIndex = 3
            case "right":
                emumIndex = 1
            default:
                break
            }
        }else{
            switch result{
            case "left":
                emumIndex = 1
            case "right":
                emumIndex = 3
            default:
                break
            }
        }
        return ([ CIDetectorImageOrientation: emumIndex, ],isFront)
    }
    
    @objc func update() {
   
        if let motion = motionManager.deviceMotion {
            //print(deviceMotion)
            let x = motion.gravity.x
            
            let y = motion.gravity.y
            
            if fabs(y) >= fabs(x) {
                
                if y >= 0 {
                    result =  "updown"
                    // UIDeviceOrientationPortraitUpsideDown;
                } else {
                    result =  "updown"
                    // UIDeviceOrientationPortrait;
                }
                
            } else {
                if x >= 0 {
                    result = "right"
                    // UIDeviceOrientationLandscapeRight;
                } else {
                    result = "left"
                    // UIDeviceOrientationLandscapeLeft;
                }
            }
        }
    }
  
}

// MARK: - Live Photo 拍摄
extension FConViewController{
    
    
    func setLiveMode(){
        if !isLivePhoto{
            isLivePhoto = true
            setLiveStart()
        }else{
            isLivePhoto = false
            movieWriter?.finishRecording()
            liveTimer?.invalidate()
            liveTimer = nil
        }
    }
    
    /// 开始录制LivePhoto
    func setLiveStart(){
        shotButton.isUserInteractionEnabled = true
        startRecord()
        videoUrls.append(videoUrl!)
        liveTimer = Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(updateLiveCounter), userInfo: nil, repeats: true)
    }
    //倒计时控制
    @objc func updateLiveCounter(){
       // print("正在拍摄LivePhoto: ",liveCounter)
        weak var weakSelf = self
            liveFinishRecord(finish: {
                 weakSelf?.deleteLiveBuffer()
                 weakSelf?.startRecord()
                 weakSelf?.videoUrls.append((weakSelf?.videoUrl!)!)
            })
    }
    
    /// 倒计时结束,结束录制
    func finishLiveRecord(){
        weak var weakSelf = self
        weakSelf?.shotButton.isUserInteractionEnabled = false
        weakSelf?.liveTimer?.invalidate()
        //动画
        weakSelf?.shotButton.setScaleAnimation(0.5)
        liveFinishRecord(finish: {
             weakSelf?.startRecord()
            //录制1.5秒后跳转
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.5, execute: {
                weakSelf?.setIntervalFinish()
                weakSelf?.shotButton.setScaleAnimation(1)

            })

        })
        
        
    }
    
    
    
    //录制完成，进行合成和跳转
    @objc func setIntervalFinish(){
        deleteAdditionalBuffer()
        shotButton.isUserInteractionEnabled = false
        weak var weakSelf = self
        self.videoUrls.append(self.videoUrl!)
        weakSelf?.topView.liveCounter.isHidden = true
        liveFinishRecord(finish: {
            print("-------------:",self.videoUrls)
            weakSelf?.liveTimer = nil
            weakSelf?.saveLivePhoto()
        })
    }
    
    
    func saveLivePhoto(){
        //视频裁剪以及合成
        saveManager = SaveVieoManager(urls: videoUrls)
        let newUrl = URL(fileURLWithPath: "\(NSTemporaryDirectory())folder_all.mp4")
        unlink(newUrl.path)
        videoUrl = newUrl
        saveManager?.combineLiveVideos(success: {
            com in
            weak var weakSelf = self
            weakSelf?.saveManager?.store(com, storeUrl: newUrl, success:{
                DispatchQueue.main.async {
                    let vc =  CheckViewController.init(image: nil, type: 2)
                    vc.videoUrl = newUrl
                    vc.videoScale = weakSelf?.scaleRate
                    vc.willDismiss = {
                        if (weakSelf?.isBeauty)!{
                            weakSelf?.isBeauty = false
                            weakSelf?.defaultBottomView.beautyButton.isSelected = false
                        }
                        if weakSelf?.scaleRate != 0{
                            weakSelf?.defaultBottomView.backgroundColor = UIColor.clear
                        }
                    }
                    weakSelf?.present(vc, animated: true, completion: nil)
                    weakSelf?.setLiveStart()
                }
            })
        })
    }
    
    
    
    /// 结束录制
    ///
    /// - Parameter finish: 完成回调
    func liveFinishRecord(finish:@escaping ()->()){
        ifFilter.removeTarget(movieWriter)
        movieWriter?.finishRecording(completionHandler: {
            finish()
        })
    }

    
    /// 录制过程中清空缓冲区
    func deleteLiveBuffer(){
        
        if videoUrls.count>=2{
            do {
                try FileManager.default.removeItem(atPath: (videoUrls.first!.path))
                videoUrls.removeFirst()
            } catch {
            }
        }
        
    }
    
    //录制结束后清空缓冲
    func deleteAdditionalBuffer(){
        while videoUrls.count>=3{
            do {
                try FileManager.default.removeItem(atPath: (videoUrls.first!.path))
                videoUrls.removeFirst()
            } catch {
            }
        }
    }
    

}






