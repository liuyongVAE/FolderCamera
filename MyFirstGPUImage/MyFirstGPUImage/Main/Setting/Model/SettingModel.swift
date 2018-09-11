//
//  SettingModel.swift
//  MyFirstGPUImage
//
//  Created by LiuYong on 2018/9/10.
//  Copyright © 2018年 LiuYong. All rights reserved.
//

import Foundation

class  SettingModel {
    var section = ["拍照设置","其他"]
    var titles = [
        0:["人脸识别框"],
        1:["版本更新","意见反馈","许可证明","关于折纸","给我点赞吧~"]
    ]
    
    var selectedValue = [true]
    
    static var share:SettingModel = {
        var share = SettingModel()
        return share
        
    }()
    
    func setSelectedValue(index:Int,value:Bool){
        selectedValue[index] = value
        UserDefaults.standard.set(value, forKey: "isFaceLayer")
    }
    
}
