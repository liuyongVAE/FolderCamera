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
    
    lazy var photoView:UIImageView = {
        let v = UIImageView()
        v.image = image
        //v.contentMode = .center
        v.contentMode = .scaleAspectFit
        
        return v
    }()
    
    //属性
    var image:UIImage!
    var imageNormal:UIImage!
   //图片分辨率
    var fixel:Int?
    var willDismiss:(()-> Void)? = nil
    //滤镜
    var ifFilter:IFImageFilter?

    //初始化
    init(image:UIImage){
        self.image = image
        self.imageNormal = image
        self.fixel = 0
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /// 获取图片像素
    ///
    /// - Returns: 像素元组
    func getImageSize()->(w:Int,h:Int){
        guard let fixelW = image.cgImage?.width else{return (0,0)}
        guard let fixelH = image.cgImage?.height else{return (0,0)}
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
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            ProgressHUD.showSuccess("保存成功")
            self.dismiss(animated: false, completion: nil)
            
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
  
    
}
extension CheckViewController:FillterSelectViewDelegate{
  
    
    /// 切换滤镜
    ///
    /// - Parameter index: 滤镜代码
    func switchFillter(index: Int) {
        ifFilter =  FilterGroup.getFillter(filterType: index)
        image =  ifFilter?.image(byFilteringImage:imageNormal )
        //主线程修改image
        DispatchQueue.main.async {
            self.photoView.image = self.image
        }
    }
    
 
    
}
