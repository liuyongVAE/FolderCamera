 //
//  DefaultBotomView.swift
//  MyFirstGPUImage
//
//  Created by LiuYong on 2018/7/26.
//  Copyright © 2018年 LiuYong. All rights reserved.
//

import UIKit
import SnapKit



protocol DefaultBottomViewDelegate{
    func changeFillter()
    func beauty()
    func pushVideo(isRecord:Bool)
    //长视频按钮
    func finishLongVideoRecord()
    func deletePrevious()
    
}


class DefaultBotomView: UIView {
    
    //MARK: - lazy loading
//   滤镜选择按钮
    lazy var fillterButton:UIButton = {
        var btn = CameraModeManage.shared.currentFilterButton
        btn.addTarget(self, action: #selector(self.changeFillter), for: .touchUpInside)
        return btn
    }()
//  美颜按钮
    lazy var beautyButton:UIButton = {
        //CGRect(x:SCREEN_WIDTH - getWidth(109) - getWidth(78), y: getHeight(150), width:getWidth(78) , height: getHeight(154))
        var btn = UIButton()
        btn.setImage(#imageLiteral(resourceName: "美颜1"), for: .normal)
        btn.setImage(#imageLiteral(resourceName: "美颜2"), for: .selected)
        btn.setTitleColor(UIColor.black, for: .normal)
        
        btn.addTarget(self, action: #selector(self.beauty), for: .touchUpInside)
        return btn
    }()
//  视频按钮
    lazy var videoButton:UIButton = {
        //CGRect(x:SCREEN_WIDTH - getWidth(109) - getWidth(78), y: getHeight(150), width:getWidth(78) , height: getHeight(154))
        var btn = UIButton()
        btn.setTitle("录制", for: .normal)
        btn.setTitleColor(UIColor.black, for: .normal)
        //btn.addTarget(self, action: #selector(self.pushVideo), for: .touchUpInside)
        return btn
    }()
    
    //长视频录制
    lazy var recordButton:UIButton = {
        let button = UIButton()
        button.setTitle("视频", for: .normal)
        button.setTitle("取消录制", for: .selected)
        button.setTitleColor(naviColor, for: .selected)
        button.setTitleColor(UIColor.black, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
       // button.addTarget(self, action: #selector(startLongRecord), for: .touchUpInside)
        return button
    }()
    lazy var finishButton:UIButton = {
        var btn = NewUIButton()
        btn.setImage(#imageLiteral(resourceName: "next"), for: .normal)
        btn.setTitle("完成录制", for: .normal)
        btn.setTitleColor(UIColor.black, for: .normal)
        btn.addTarget(self, action: #selector(self.finishRecord), for: .touchUpInside)
        return btn
    }()
    
    lazy var deletePreviousButton:UIButton = {
        var btn = NewUIButton()
        btn.setImage(#imageLiteral(resourceName: "删除"), for: .normal)
        btn.setTitle("删除上段", for: .normal)
        btn.setTitleColor(UIColor.black, for: .normal)
        btn.addTarget(self, action: #selector(self.deletePrevious), for: .touchUpInside)
        return btn
    }()
    
    lazy var recordBackView:UIView = {
        let b = UIView()
        b.isHidden = true
        b.backgroundColor = UIColor.white
        return b
    }()
    
    lazy var selectionView:SelectionView = {
        let v = SelectionView.init(frame: CGRect.init(x: 0, y: 0, width: 505, height: 40), titles: ["映画模式","人像","风景","美食","胶片"], parentViewController: nil)
        v.delegate = self
        return v
    }()
    
    
    //Propoty，按钮点击的代理
    
    var delegate:DefaultBottomViewDelegate?
    


    init() {
    
        super.init(frame: CGRect.zero)
        self.backgroundColor = UIColor.white
        self.addSubview(beautyButton)
        self.addSubview(fillterButton)
        self.addSubview(videoButton)
        //self.addSubview(recordButton)
        self.addSubview(finishButton)
        self.addSubview(deletePreviousButton)
        self.addSubview(recordBackView)
        self.addSubview(selectionView)
        self.backgroundColor = UIColor.clear

        let topMagin = 49+topFix
        
        fillterButton.snp.makeConstraints({
            (make) in
            make.top.equalTo(topMagin)
            make.width.height.equalTo(49)
            make.right.equalToSuperview().offset(-30)
            
        })
        beautyButton.snp.makeConstraints({
            (make) in
            make.top.equalTo(topMagin)
            make.width.height.equalTo(32)
            make.left.equalToSuperview().offset(36)
        })
       videoButton.snp.makeConstraints({
            (make) in
            make.centerX.equalToSuperview()
            make.width.height.equalTo(44)
            make.bottom.equalToSuperview().offset(52)
        })
//        recordButton.snp.makeConstraints({
//            make in
//            make.centerX.equalToSuperview()
//            make.height.equalTo(25)
//            make.centerY.equalTo(self.snp.bottom).offset(-25)
//        })
        recordBackView.snp.makeConstraints({
           make in
           make.width.height.left.top.equalToSuperview()
           //make.top.equalTo(self.snp.bottom)
        })
        
        finishButton.snp.makeConstraints({
            make in
            make.centerY.equalToSuperview()
            make.width.height.equalTo(49)
            make.right.equalToSuperview().offset(-10)
        })
        
        deletePreviousButton.snp.makeConstraints({
            make in
            make.centerY.equalToSuperview()
            make.width.height.equalTo(49)
            make.left.equalToSuperview().offset(10)
        })
        
        selectionView.snp.makeConstraints({
            make in
            make.centerX.equalToSuperview()
            make.top.equalTo(0)
            make.width.equalToSuperview()
            make.height.equalTo(60)
            
        })

        finishButton.alpha = 0
        deletePreviousButton.alpha = 0
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //更该比例
    func hideMyself(isHidden:Bool){
        
        if isHidden{
            self.backgroundColor = UIColor.clear
            self.recordBackView.backgroundColor = UIColor.clear
            self.beautyButton.isHidden = true
            self.fillterButton.isHidden = true
        }else{
            self.backgroundColor = UIColor.white
            self.recordBackView.backgroundColor = UIColor.white
            self.beautyButton.isHidden = false
            self.fillterButton.isHidden = false
        }
        
    }
    
    
    
    
    //按钮点击
    
    //改变滤镜
    @objc func  changeFillter(){
       
        delegate?.changeFillter()
    }
    
    /// 美颜
    ///
    /// - Parameter btn: 按钮
    @objc func beauty(_ btn:UIButton){
        
        btn.isSelected = !btn.isSelected
        delegate?.beauty()
    }
    

    /// 长视频录制结束
    @objc func finishRecord(){
        delegate?.finishLongVideoRecord()
    }
    
    @objc func deletePrevious(){
        delegate?.deletePrevious()
    }
    
    
    
    /// 打开长视频录制页
    ///
    /// - Parameter isRecord:
    func startLongRecord(isRecord:Bool){
        delegate?.pushVideo(isRecord:isRecord)
        //位置变换动画
        transmationAction(isSelected: isRecord)
   
        
    }
    
    
    /// 转换按钮位置动画函数
    ///
    /// - Parameter isSelected: 是否转换
    func transmationAction(isSelected:Bool){
        weak var weakSelf = self
        if isSelected{
           //视频
            UIView.animate(withDuration: 0.3, animations: {
                weakSelf?.finishButton.alpha = 1
                weakSelf?.deletePreviousButton.alpha = 1

            //平移滤镜和我美颜按钮
                weakSelf?.fillterButton.transform = CGAffineTransform(translationX: 40 , y: (weakSelf?.fillterButton.transform.ty)!)
                weakSelf?.beautyButton.transform = CGAffineTransform(translationX: -40 , y: (weakSelf?.beautyButton.transform.ty)!)
                
              //  weakSelf?.layoutIfNeeded()
            })
        }else{
            UIView.animate(withDuration: 0.3, animations: {
                weakSelf?.finishButton.alpha = 0
                weakSelf?.deletePreviousButton.alpha = 0
                //平移滤镜和我美颜按钮
                weakSelf?.fillterButton.transform = CGAffineTransform(translationX: 0 , y: (weakSelf?.fillterButton.transform.ty)!)
                weakSelf?.beautyButton.transform = CGAffineTransform(translationX: 0 , y: (weakSelf?.beautyButton.transform.ty)!)
            })
        }
        
        
    }
    
}
 //MARK: - selectionviewDelegate
 extension DefaultBotomView:selectedDelegate{
    
    func didSelected(index: Int) {
        
        print(index)
        CameraModeManage.shared.currentMode = CameraMode(rawValue:index) ?? .CameraModeMovie;
        
        switch index {
        case 0://left
            break;
          //  startLongRecord(isRecord:true )
            
        case 1://right
            break;
           // startLongRecord(isRecord:false )

        default:
            break
        }
    }
    
    
    
    
 }
