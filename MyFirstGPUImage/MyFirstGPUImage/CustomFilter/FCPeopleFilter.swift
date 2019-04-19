//
//  FCPeopleFilter.swift
//  MyFirstGPUImage
//
//  Created by apple on 2019/4/14.
//  Copyright © 2019 LiuYong. All rights reserved.
//

import Foundation
class FCPeopleFilter: FCSceneryFilter {
    
    override func setCustomIndex(index: Int) {
        let image = UIImage(named: peopleSourceNames[index]);
        fetchLookUpSource(image: image)
    }
    
    
}
