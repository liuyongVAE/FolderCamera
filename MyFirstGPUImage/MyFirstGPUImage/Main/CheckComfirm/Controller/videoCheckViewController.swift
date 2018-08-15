//
//  videoCheckViewController.swift
//  MyFirstGPUImage
//
//  Created by LiuYong on 2018/8/15.
//  Copyright © 2018年 LiuYong. All rights reserved.
//

import UIKit
import ProgressHUD
class videoCheckViewController: UIViewController {
    
    
    var movieFile: GPUImageMovie!
    //保存用
    var saveMovie: GPUImageMovie?
    //预览用的滤镜
    var filter: (GPUImageOutput & GPUImageInput)?
    //保存用的滤镜
    var savefilter: (GPUImageOutput & GPUImageInput)?
    var saveWrite: GPUImageMovieWriter?
    var filterView:GPUImageView!
    var url:URL!
    
    
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
    
    
    init(videoUrl:URL){
        url = videoUrl
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // unlink(url.path)
        movieFile = GPUImageMovie(url: url)
        //设置预览重复播放
        movieFile.shouldRepeat = true
        movieFile.runBenchmark = true
        //设置渲染速度与视屏播放速度一致
        movieFile.playAtActualSpeed = true
        //初始化磨皮滤镜
        filter = GPUImageBeautifyFilter()
        //原图
        filter = GPUImageBrightnessFilter()
        (filter as? GPUImageBrightnessFilter)?.brightness = 0
        savefilter = GPUImageBrightnessFilter()
        (savefilter as? GPUImageBrightnessFilter)?.brightness = 0
        //把滤镜添加到GPUImageMovie中
        movieFile.addTarget(filter)
        // Only rotate the video for display, leave orientation the same for recording
        //创建预览的GPUImageView并显示
        filterView = GPUImageView()
        // filterView.frame = CGRect(x: 0, y: 64, width: SCREEN_HEIGHT, height: SCREEN_WIDTH)
        //    filterView.transform = CGAffineTransformMakeRotation(90 * M_PI/180.0);
        view.addSubview(filterView)
        filterView.snp.makeConstraints({
            make in
            make.left.width.top.equalToSuperview()
            make.height.equalTo(SCREEN_HEIGHT*3/4)
        })
        // view.sendSubview(toBack: filterView)
        //把滤镜内容显示到预览中
        filter?.addTarget(filterView)
        //开始预览
        movieFile.startProcessing()
        view.addSubview(backButton)
        view.addSubview(saveButton)
        saveButton.snp.makeConstraints({
            make in
            make.center.equalToSuperview()
            make.width.height.equalTo(70)
        })
        backButton.snp.makeConstraints({
            make in
            make.centerY.equalTo(saveButton).offset(10)
            make.width.height.equalTo(70)
            make.left.equalToSuperview().offset(20)
        })
        //setUI()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        //        //触发返回闭包
        //        if self.willDismiss != nil{
        //            willDismiss!()
        //        }
        //        playView.pause()
        //        playView.player = nil
        self.dismiss(animated: false, completion: nil)
    }
    //保存图片
    @objc func  savePhoto(){
        
    }
    
    
    
    func finishEdit(){
        //        movieWriter = GPUImageMovieWriter.init(movieURL: videoUrl, size: CGSize(width:480, height: 640))
        
        
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
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

extension videoCheckViewController{
    // UI布局
    private func setUI(){
        view.addSubview(defaultBottomView)
        view.addSubview(saveButton)
        view.addSubview(backButton)
        view.addSubview(filterButton)
        view.addSubview(cameraFilterView)
        view.addSubview(backButton)

   
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
            make.width.left.equalToSuperview()
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

        }
    }
    
    
    func setPreview(){
    
    }
    



extension videoCheckViewController:FillterSelectViewDelegate{
    
    
    /// 切换滤镜
    ///
    /// - Parameter index: 滤镜代码
    func switchFillter(index: Int) {
//        ifFilter =  FilterGroup.getFillter(filterType: index)
//        if image != nil{
//            image =  ifFilter?.image(byFilteringImage:imageNormal )
//            //主线程修改image
//            DispatchQueue.main.async {
//                self.photoView.image = self.image
//            }
//        }else{
//            // movieFile = GPUImageMovie.init(url: videoUrl)
//            movieFile?.shouldRepeat = true
//            movieFile?.runBenchmark = true
//            movieFile?.playAtActualSpeed = false
//            movieFile?.cancelProcessing()
//            movieFile?.removeAllTargets()
//            ifFilter?.removeAllTargets()
//            movieFile?.addTarget(ifFilter)
//            ifFilter?.addTarget(moviePreview)
//            movieFile?.startProcessing()
//
//            //ifFilter?.removeTarget(writer)
//
//
//        }
   }

}

