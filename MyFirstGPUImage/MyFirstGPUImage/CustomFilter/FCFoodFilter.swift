//
//  FCFoodFilter.swift
//  MyFirstGPUImage
//
//  Created by apple on 2019/4/14.
//  Copyright © 2019 LiuYong. All rights reserved.
//

import UIKit

class FCFoodFilter: FCSceneryFilter {
    override func setCustomIndex(index: Int) {
        let image = UIImage(named: foodSourceNames[index]);
        fetchLookUpSource(image: image)
    }
}
