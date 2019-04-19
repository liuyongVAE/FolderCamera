//
//  FilterGroup.swift
//  MyFirstGPUImage
//
//  Created by LiuYong on 2018/8/1.
//  Copyright © 2018年 LiuYong. All rights reserved.
//

import Foundation

struct FCFilter {
    var name:String
    var imageCode:String
    var filter:GPUImageOutput & GPUImageInput
}


//获取自定义滤镜组Model
class FilterGroup {
    
    var currentFilter:FCFilter!
    
    var count:Int {
        
        switch CameraModeManage.shared.currentMode {
        case .CameraModePeople:
            return peopleSourceNames.count;
        case .CameraModeMovie:
            return movieSourceNames.count;
        case .CameraModeScenery:
            return scenerySourceNames.count;
        case .CameraModeFilm:
            return filmSourceNames.count;
        case .CameraModeFood:
            return foodSourceNames.count;
        default :
            return 0;
    }
    }
    
    static let shared:FilterGroup = {
        return FilterGroup.init()
    }()
    
    private init(){
        
        self.currentFilter = FCFilter(name: "原图", imageCode: "原图",filter: IFNormalFilter());
    }
    
    
    func getFilterWithIndex(index:Int) -> FCFilter {
        
        var cuFilter = FCFilter(name: "原图", imageCode: "原图",filter: IFNormalFilter());
        if (index == 0) {
            return cuFilter;
        }
        
        switch CameraModeManage.shared.currentMode {
        case .CameraModePeople:
            cuFilter = getPeopleFilter(index: index);
        case .CameraModeMovie:
            cuFilter = getMovieFilter(index: index);
        case .CameraModeScenery:
            cuFilter = getSceneryFilter(index: index)
        case .CameraModeFilm:
            cuFilter = getFilmFilter(index: index);
        case .CameraModeFood:
            cuFilter = getFoodFilter(index: index)
        default:
            break;
        }
        
        self.currentFilter = cuFilter;
        return cuFilter;
    
    }
    

    func getMovieFilter(index:Int) -> FCFilter {
        
        let cufilter = FCFilter(name: movieFilterNames[index], imageCode: movieIconNames[index],filter: FCMovieFilter(index: index))

        return cufilter
    }
    
   func getPeopleFilter(index:Int) -> FCFilter {
        
       let cufilter = FCFilter(name: peopleFilterNames[index], imageCode: peopleIconNames[index],filter: FCPeopleFilter(index: index))

        return cufilter
        
    }
    func getSceneryFilter(index:Int) -> FCFilter {
        
        let cufilter = FCFilter(name: sceneryFilterNames[index], imageCode: sceneryIconNames[index],filter: FCSceneryFilter(index: index))

        return cufilter
        
    }
    
     func getFoodFilter(index:Int) -> FCFilter {
        
         let cufilter = FCFilter(name: foodFilterNames[index], imageCode: foodIconNames[index],filter: FCFoodFilter(index: index))
        
     
        return cufilter
        
    }
    
     func getFilmFilter(index:Int) -> FCFilter {
        
        let cufilter = FCFilter(name: filmFilterNames[index], imageCode: filmIconNames[index],filter: FCFilmFilter(index: index))
   
        return cufilter
        
    }
    
    
    /// 获取滤镜名称
    ///
    /// - Parameter filterType: 滤镜代码
    /// - Returns: 滤镜名称
   private  func getFillterName(filterType:Int)->String{
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
  private func getFillter(filterType:Int)->GPUImageOutput & GPUImageInput{
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
            filter = TestLookUpFilter()
            
        case 14:
            filter = GPUImageBeautifyFilter()
        default:
            break
        }
        return filter
        
    }
    
    
  private func addGPUImageFilter(_ filter: (GPUImageOutput & GPUImageInput)?) -> GPUImageFilterGroup {
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

