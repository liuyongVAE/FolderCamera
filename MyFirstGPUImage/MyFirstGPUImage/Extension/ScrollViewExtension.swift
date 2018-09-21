//
//  ScrollViewExtension.swift
//  MyFirstGPUImage
//
//  Created by LiuYong on 2018/9/19.
//  Copyright © 2018年 LiuYong. All rights reserved.
//

import UIKit

//为解决ScrollView不能响应touches事件问题
extension UIScrollView{
    
    override  open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //传给下一层响应者
        self.next?.touchesBegan(touches, with: event)
        super.touchesBegan(touches, with: event)
    }
    
    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        //传给下一层响应者
        self.next?.touchesEnded(touches, with: event)
        super.touchesEnded(touches, with: event)
    }
    
    
}
