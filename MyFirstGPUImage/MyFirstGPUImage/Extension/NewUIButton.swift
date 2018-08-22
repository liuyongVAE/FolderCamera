//
//  NewUIButton.swift
//  MyFirstGPUImage
//
//  Created by LiuYong on 2018/7/26.
//  Copyright © 2018年 LiuYong. All rights reserved.
//

import UIKit

class NewUIButton: UIButton {

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //设置按钮的基本属性
    func commonInit() {
        self.titleLabel?.textAlignment = .center
        self.imageView?.contentMode = .scaleAspectFit
        self.titleLabel?.font = UIFont.systemFont(ofSize: 10)
    }
    
    //调整系统UIButton的文字的位置
    override func titleRect(forContentRect  contentRect: CGRect) -> CGRect {
        let titleX = 0
        let titleY = contentRect.size.height * 0.45
        let titleW = contentRect.size.width
        let titleH = contentRect.size.height - titleY
        return CGRect(x: CGFloat(titleX), y: titleY, width: titleW, height: titleH)//CGRectMake(CGFloat(titleX), titleY, titleW, titleH)
    }
    
    //调整系统UIButton的图片的位置
    override func imageRect(forContentRect contentRect: CGRect) -> CGRect {
        let imageW = contentRect.width
        let imageH = contentRect.size.height * 0.5
        return   CGRect(x: 0, y: 0, width: imageW, height: imageH) //CGRectMake(0, 5, imageW, imageH)
    }

}
