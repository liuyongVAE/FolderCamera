//
//  File.swift
//  MyFirstGPUImage
//
//  Created by 刘勇 on 2019/1/24.
//  Copyright © 2019 LiuYong. All rights reserved.
//

import Foundation
import UIKit

let IPHONEX_TOP_FIX:CGFloat = 24;
let IPHONEX_BOTTOM_FIX:CGFloat = 34;

func isiPhoneX() ->Bool {
    let screenHeight = UIScreen.main.nativeBounds.size.height;
    if screenHeight == 2436 || screenHeight == 1792 || screenHeight == 2688 || screenHeight == 1624 {
        return true
    }
    return false
}

func addImage(_ image1: UIImage?, withImage image2: UIImage?) -> UIImage? {
    

    UIGraphicsBeginImageContext(image1?.size ?? CGSize.zero)
    
    image1?.draw(in: CGRect(x: 0, y: 0, width: image1?.size.width ?? 0.0, height: image1?.size.height ?? 0.0))
    
    image2?.draw(in: CGRect(x: 0, y: 0, width: image1?.size.width ?? 0.0, height: image1?.size.height ?? 0.0))
    
    let resultingImage: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
    
    UIGraphicsEndImageContext()
    
    return resultingImage
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
