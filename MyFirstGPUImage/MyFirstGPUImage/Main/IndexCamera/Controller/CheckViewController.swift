//
//  CheckViewController.swift
//  MyFirstGPUImage
//
//  Created by LiuYong on 2018/7/26.
//  Copyright © 2018年 LiuYong. All rights reserved.
//

import UIKit
import Photos


class CheckViewController: UIViewController {
    //UI
    lazy var saveButton:UIButton = {
        let widthofme:CGFloat = 50
        var btn = UIButton()
        btn.layer.cornerRadius = widthofme/2
        btn.setImage(#imageLiteral(resourceName: "确认") , for: .normal)
        btn.addTarget(self, action: #selector(self.savePhoto), for: .touchUpInside)
        return btn
    }()
    
    lazy var backButton:UIButton = {
        var btn = NewUIButton()
        btn.setImage(#imageLiteral(resourceName: "返回") , for: .normal)
       // btn.setTitle("返回", for: .normal)
        btn.setTitleColor(UIColor.black, for: .normal)
        btn.addTarget(self, action: #selector(self.back), for: .touchUpInside)
        return btn
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
    let image:UIImage!
   //图片分辨率
    var fixel:Int?
    var willDismiss:(()-> Void)? = nil

    //初始化
    init(image:UIImage){
        self.image = image
        self.fixel = 0
        super.init(nibName: nil, bundle: nil)
    }
    

    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        photoView.snp.makeConstraints({
            make in
            make.top.width.equalToSuperview()
            make.height.equalTo(SCREEN_HEIGHT*3/4)
        })
        defaultBottomView.snp.makeConstraints({
            make in
            make.bottom.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(SCREEN_HEIGHT*1/4)
        })
        
        let widthOfShot:CGFloat = 75
        saveButton.snp.makeConstraints({
            make in
            make.center.equalTo(defaultBottomView)
            make.width.height.equalTo(widthOfShot)
        })
        backButton.snp.makeConstraints({
            make in
            make.centerY.equalTo(saveButton).offset(20)
            make.width.height.equalTo(widthOfShot)
            make.left.equalToSuperview().offset(20)
        })
        
    }
    
    
    
    
    //按钮点击
    
    @objc func back(){
        
        if self.willDismiss != nil{
            willDismiss!()
        }
        
        
        self.dismiss(animated: false, completion: nil)
    }
    
 
    
    
    
    
}
extension CheckViewController:UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    
    
    //保存图片
    @objc func  savePhoto(){
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
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
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
