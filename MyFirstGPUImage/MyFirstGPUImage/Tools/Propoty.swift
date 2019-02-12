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
let naviColor = UIColor.init(red: 245/255, green: 0/255, blue: 87/255, alpha: 1)
let bgColor = UIColor.init(red: 213/255, green: 0/255, blue: 249/255, alpha: 1)
let lightPink = UIColor.init(red: 252/255, green: 228/255, blue: 236/255, alpha: 1)
let filterSelectedColor = UIColor(red: 255/255, green: 224/255, blue: 130/255, alpha: 1)
let topFix = isiPhoneX() ? IPHONEX_TOP_FIX : 0
let bottomFix = isiPhoneX() ? IPHONEX_BOTTOM_FIX : 0

//240 207 120
//e89abe



//自定义navigation
public func setNavi(nav:UINavigationController){
    //let dict:NSDictionary = [NSAttributedStringKey.foregroundColor: UIColor.black,NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 18)]
   // nav.navigationBar.titleTextAttributes = dict as?  [NSAttributedStringKey : Any]
    nav.navigationBar.tintColor = UIColor.black
   //  nav.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

}

