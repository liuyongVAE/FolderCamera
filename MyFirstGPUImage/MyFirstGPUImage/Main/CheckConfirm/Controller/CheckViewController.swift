//
//  CheckViewController.swift
//  MyFirstGPUImage
//
//  Created by LiuYong on 2018/7/26.
//  Copyright © 2018年 LiuYong. All rights reserved.
//

import UIKit
import Photos
import ProgressHUD
import PhotosUI
import MobileCoreServices

struct FilePaths {
    //LivePhoto 路径
    static let documentsPath : AnyObject = NSSearchPathForDirectoriesInDomains(.cachesDirectory,.userDomainMask,true)[0] as AnyObject
    struct VidToLive {
        static var livePath = FilePaths.documentsPath.appending("/")
    }
}


class CheckViewController: UIViewController {
    
    var refVc:FConViewController!
    
    //UI
    lazy var saveButton:UIButton = {
        let widthofme:CGFloat = 35
        var btn = UIButton()
       //btn.backgroundColor = UIColor.blue
        btn.setImage(UIImage.init(named: "下载"), for: .normal)
        btn.setBackgroundImage(#imageLiteral(resourceName: "下载"), for: .normal)
        // btn.setImage(#imageLiteral(resourceName: "下载"), for: .normal)
        btn.addTarget(self, action: #selector(self.savePhoto), for: .touchUpInside)
        return btn
    }()
    //返回按钮
    lazy var backButton:UIButton = {
        var btn = NewUIButton()
        btn.setImage(#imageLiteral(resourceName: "imageback") , for: .normal)
        btn.setTitle("返回", for: .normal)
        btn.setTitleColor(UIColor.black, for: .normal)
        btn.addTarget(self, action: #selector(self.back), for: .touchUpInside)
        return btn
    }()
    //   滤镜选择按钮
    lazy var filterButton:UIButton = {
        var btn = NewUIButton()
        btn.setImage(#imageLiteral(resourceName: "滤镜") , for: .normal)
        btn.setTitle("风格滤镜", for: .normal)
        btn.setTitleColor(UIColor.black, for: .normal)
        btn.addTarget(self, action: #selector(self.changeFilter), for: .touchUpInside)
        return btn
    }()
    //滤镜页面
    lazy var cameraFilterView:FillterSelectView = {
        let v = FillterSelectView()
        
        v.filterDelegate = self
        return v
    }()
    lazy var defaultBottomView:UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.clear
        
        return v
    }()
    //照片页面
    lazy var photoView:UIImageView = {
        let v = UIImageView()
        v.image = image
        //v.contentMode = .center
        v.contentMode = .scaleAspectFit
        
        
        return v
    }()
    //视频预览
    lazy var playView:VideoPlayView = {
        let v = VideoPlayView()
        return v
    }()
    
    //LivePhoto预览
    lazy var livePhotoView: FDLivePhotoView =  {
        let v = FDLivePhotoView()
        return v
    }()
    
    //展示类型
    //0:image,1:video,2:livePhoto
    var type:Int!
    
    //视频地址
    var videoUrl:URL?
    
    //属性
    var image:UIImage?
    var imageNormal:UIImage!
    //图片分辨率
    var fixel:Int?
    var videoScale:Int?
    var willDismiss:(()-> Void)? = nil
    //滤镜
    var ifFilter: (GPUImageOutput & GPUImageInput)?
    var filterIndex:Int = 0
    //视频
    var movieWriter:GPUImageMovieWriter?
    var movieFile:GPUImageMovie?
    var moviePreview:GPUImageView?
    
    
    //MARK: - 初始化
    init(image:UIImage?,type:Int){
        self.type = type
        if image != nil{
            self.image = image
            self.imageNormal = image
            self.fixel = 0
        }
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
  
    convenience init(){
        self.init(image: nil, type: 1)
    }
    
    //MARK: - 生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        print(getImageSize())
        fixel = getImageSize().h
        setUI()
        changeImagePresent()
        
        // Do any additional setup after loading the view.
    }
    override func viewWillDisappear(_ animated: Bool) {
        playView.deadlloc()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        //检测用户使用次数，十次时候弹出好评弹窗
        if let time = UserDefaults.standard.value(forKey: "userTime"){
            let z = time as! Int
            if z > 10 && z < 1024{
                UpdateManager.presentCommentApp()
                UserDefaults.standard.set(1024, forKey: "userTime")
            }
        }
        
        
        if type == 1{
            setPreview()
            playView.play()
            //switchFillter(index: 0)
           //self.present(ViewController(), animated: true, completion: nil)
            //  setPreview()
        }else if type == 2{
            loadVideoWithVideoURL(videoUrl!)
        }

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let block =  cameraFilterView.mb{
            UIView.animate(withDuration: 0.3, animations: {
                block()
                self.view.layoutIfNeeded()
            })
        }
    }
    
    
    
}



// MARK: - UI布局和初始化
extension CheckViewController{
    
    // UI布局
    private func setUI(){
        view.backgroundColor = UIColor.clear
        photoView.backgroundColor = UIColor.clear
        
        let back = UIImageView(frame: CameraModeManage.shared.currentBackImageView.frame)
        back.image =  CameraModeManage.shared.currentBackImageView.image
        view.addSubview(back)
        view.addSubview(photoView)
        view.addSubview(defaultBottomView)
        view.addSubview(saveButton)
        view.addSubview(backButton)
        view.addSubview(filterButton)
        view.addSubview(cameraFilterView)
        photoView.frame = refVc.mGpuimageView.frame;
        defaultBottomView.frame = refVc.defaultBottomView.frame;
        

        
//        photoView.snp.makeConstraints({
//            make in
//            make.top.width.equalToSuperview()
//            make.height.equalTo(SCREEN_HEIGHT*3/4)
//        })
//        defaultBottomView.snp.makeConstraints({
//            make in
//            make.left.equalToSuperview()
//            make.bottom.equalToSuperview()
//            make.width.equalToSuperview()
//            make.height.equalTo(SCREEN_HEIGHT*1/4)
//        })
        cameraFilterView.snp.makeConstraints({
            make in
            make.top.equalTo(SCREEN_HEIGHT)
            make.width.equalToSuperview()
            make.height.equalTo(SCREEN_HEIGHT*1/4)
        })
        let widthOfShot:CGFloat = 70
        saveButton.snp.makeConstraints({
            make in
            make.center.equalTo(defaultBottomView)
            make.width.height.equalTo(widthOfShot)
        })
        backButton.snp.makeConstraints({
            make in
            make.centerY.equalTo(saveButton).offset(10)
            make.width.height.equalTo(70)
            make.left.equalToSuperview().offset(20)
        })
        filterButton.snp.makeConstraints({
            (make) in
            make.centerY.equalTo(saveButton).offset(10)
            make.width.height.equalTo(70)
            make.right.equalToSuperview().offset(-20)
        })
        if self.videoUrl != nil {
           // setPreview()
           // filterButton.isHidden = true
            moviePreview?.fillMode = kGPUImageFillModeStretch
        }else{
        }
    }
    
    
    /// 获取图片像素
    ///
    /// - Returns: 像素元组
    func getImageSize()->(w:Int,h:Int){
        guard let fixelW = image?.cgImage?.width else{return (0,0)}
        guard let fixelH = image?.cgImage?.height else{return (0,0)}
        //  let fx  = movieFile?.
        
        return (fixelW,fixelH)
    }
    
    
    /// 解决图片显示旋转问题
    func changeImagePresent(){
//        if fixel == 1280{
//            photoView.snp.remakeConstraints({
//                make in
//                make.top.left.bottom.width.equalToSuperview()
//            })
//            self.view.layoutIfNeeded()
//            self.defaultBottomView.isHidden = true
//        }else{
//            photoView.contentMode = .scaleAspectFill
//            photoView.snp.remakeConstraints({
//                make in
//                make.top.left.width.equalToSuperview()
//                make.height.equalTo(SCREEN_HEIGHT*3/4)
//            })
//            self.view.layoutIfNeeded()
//        }
    }
    
    
    //创建视频预览页面
    func setPreview(){
        //带声音的视频播放
        playView.videoUrl = videoUrl
        //
        //初始化滤镜页面
        moviePreview = GPUImageView()
        
        //movieFile  = GPUImageMovie.init(url:videoUrl)
        movieFile = GPUImageMovie.init(playerItem: playView.playerItem!)
        movieFile?.playAtActualSpeed = false
        //movieFile?.addTarget(ifFilter)
        movieFile?.addTarget(moviePreview)
        moviePreview?.backgroundColor = UIColor.clear
        self.view.addSubview(moviePreview!)
        
        if videoScale == 0{
            moviePreview?.snp.makeConstraints({
                make in
                make.top.left.width.equalToSuperview()
                make.height.equalTo(SCREEN_HEIGHT*3/4)
            })
        }else{
            moviePreview?.snp.makeConstraints({
                make in
                make.top.left.width.height.equalToSuperview()
            })
            //将该view加到最后面
            self.view.sendSubview(toBack: moviePreview!)
            moviePreview?.contentMode = .scaleAspectFill
            self.defaultBottomView.backgroundColor = UIColor.clear
        }
        
        movieFile?.startProcessing()
        movieFile?.shouldRepeat = true
    }
    
    
    //MARK: 按钮点击
    //切换滤镜
    @objc func changeFilter(){
        //let centerBottom = cameraFilterView.center
        //let centerReset = defaultBottomView.center
        weak var weakSelf  = self
        //底部View做动画平移
        UIView.animate(withDuration: 0.2, animations: {
            weakSelf?.cameraFilterView.snp.remakeConstraints({
                make in
                make.width.height.top.left.equalTo((weakSelf?.defaultBottomView)!)
            })
            weakSelf?.view.layoutIfNeeded()
        })
        cameraFilterView.mb = {
            weakSelf?.cameraFilterView.snp.remakeConstraints({
                make in
                make.left.equalToSuperview()
                make.top.equalTo(SCREEN_HEIGHT)
                make.width.equalToSuperview()
                make.height.equalTo(SCREEN_HEIGHT*1/4)
            })
            weakSelf?.view.layoutIfNeeded()
        }
    }
    //返回按钮
    @objc func back(){
        //触发返回闭包
        if self.willDismiss != nil{
            willDismiss!()
        }
        playView.pause()
        playView.player = nil
        self.dismiss(animated: false, completion: nil)
    }
    //保存图片
    @objc func  savePhoto(){
        //询问申请权限
        let authStatus = PHPhotoLibrary.authorizationStatus()
        if authStatus == .notDetermined{
            PHPhotoLibrary.requestAuthorization({
                status in
                if status == PHAuthorizationStatus.authorized{
                    print("同意")
                }else{
                    print("不同意")
                }
            })
        }else if (authStatus == .authorized ){
            ProgressHUD.show("保存中")
            if type ==  0{
                UIImageWriteToSavedPhotosAlbum(image!, nil, nil, nil)
                ProgressHUD.showSuccess("保存成功")
                self.dismiss(animated: false, completion: nil)
            }else if type == 1{
                //如果没有传图片，进入此方法存储视频
                 stopEc(false)
                //finishEdit()
            }else if type == 2{
                 self.stopEc(true)
            }
            
        }else{
            let alertController = UIAlertController(title: "提示", message: "您已经关闭相册权限，该功能无法使用，请点击系统设置设置", preferredStyle: .alert)
            
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
    
    
    /// 文件存储函数
    ///
    /// - Parameter isLivePhoto: true表示存储LivePhoto，false表示存储视频
    func stopEc(_ isLivePhoto:Bool){
        movieFile = GPUImageMovie(url: videoUrl)
        //重新初始化滤镜，去掉不必要的链条
        ifFilter = FilterGroup.shared.currentFilter.filter
        let pixellateFilter = ifFilter ?? GPUImageFilter()
        //movie添加滤镜链
        movieFile?.addTarget(pixellateFilter as! GPUImageInput)
        let pathToMovie = URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("Documents/Movie.m4v")
       //创建新路径存储渲染后的视频
        unlink(pathToMovie.path)
        let movieURL = URL(fileURLWithPath: pathToMovie.path)
        //初始化Write
        movieWriter = GPUImageMovieWriter(movieURL: movieURL, size: CGSize(width: 480.0, height: 640.0))
        pixellateFilter.addTarget(movieWriter)
        movieWriter?.shouldPassthroughAudio = true
        movieFile?.audioEncodingTarget = movieWriter
        movieFile?.enableSynchronizedEncoding(using: movieWriter)
        //开始录制，开始渲染
        movieWriter?.startRecording()
        movieFile?.startProcessing()
        //成功回调
        
        weak var weakSelf = self
        movieWriter?.completionBlock = {
            pixellateFilter.removeTarget(weakSelf?.movieWriter)
            weakSelf?.movieWriter?.finishRecording()
            print("done")
            if isLivePhoto{
                //调用livePhoto存储方法
               weakSelf?.exportLivePhoto(videoURL: movieURL)
            }else{
                UISaveVideoAtPathToSavedPhotosAlbum((movieURL.path), self,#selector(self.saveVideo(videoPath:didFinishSavingWithError:contextInfo:)), nil)
            }
        }
        //失败回调
        movieWriter?.failureBlock = {
            error in
            print(error ?? "")
            ProgressHUD.showError("保存失败")
            pixellateFilter.removeTarget(self.movieWriter)
            self.movieWriter?.finishRecording()
        }

        
    }
    
    
    @objc  func saveVideo(videoPath:String,didFinishSavingWithError:NSError,contextInfo info:AnyObject){
        print(didFinishSavingWithError.code)
        if didFinishSavingWithError.code == 0{
            print("success！！！！！！！！！！！！！！！！！")
            //print(info)
            ProgressHUD.showSuccess("保存成功")
            self.dismiss(animated: true, completion: nil)
        }else{
            ProgressHUD.showError("保存失败")
        }
        
    }
    
    
    
    
    
}


// MARK: - 切换滤镜
extension CheckViewController:FillterSelectViewDelegate{
    
    /// 切换滤镜
    ///
    /// - Parameter index: 滤镜代码
    func switchFillter(index: Int) {
        filterIndex = index
        ifFilter =  FilterGroup.shared.getFilterWithIndex(index: index).filter;
        if image != nil{
            //GPUImageFilterGroup的实例对象有这样的方法返回UIimage对象
            image =  ifFilter?.image(byFilteringImage:imageNormal )
            //主线程修改image
            DispatchQueue.main.async {
                self.photoView.image = self.image
            }
        }else if type == 1{
            // movieFile = GPUImageMovie.init(url: videoUrl)
            movieFile?.shouldRepeat = true
            movieFile?.runBenchmark = false
            movieFile?.playAtActualSpeed = true
            movieFile?.cancelProcessing()
            movieFile?.removeAllTargets()
            ifFilter?.removeAllTargets()
            movieFile?.addTarget(ifFilter)
            ifFilter?.addTarget(moviePreview)
            movieFile?.startProcessing()
        
        }else if type == 2{
            //渲染视频
            movieFile?.cancelProcessing()
            movieFile?.removeAllTargets()
            ifFilter?.removeAllTargets()
            movieFile?.addTarget(ifFilter)
            ifFilter?.addTarget(livePhotoView.videoPlayView)
            movieFile?.startProcessing()
            //渲染图片
            let asset = AVURLAsset(url: videoUrl!)
            let generator = AVAssetImageGenerator(asset: asset)
            generator.appliesPreferredTrackTransform = true
            let time = NSValue(time: CMTimeMakeWithSeconds(CMTimeGetSeconds(asset.duration)/2, asset.duration.timescale))
            generator.generateCGImagesAsynchronously(forTimes: [time]) { [weak self] _, image, _, _, _ in
                //生成livePhoto封面图
                if let image = image, let data = (self?.ifFilter?.image(byFilteringImage: UIImage(cgImage: image))!) {
                    DispatchQueue.main.async {
                        self?.livePhotoView.presentImageView.image = data
                    }
                }
            }
            
            
        }
    }
    
}
//MARK: - livePhoto
extension CheckViewController{
    
    
    @available(iOS 9.1, *)
    func loadVideoWithVideoURL(_ videoURL: URL) {
        
        self.view.addSubview(livePhotoView)
       
        if videoScale == 0{
            livePhotoView.snp.makeConstraints({
                make in
                make.width.left.top.height.equalTo(photoView)
            })
        }else{
            livePhotoView.snp.makeConstraints({
                make in
                make.top.left.width.height.equalToSuperview()
            })
            //将该view加到最后面
            self.view.sendSubview(toBack: livePhotoView)
            livePhotoView.contentMode = .scaleAspectFill
            self.defaultBottomView.backgroundColor = UIColor.clear
        }
        
        //带声音的视频播放
        playView.videoUrl = videoUrl
        //取消重复播放
        playView.removeNotification()
        //
        //初始化滤镜页面
        
        movieFile = GPUImageMovie.init(playerItem: playView.playerItem!)
        movieFile?.playAtActualSpeed = true
        movieFile?.addTarget(livePhotoView.videoPlayView)

        movieFile?.startProcessing()
        //设置长按点击的block，开始点击播放视频，放开时展示图片
        livePhotoView.stateBlock = {
            i in
            if i == 0{
                self.playView.play()
            }else{
                self.playView.pause()
            }
        }

        let asset = AVURLAsset(url: videoURL)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        let time = NSValue(time: CMTimeMakeWithSeconds(CMTimeGetSeconds(asset.duration)/2, asset.duration.timescale))
        generator.generateCGImagesAsynchronously(forTimes: [time]) { [weak self] _, image, _, _, _ in
            //生成livePhoto封面图
            if let image = image{
               self?.livePhotoView.setImage(image: UIImage(cgImage: image))

            }
        }
    }
    
    
    //保存为livePhoto
    func exportLivePhoto (videoURL:URL) {
        //print("看看是谁在这里")
        //获取当前展示的封面图
        if let image = self.livePhotoView.presentImageView.image?.cgImage, let data = UIImagePNGRepresentation(UIImage(cgImage: image)) {
            //为视频和图片分配url
            let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            let imageURL = urls[0].appendingPathComponent("image.jpg")
            try? data.write(to: imageURL, options: [.atomic])
            
            let image = imageURL.path
            let mov = videoURL.path
            let output = FilePaths.VidToLive.livePath
            let assetIdentifier = UUID().uuidString
            let _ = try? FileManager.default.createDirectory(atPath: output, withIntermediateDirectories: true, attributes: nil)
            do {
                try FileManager.default.removeItem(atPath: output + "/IMG.JPG")
                try FileManager.default.removeItem(atPath: output + "/IMG.MOV")
                
            } catch {
                
            }
            
            //写入图片
            JPEG(path: image).write(output + "/IMG.JPG",
                                    assetIdentifier: assetIdentifier)
            
            //写入视频
            QuickTimeMov(path: mov).write(output + "/IMG.MOV",assetIdentifier: assetIdentifier,filter: nil)
            //写为LivePhoto
            var inCounter = 1;
            PHLivePhoto.request(withResourceFileURLs: [ URL(fileURLWithPath: FilePaths.VidToLive.livePath + "/IMG.MOV"), URL(fileURLWithPath: FilePaths.VidToLive.livePath + "/IMG.JPG")],
                                placeholderImage: nil,
                                targetSize: self.view.bounds.size,
                                contentMode: PHImageContentMode.aspectFit,
                                resultHandler: { (livePhoto, info) -> Void in
                                    //ProgressHUD.showSuccess("对")
                                   // print("我在这里",inte)
                                    //防止多次保存
                                    if inCounter <= 1{
                                      self.saveAsLivePhoto()
                                    }
                                    inCounter += 1
            })
            
            
        }
        
    
    }
    
    
    /// 文件保存
    func saveAsLivePhoto(){
        
        print("okyes")

        PHPhotoLibrary.shared().performChanges({ () -> Void in
            let creationRequest = PHAssetCreationRequest.forAsset()
            let options = PHAssetResourceCreationOptions()
            
            creationRequest.addResource(with: PHAssetResourceType.pairedVideo, fileURL: URL(fileURLWithPath: FilePaths.VidToLive.livePath + "/IMG.MOV"), options: options)
            creationRequest.addResource(with: PHAssetResourceType.photo, fileURL: URL(fileURLWithPath: FilePaths.VidToLive.livePath + "/IMG.JPG"), options: options)
            
        }, completionHandler: { (success, error) -> Void in
            if !success {
                print((error?.localizedDescription)!)
                ProgressHUD.showError("保存失败")
                
            }else{
                ProgressHUD.showSuccess("保存成功")

                
            }
        })
    }
    

}
