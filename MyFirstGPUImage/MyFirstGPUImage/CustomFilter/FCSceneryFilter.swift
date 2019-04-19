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

class FCSceneryFilter: GPUImageFilterGroup {
    
    var lookupImageSource:GPUImagePicture!
    var currentIndex:Int!
    
    override init() {
        super.init()
        let image = UIImage(named: "风景-01鲜明.png");
        self.currentIndex = 0;
        fetchLookUpSource(image: image)
    }
    
    init(index:Int) {
        
        super.init()
        setCustomIndex(index: index)
        self.currentIndex = index;

    }
    
    
    func setCustomIndex(index:Int){
        let image = UIImage(named: scenerySourceNames[index]);
        fetchLookUpSource(image: image)
    }
    
   func fetchLookUpSource(image:UIImage?){
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
