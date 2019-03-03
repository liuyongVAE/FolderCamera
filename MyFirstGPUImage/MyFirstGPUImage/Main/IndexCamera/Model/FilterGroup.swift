//
//  FilterGroup.swift
//  MyFirstGPUImage
//
//  Created by LiuYong on 2018/8/1.
//  Copyright © 2018年 LiuYong. All rights reserved.
//

import Foundation


//获取自定义滤镜组Model
class FilterGroup {
    
    
    static var count = 13//滤镜个数
    
    init() {
    }
    
    
    /// 获取滤镜名称
    ///
    /// - Parameter filterType: 滤镜代码
    /// - Returns: 滤镜名称
    class func getFillterName(filterType:Int)->String{
        var title = ""
        switch filterType {
        case 0:
            title = "原图"
        case 1:
            title = "布拉格"
        case 2:
            title = "黑白"
        case 3:
            title = "鲜亮"
        case 4:
            title = "暖暖"
        case 5:
            title = "流年"
        case 6:
            title = "胶片"
        case 7:
            title = "维也纳"
        case 8:
            title = "少女"
        case 9:
            title = "薄暮"
        case 10:
            title = "时光"
        case 11:
            title = "白露"
        case 12:
            title = "Rise"
        case 13:
            title = "萨拉里昂"
        default:
            break
            
        }
        return title
    }
    
    
    
    
  /// 获取滤镜
  ///
  /// - Parameter filterType: 滤镜代码
  /// - Returns: 滤镜
  class func getFillter(filterType:Int)->GPUImageOutput & GPUImageInput{
    var filter:(GPUImageOutput & GPUImageInput)!
        switch filterType {
        case 0:
            return IFNormalFilter()
        case 1:
            filter = IF1977Filter()
        case 2:
            filter = IFInkwellFilter()
        case 3:
            filter = IFBrannanFilter()
        case 4:
            filter = IFEarlybirdFilter()
        case 5:
            filter = IFHefeFilter()
        case 6:
            filter = IFHudsonFilter()
        case 7:
            filter = IFAmaroFilter()
        case 8:
            filter = IFLomofiFilter()
        case 9:
            filter = IFLordKelvinFilter()
        case 10:
            filter = IFNashvilleFilter()
        case 11:
            filter = IFWaldenFilter()
        case 12:
            filter = IFRiseFilter()
        case 13:
            filter = IFRiseFilter()
            
        case 14:
            filter = GPUImageBeautifyFilter()
        default:
            break
        }
        return filter
        
    }
    
    
   class func addGPUImageFilter(_ filter: (GPUImageOutput & GPUImageInput)?) -> GPUImageFilterGroup {
        let filterGroup = GPUImageFilterGroup()
        filterGroup.addFilter(filter)
        
        let newTerminalFilter: (GPUImageOutput & GPUImageInput)? = filter
        
        let count = filterGroup.filterCount() as UInt;
        
        if count == 1 {
            filterGroup.initialFilters = [newTerminalFilter!]
            filterGroup.terminalFilter = newTerminalFilter
        } else {
            let terminalFilter: (GPUImageOutput & GPUImageInput)? = filterGroup.terminalFilter
            let initialFilters = filterGroup.initialFilters
            
            terminalFilter?.addTarget(newTerminalFilter)
            
            filterGroup.initialFilters = [initialFilters![0]]
            filterGroup.terminalFilter = newTerminalFilter
        }
        
        return filterGroup;
    }
    
    


}

