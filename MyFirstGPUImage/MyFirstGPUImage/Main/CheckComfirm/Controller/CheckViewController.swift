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

class CheckViewController: UIViewController {
    //UI
    lazy var saveButton:UIButton = {
        let widthofme:CGFloat = 35
        var btn = UIButton()
        btn.setImage(#imageLiteral(resourceName: "下载"), for: .normal)
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
        v.backgroundColor = UIColor.white
        
        v.filterDelegate = self
        return v
    }()
    lazy var defaultBottomView:UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white
        
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
    var ifFilter:GPUImageFilterGroup?
    var filterIndex:Int = 0
    //视频
    var movieWriter:GPUImageMovieWriter?
    var movieFile:GPUImageMovie?
    var moviePreview:GPUImageView?
    
    
    //初始化
    init(image:UIImage?){
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
        self.init(image: nil)
    }
    

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
        if image == nil{
            setPreview()
            playView.play()
            
            //switchFillter(index: 0)
           //self.present(ViewController(), animated: true, completion: nil)
            //  setPreview()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        if fixel == 1280{
            photoView.snp.remakeConstraints({
                make in
                make.top.left.bottom.width.equalToSuperview()
            })
            self.view.layoutIfNeeded()
            self.defaultBottomView.isHidden = true
        }else{
            photoView.contentMode = .scaleAspectFill
            photoView.snp.remakeConstraints({
                make in
                make.top.left.width.equalToSuperview()
                make.height.equalTo(SCREEN_HEIGHT*3/4)
            })
            self.view.layoutIfNeeded()
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

extension CheckViewController{
    
    // UI布局
    private func setUI(){
        view.backgroundColor = UIColor.clear
        photoView.backgroundColor = UIColor.clear
        view.addSubview(photoView)
        view.addSubview(defaultBottomView)
        view.addSubview(saveButton)
        view.addSubview(backButton)
        view.addSubview(filterButton)
        view.addSubview(cameraFilterView)
        
        photoView.snp.makeConstraints({
            make in
            make.top.width.equalToSuperview()
            make.height.equalTo(SCREEN_HEIGHT*3/4)
        })
        defaultBottomView.snp.makeConstraints({
            make in
            make.left.equalToSuperview()
            make.bottom.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(SCREEN_HEIGHT*1/4)
        })
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
        }
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
            moviePreview?.contentMode = .scaleToFill
            self.defaultBottomView.backgroundColor = UIColor.clear
        }
        
        movieFile?.startProcessing()
        movieFile?.shouldRepeat = true
    }
    
    
    //MARK: - 按钮点击
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
            if image != nil{
                UIImageWriteToSavedPhotosAlbum(image!, nil, nil, nil)
                ProgressHUD.showSuccess("保存成功")
                self.dismiss(animated: false, completion: nil)
            }else{
                //如果没有传图片，进入此方法存储视频
                 stopEc()
                //finishEdit()
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
    func stopEc(){
        movieFile = GPUImageMovie(url: videoUrl)
        //重新初始化滤镜，去掉不必要的链条
        ifFilter = FilterGroup.getFillter(filterType: filterIndex)
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
            UISaveVideoAtPathToSavedPhotosAlbum((movieURL.path), self,#selector(self.saveVideo(videoPath:didFinishSavingWithError:contextInfo:)), nil)
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
extension CheckViewController:FillterSelectViewDelegate{
    
    /// 切换滤镜
    ///
    /// - Parameter index: 滤镜代码
    func switchFillter(index: Int) {
        filterIndex = index
        ifFilter =  FilterGroup.getFillter(filterType: index)
        if image != nil{
            image =  ifFilter?.image(byFilteringImage:imageNormal )
            //主线程修改image
            DispatchQueue.main.async {
                self.photoView.image = self.image
            }
        }else{
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
        
            
        }
    }
    
    
    
    
    
}
