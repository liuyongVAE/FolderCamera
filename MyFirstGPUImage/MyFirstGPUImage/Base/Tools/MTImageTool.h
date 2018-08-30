//
//  MTImageUtils.h
//  MTLivePhotoDemo
//
//  Created by wuxi on 16/9/23.
//  Copyright © 2016年 wuxi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>
#import <UIKit/UIKit.h>

@interface MTImageTool : NSObject

/**
 *  类型转换
 */
+ (UIImage *)imageFromSampleBuffer:(CMSampleBufferRef)bufferRef;
/**
 *  类型转换
 */
+ (CVPixelBufferRef)pixelBufferFromCGImage:(CGImageRef)image;
@end
