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
    var willDismiss:(()-> Void)? = nil
    //滤镜
    var ifFilter:IFImageFilter?
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
            //playView.play()
            
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
    
    
    func setPreview(){
        //带声音的视频播放

        playView.videoUrl = videoUrl
        //
        //初始化滤镜页面
        //ifFilter = IFNormalFilter()
        moviePreview = GPUImageView()
        
       // movieFile  = GPUImageMovie.init(playerItem: playView.playerItem!)
        movieFile  = GPUImageMovie.init(playerItem: playView.playerItem!)

        //playView.play()
       //movieFile?.runBenchmark = true
        movieFile?.playAtActualSpeed = false
        //movieFile?.addTarget(ifFilter)
        movieFile?.addTarget(moviePreview)
        
        self.view.addSubview(moviePreview!)
        moviePreview?.snp.makeConstraints({
            make in
            make.top.left.width.equalToSuperview()
            make.height.equalTo(SCREEN_HEIGHT*3/4)
        })
        //moviePreview?.backgroundColor = UIColor.blue
        //ifFilter?.addTarget(moviePreview)
        //movieWriter = GPUImageMovieWriter.init(movieURL: videoUrl, size: CGSize(width:480, height: 640))
        //movieWriter?.startRecording()
        movieFile?.startProcessing()
        movieFile?.shouldRepeat = true
      
        //movieWriter?.finishRecording()
        //ifFilter?.removeTarget(movieWriter)
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
                finishEdit()
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
    
    
    
    func finishEdit(){
    
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let videopath = paths[0].appendingPathComponent("TmpVideo.mp4")
        try? FileManager.default.removeItem(at: videopath)
        
        movieFile = GPUImageMovie(url: videoUrl)
        movieFile?.shouldRepeat = false
        movieFile?.playAtActualSpeed = true
        let url2 = videopath
            //URL(fileURLWithPath: "\(NSTemporaryDirectory())folder_video.mp4")
        //unlink(url2.path)
        movieWriter = GPUImageMovieWriter.init(movieURL: url2, size: CGSize(width:480, height: 640))
        movieWriter?.encodingLiveVideo = false
        movieWriter?.shouldPassthroughAudio = false
        movieFile?.addTarget(ifFilter)
        ifFilter?.addTarget(movieWriter)
        movieFile?.enableSynchronizedEncoding(using: movieWriter)
        movieWriter?.startRecording()
        movieFile?.startProcessing()
        weak var weakSelf = self
        movieWriter?.completionBlock = {
            print("OK")
            weakSelf?.movieWriter?.finishRecording()
            weakSelf?.ifFilter?.removeTarget(weakSelf?.movieWriter)
        }
        movieWriter?.completionBlock()
        
    
        let when  = DispatchTime.now() + 0.1
        DispatchQueue.main.asyncAfter(deadline: when, execute: {
            //weakSelf?.ifFilter?.removeTarget(weakSelf?.movieWriter)
            
            if UIVideoAtPathIsCompatibleWithSavedPhotosAlbum((url2.path)){
                UISaveVideoAtPathToSavedPhotosAlbum((url2.path), self,#selector(weakSelf?.saveVideo(videoPath:didFinishSavingWithError:contextInfo:)), nil)
            }
            
            
        })
        
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
            movieFile?.runBenchmark = true
            movieFile?.playAtActualSpeed = false
            movieFile?.cancelProcessing()
            movieFile?.removeAllTargets()
            ifFilter?.removeAllTargets()
            movieFile?.addTarget(ifFilter)
            ifFilter?.addTarget(moviePreview)
            movieFile?.startProcessing()
          
            
            
            //           let filterView = GPUImageView()
            //            self.view.addSubview(filterView)
            //            filterView.snp.makeConstraints({
            //                    make in
            //                    make.top.width.equalToSuperview()
            //                    make.height.equalTo(SCREEN_HEIGHT*3/4)
            //                })
            //            unlink(videoUrl?.path)
            //            movieWriter?.startRecording()
            //            movieFile?.startProcessing()
            //            movieFile?.shouldRepeat = true
            //            movieWriter?.finishRecording()
            //            ifFilter?.removeTarget(movieWriter)
            // movieWriter
            //let writer = GPUImageMovieWriter.init(movieURL: videoUrl, size: CGSize(width:480, height: 640))
            //writer?.startRecording()
            //  movieFile?.shouldRepeat = true
            // writer?.finishRecording()
            //ifFilter?.removeTarget(writer)
            
            
        }
    }
    
    
    
    
    
}
