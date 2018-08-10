//
//  CaptureViewController.h
//  MyFirstGPUImage
//
//  Created by LiuYong on 2018/8/8.
//  Copyright © 2018年 LiuYong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GPUImageBeautifyFilter.h"
#import "InstaFilters.h"

//优化，此处传入上一个页面的Camera，无需再次新建；
@interface CaptureViewController : UIViewController
- (instancetype)initWithCamera:(GPUImageStillCamera *)camera; //andFilter:(IFFilter);
@end

