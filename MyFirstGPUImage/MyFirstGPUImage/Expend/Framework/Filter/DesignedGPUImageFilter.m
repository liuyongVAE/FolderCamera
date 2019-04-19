//
//  DesignedGPUImageFilter.m
//  MyFirstGPUImage
//
//  Created by LiuYong on 2018/8/10.
//  Copyright © 2018年 LiuYong. All rights reserved.
//

#import "DesignedGPUImageFilter.h"
#import "GPUImageFilter.h"




@implementation DesignedGPUImageFilter
- (id)init {
    if (self = [super initWithFragmentShaderFromFile:@"myShader"]) {
 
        return self;
    }else{
        return nil;
    }
   
}




@end

