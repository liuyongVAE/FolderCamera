//
//  FCAIFilter.swift
//  MyFirstGPUImage
//
//  Created by liuyong on 2019/5/23.
//  Copyright © 2019年 LiuYong. All rights reserved.
//

import UIKit

class FCAIFilter: FCSceneryFilter {
    override func setCustomIndex(index: Int) {
        let image = UIImage(named: aiFilterName[index]);
        fetchLookUpSource(image: image)
    }
}
