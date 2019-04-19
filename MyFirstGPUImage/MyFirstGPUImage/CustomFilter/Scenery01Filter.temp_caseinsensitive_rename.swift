//
//  scenery01Filter.swift
//  MyFirstGPUImage
//
//  Created by apple on 2019/4/14.
//  Copyright © 2019 LiuYong. All rights reserved.
//

import Foundation
import UIKit
//import GPUImage

class Scenery01Filter: GPUImageFilterGroup {
    
    var lookupImageSource:GPUImagePicture!
    
    override init() {
        super.init()
        let image = UIImage(named: "");
        assert((image != nil), "To use GPUImageAmatorkaFilter you need to add lookup_amatorka.png from GPUImage/framework/Resources to your application bundle.");
        
        lookupImageSource = GPUImagePicture(image: image)
        let lookupFilter = GPUImageLookupFilter();
        self.addFilter(lookupFilter)
        lookupImageSource.addTarget(lookupFilter, atTextureLocation: 1)
        lookupImageSource.processImage()

        self.initialFilters = [lookupFilter];
        
        self.terminalFilter = lookupFilter;
        }
    
    
}
