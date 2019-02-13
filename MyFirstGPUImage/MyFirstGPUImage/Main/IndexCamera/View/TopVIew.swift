//
//  topVIew.swift
//  MyFirstGPUImage
//
//  Created by LiuYong on 2018/8/10.
//  Copyright © 2018年 LiuYong. All rights reserved.
//

import Foundation
import UIKit
import ProgressHUD

protocol topViewDelegate{
    func  turnScale()
    func  turnCamera()
    func  flashMode()
    func  liveMode()
    func  push(_ vc:UIViewController)
}


class TopView: UIView {
    
    let widthofme:CGFloat = 50
    //MARK: - lazy loading
    //  转换摄像头
    lazy var turnCameraButton:UIButton = {
        var btn = UIButton()
        btn.layer.cornerRadius = widthofme/2
        btn.setImage(#imageLiteral(resourceName: "转换"), for: .normal)
        btn.addTarget(self, action: #selector(self.turnCamera(_:)), for: .touchUpInside)
        return btn
    }()
    //    转换拍照比例
    lazy var turnScaleButton:UIButton = {
        var btn = NewUIButton()
        btn.layer.cornerRadius = widthofme/2
        btn.setImage(#imageLiteral(resourceName: "屏幕比例"), for: .normal)
        btn.setTitle("比例切换", for: .normal)
        btn.addTarget(self, action: #selector(turnScale), for: .touchUpInside)
        return btn
    }()
    lazy var flashButton:UIButton = {
        var btn = UIButton()
        btn.layer.cornerRadius = widthofme/2
        btn.setImage(#imageLiteral(resourceName: "闪光灯关闭"), for: .normal)

        btn.addTarget(self, action: #selector(self.flashMode(btn:)), for: .touchUpInside)
        
        return btn
    }()
    
    lazy var liveButton:UIButton = {
        var btn = UIButton()
        btn.layer.cornerRadius = widthofme/2
        btn.setImage(#imageLiteral(resourceName: "live"), for: .normal)
        btn.setImage(#imageLiteral(resourceName: "live1"), for: .selected)
        btn.addTarget(self, action: #selector(self.liveMode(_:)), for: .touchUpInside)
        
        return btn
    }()
    
    
    lazy var moreButton:UIButton = {
        var btn = UIButton()
        btn.layer.cornerRadius = widthofme/2
        btn.setImage(#imageLiteral(resourceName: "更多"), for: .normal)
        btn.addTarget(self, action: #selector(touchMore), for: .touchUpInside)
        
        return btn
    }()
    
    lazy var liveCounter:UILabel = {
        var btn = UILabel()
        btn.textColor = UIColor.white
        return btn
    }()
    
    lazy var popSetting:CallSettingView = {
        var btn = CallSettingView(frame: CGRect.zero)
       // btn.textColor = UIColor.white
        return btn
    }()
    
    lazy var settingButton:UIButton = {
        var btn = NewUIButton()
        btn.layer.cornerRadius = widthofme/2
        btn.setImage(#imageLiteral(resourceName: "设置"), for: .normal)
        btn.setTitle("设置", for: .normal)
        btn.addTarget(self, action: #selector(self.push), for: .touchUpInside)
        return btn
    }()
    
    lazy var AI_fillterButton:UIButton = {
        var btn =  UIButton()
        btn.layer.cornerRadius = widthofme/2
        btn.setImage(UIImage.init(named: "AI滤镜开"), for: .normal)
        btn.setImage(UIImage.init(named: "AI滤镜关"), for: .selected)
        btn.addTarget(self, action: #selector(self.push), for: .touchUpInside)
        return btn
    }()
    
    
    //Propoty，按钮点击的代理
    
    var delegate:topViewDelegate?
    
    var upView:UIView?
    
    init(upView:UIView) {
        super.init(frame: CGRect.zero)
        self.addSubview(flashButton)
        self.addSubview(liveButton)
        self.addSubview(AI_fillterButton)
        self.addSubview(turnCameraButton)
        let widthOfTop:CGFloat = 26
        
        turnCameraButton.snp.makeConstraints({
            make in
            make.width.height.equalTo(widthOfTop)
            make.right.equalToSuperview().offset(-15)
            make.top.equalTo(topFix*2+11)
        })
        
        
        liveButton.snp.makeConstraints({
            make in
            make.width.height.equalTo(widthOfTop)
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(topFix*2+11)
            
        })
        
        AI_fillterButton.snp.makeConstraints({
            make in
            make.width.height.equalTo(widthOfTop)
            make.right.equalTo(self.turnCameraButton.snp.right).offset(-61)
            make.top.equalToSuperview().offset(topFix*2+11)
        })
        
        flashButton.snp.makeConstraints({
            make in
            make.width.height.equalTo(widthOfTop)
            make.left.equalToSuperview().offset(15)
            make.top.equalTo(topFix*2+11)
        })
        

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
  
    
    
    //老页面，保留
    func remakeTopView(){
        self.backgroundColor = UIColor.clear
        self.addSubview(turnCameraButton)
        self.addSubview(turnScaleButton)
        self.addSubview(liveButton)
        self.addSubview(liveCounter)
        //self.addSubview(popSetting)
        self.addSubview(moreButton)
        
        let widthOfTop:CGFloat = 26
        
        turnCameraButton.snp.makeConstraints({
            make in
            make.width.height.equalTo(widthOfTop)
            make.right.equalToSuperview().offset(-15)
            make.top.equalToSuperview().offset(11)
        })
        
        
        liveButton.snp.makeConstraints({
            make in
            make.width.height.equalTo(widthOfTop)
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(11)
            
        })
        liveCounter.snp.makeConstraints({
            make in
            make.width.height.equalTo(widthOfTop)
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(11)
            
        })
        moreButton.snp.makeConstraints({
            make in
            make.width.height.equalTo(widthOfTop)
            make.left.equalToSuperview().offset(20)
            make.top.equalToSuperview().offset(11)
        })
        
        
        //更多页面
        self.addSubview(popSetting)
        popSetting.addSubview(flashButton)
        popSetting.addSubview(turnScaleButton)
        popSetting.addSubview(settingButton)
        
        
        popSetting.snp.makeConstraints({
            make in
            make.height.equalTo(widthOfTop*4)
            make.width.equalTo(250)
            make.left.equalToSuperview().offset(-80)
            make.top.equalToSuperview().offset(-10)
            
        })
        flashButton.snp.makeConstraints({
            make in
            make.width.height.equalTo(widthOfTop+30)
            make.left.equalToSuperview().offset(15)
            make.centerY.equalToSuperview().offset(-5)
        })
        
        turnScaleButton.snp.makeConstraints({
            make in
            make.width.height.equalTo(widthOfTop+30)
            make.left.equalTo(flashButton.snp.right).offset(15)
            make.centerY.equalToSuperview().offset(-5)
        })
        
        settingButton.snp.makeConstraints({
            make in
            make.width.height.equalTo(widthOfTop+30)
            make.left.equalTo(turnScaleButton.snp.right).offset(15)
            make.centerY.equalToSuperview().offset(-5)
        })
        
    }
    

    
    
    //按钮点击
    
    @objc func turnScale(){
        delegate?.turnScale()
    }
    
    @objc func flashMode(btn:UIButton){
        btn.isSelected = !btn.isSelected
        delegate?.flashMode()
    }

    @objc func turnCamera(_ btn:UIButton){
        delegate?.turnCamera()
    }
    @objc func push(){
        delegate?.push(SettingViewController())
        popSetting.close()
    }
    @objc func liveMode(_ btn:UIButton){
        
        let deviceName = UIDevice.current.modelName
        if deviceName == "iPhone 5c" || deviceName == "iPhone 5s" || deviceName == "iPhone 4s" || deviceName == "iPhone "{
            ProgressHUD.showError("当前设备不支持LivePhoto")
        }else{
            btn.isSelected = !btn.isSelected
            delegate?.liveMode()
        }
    }
    
    
    @objc func touchMore(){
        moreButton.isSelected = !moreButton.isSelected

        if moreButton.isSelected{
            popSetting.open()
        }else{
            popSetting.close()
        }

    }
    
    func setCounter(text:String){
        DispatchQueue.main.async {
            self.liveCounter.text = text
        }
    }
    
    
}
