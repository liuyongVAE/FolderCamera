//
//  DefaultBotomView.swift
//  MyFirstGPUImage
//
//  Created by LiuYong on 2018/7/26.
//  Copyright © 2018年 LiuYong. All rights reserved.
//

import UIKit



protocol DefaultBottomViewDelegate{
    func  changeFillter()
    func beauty(_ btn:UIButton)
}


class DefaultBotomView: UIView {
    
    //MARK: - lazy loading
    
    lazy var fillterButton:UIButton = {
        var btn = NewUIButton(frame: CGRect(x:getWidth(109), y: getHeight(150), width:getWidth(78) , height: getHeight(154)))
        btn.setImage(#imageLiteral(resourceName: "滤镜") , for: .normal)
        btn.setTitle("滤镜", for: .normal)
        btn.setTitleColor(UIColor.black, for: .normal)
        btn.addTarget(self, action: #selector(self.changeFillter), for: .touchUpInside)
        return btn
    }()
    
    lazy var beautyButton:UIButton = {
        var btn = NewUIButton(frame: CGRect(x:SCREEN_WIDTH - getWidth(109) - getWidth(78), y: getHeight(150), width:getWidth(78) , height: getHeight(154)))
        btn.setImage(#imageLiteral(resourceName: "美颜"), for: .normal)
        btn.setTitle("美颜", for: .normal)
        btn.setImage(#imageLiteral(resourceName: "美颜2"), for: .selected)
        btn.setTitleColor(UIColor.black, for: .normal)
        btn.addTarget(self, action: #selector(self.beauty), for: .touchUpInside)
        return btn
    }()
    
    //Propoty
    
    var delegate:DefaultBottomViewDelegate?
    

    
     init() {
        //default frame
        
        super.init(frame: FloatRect(0, SCREEN_HEIGHT*3/4, SCREEN_WIDTH, SCREEN_HEIGHT/4))
        self.backgroundColor = UIColor.white
        
        self.addSubview(beautyButton)
        self.addSubview(fillterButton)
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
