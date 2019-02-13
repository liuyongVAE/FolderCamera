//
//  File.swift
//  MyFirstGPUImage
//
//  Created by 刘勇 on 2019/1/24.
//  Copyright © 2019 LiuYong. All rights reserved.
//

import Foundation

let IPHONEX_TOP_FIX:CGFloat = 24;
let IPHONEX_BOTTOM_FIX:CGFloat = 34;

func isiPhoneX() ->Bool {
    let screenHeight = UIScreen.main.nativeBounds.size.height;
    if screenHeight == 2436 || screenHeight == 1792 || screenHeight == 2688 || screenHeight == 1624 {
        return true
    }
    return false
}


struct Platform {
    static let isSimulator: Bool = {
        var isSim = false
        #if arch(i386) || arch(x86_64)
        isSim = true
        #endif
        return isSim
    }()
}
