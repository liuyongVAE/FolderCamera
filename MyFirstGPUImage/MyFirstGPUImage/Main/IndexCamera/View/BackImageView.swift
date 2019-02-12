//
//  BackImageView.swift
//  MyFirstGPUImage
//
//  Created by 刘勇 on 2019/2/12.
//  Copyright © 2019 LiuYong. All rights reserved.
//

import Foundation
import UIKit

class BackImageView: UIImageView {
    override init(frame: CGRect) {
        super.init(frame: frame);
        self.image = UIImage(named: "faceModeBackground")
    }
    
    init() {
        super.init(frame: CGRect.zero);
        self.image = UIImage(named: "faceModeBackground")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

