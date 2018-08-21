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
    func pushVideo(btn:UIButton)
    //长视频按钮
    func finishLongVideoRecord()
    func deletePrevious()
    
}


class DefaultBotomView: UIView {
    
    //MARK: - lazy loading
//   滤镜选择按钮
    lazy var fillterButton:UIButton = {
        //frame: CGRect(x:getWidth(109), y: getHeight(150), width:getWidth(78) , height: getHeight(154))
        var btn = NewUIButton()
        btn.setImage(#imageLiteral(resourceName: "滤镜") , for: .normal)
        btn.setTitle("风格滤镜", for: .normal)
        btn.setTitleColor(UIColor.black, for: .normal)
        btn.addTarget(self, action: #selector(self.changeFillter), for: .touchUpInside)
        return btn
    }()
//  美颜按钮
    lazy var beautyButton:UIButton = {
        //CGRect(x:SCREEN_WIDTH - getWidth(109) - getWidth(78), y: getHeight(150), width:getWidth(78) , height: getHeight(154))
        var btn = NewUIButton()
        btn.setImage(#imageLiteral(resourceName: "美颜"), for: .normal)
        btn.setTitle("折纸轻美颜", for: .normal)
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
        button.setTitleColor(bgColor, for: .selected)
        button.setTitleColor(UIColor.black, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        button.addTarget(self, action: #selector(startLongRecord), for: .touchUpInside)
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
        b.backgroundColor = UIColor.white
        return b
    }()
    
    
    
    
    
    //Propoty，按钮点击的代理
    
    var delegate:DefaultBottomViewDelegate?
    


    init() {
    
        super.init(frame: CGRect.zero)
        self.backgroundColor = UIColor.white
        self.addSubview(beautyButton)
        self.addSubview(fillterButton)
        self.addSubview(recordBackView)
        self.addSubview(videoButton)
        self.addSubview(recordButton)
        recordBackView.addSubview(finishButton)
        recordBackView.addSubview(deletePreviousButton)
        fillterButton.snp.makeConstraints({
            (make) in
            make.centerY.equalToSuperview()
            make.width.height.equalTo(70)
            make.left.equalToSuperview().offset(20)
        })
       beautyButton.snp.makeConstraints({
            (make) in
            make.centerY.equalToSuperview()
            make.width.height.equalTo(70)
            make.right.equalToSuperview().offset(-20)
        })
       videoButton.snp.makeConstraints({
            (make) in
            make.centerX.equalToSuperview()
            make.width.height.equalTo(44)
            make.bottom.equalToSuperview().offset(52)
        })
        recordButton.snp.makeConstraints({
            make in
            make.centerX.equalToSuperview()
            make.height.equalTo(25)
            make.centerY.equalTo(self.snp.bottom).offset(-25)
        })
        recordBackView.snp.makeConstraints({
           make in
           make.width.height.left.equalToSuperview()
           make.top.equalTo(self.snp.bottom)
        })
        
        finishButton.snp.makeConstraints({
            make in
            make.centerY.equalToSuperview()
            make.width.height.equalTo(70)
            make.right.equalToSuperview().offset(-20)
        })
        
        deletePreviousButton.snp.makeConstraints({
            make in
            make.centerY.equalToSuperview()
            make.width.height.equalTo(70)
            make.left.equalToSuperview().offset(20)
        })
        
        
        
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
    /// - Parameter btn: button
    @objc func startLongRecord(_ btn:UIButton){
        delegate?.pushVideo(btn: btn)
        btn.isSelected = !btn.isSelected
        //位置变换动画
        weak var weakSelf = self
        if btn.isSelected{
            UIView.animate(withDuration: 0.3, animations: {
                btn.snp.remakeConstraints({
                    make in
                    make.centerX.equalToSuperview()
                    make.height.equalTo(25)
                    make.centerY.equalTo((weakSelf?.snp.top)!).offset(15)
                })
                
                weakSelf?.recordBackView.snp.remakeConstraints({
                    make in
                    make.width.height.left.top.equalToSuperview()
                })
                
                weakSelf?.layoutIfNeeded()
            })
        }else{
            UIView.animate(withDuration: 0.3, animations: {
                btn.snp.remakeConstraints({
                    make in
                    make.centerX.equalToSuperview()
                    make.height.equalTo(25)
                    make.centerY.equalTo((weakSelf?.snp.bottom)!).offset(-25)
                })
                
                weakSelf?.recordBackView.snp.remakeConstraints({
                    make in
                    make.width.height.left.equalToSuperview()
                    make.top.equalTo((weakSelf?.snp.bottom)!)
                })
                
                weakSelf?.layoutIfNeeded()
            })
        }
        
    }

}
