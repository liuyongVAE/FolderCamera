//
//  Propoty.swift
//  MyFirstGPUImage
//
//  Created by LiuYong on 2018/7/26.
//  Copyright © 2018年 LiuYong. All rights reserved.
//

import Foundation
import UIKit

//屏幕长宽和主题颜色
let SCREEN_HEIGHT = UIScreen.main.bounds.height
let SCREEN_WIDTH = UIScreen.main.bounds.width
let naviColor = UIColor.init(red: 232/255, green: 154/255, blue: 190/255, alpha: 1)
//e89abe

//计算空间在屏幕坐标
func getHeight(_ height: Double) -> CGFloat{
    return CGFloat(height/1920)*(SCREEN_HEIGHT)
}

func getWidth(_ width :Double) -> CGFloat {
    return  CGFloat(width/1080)*(SCREEN_WIDTH)
}


//CGRECT的简单封装，更好使用
public func Rect(_ x:Double,_ y:Double,_ w:Double,_ h:Double)->CGRect{
    
    return CGRect(x:getWidth(x),y:getHeight(y),width:getWidth(w),height:getHeight(h))
}
public func FloatRect(_ x:CGFloat,_ y:CGFloat,_ w:CGFloat,_ h:CGFloat)->CGRect{
    
    return CGRect(x:x,y:y,width:w,height:h)
}
