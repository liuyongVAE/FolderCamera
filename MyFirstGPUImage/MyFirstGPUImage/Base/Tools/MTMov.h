//
//  Mov.h
//  MTLivePhotoDemo
//
//  Created by wuxi on 16/9/14.
//  Copyright © 2016年 wuxi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPUImageBeautifyFilter.h"

/**
 读取视频文件，修改metadata，添加滤镜，生成可以构成livephoto的部分
 不想加滤镜可以设置滤镜参数为GPUImageSaturationFilter，参数saturation为1；或者直接设置参数为nil
 */
@interface MTMov : NSObject
/**
 *  初始化函数
 *
 *  @param path 一段视频的路径
 *
 *  @return self
 */
- (instancetype)initWithPath:(NSString *)path;
/**
 *  写入可以生成livephoto的带有音频轨道的视频文件
 *
 *  @param path            写入的路径
 *  @param assetIdentifier [[NSUUID UUID] UUIDString]获取
 *  @param filter          给这段视频添加的滤镜
 */
- (void)writeToDirectory:(NSString *)path WithAssetIdentifier:(NSString *)assetIdentifier filter:(GPUImageOutput<GPUImageInput> *)filter;

@end
