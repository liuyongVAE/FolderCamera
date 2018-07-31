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
    func  changeFillter()
    func beauty(_ btn:UIButton)
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
    
    //Propoty，按钮点击的代理
    
    var delegate:DefaultBottomViewDelegate?
    

    

    
    init() {
        super.init(frame: CGRect.zero)
        self.backgroundColor = UIColor.white
        self.addSubview(beautyButton)
        self.addSubview(fillterButton)
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
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
    
    //按钮点击
    
    @objc func  changeFillter(){
       
        delegate?.changeFillter()
    }
    
    @objc func beauty(_ btn:UIButton){
        
        btn.isSelected = !btn.isSelected
        delegate?.beauty(btn)
    }
    
    

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
