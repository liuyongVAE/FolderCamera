//
//  ViewControllerExtension.swift
//  MyFirstGPUImage
//
//  Created by 刘勇 on 2019/2/12.
//  Copyright © 2019 LiuYong. All rights reserved.
//

import Foundation
import FLEX

//debug
extension FConViewController {
    
    
    override open func motionBegan(_ motion: UIEventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            FLEXManager.shared()?.showExplorer()
        }
    }
    
}
