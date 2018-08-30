//
//  MTImageUtils.m
//  MTLivePhotoDemo
//
//  Created by wuxi on 16/9/23.
//  Copyright © 2016年 wuxi. All rights reserved.
//

#import "MTImageTool.h"


@implementation MTImageTool

+ (UIImage *)imageFromSampleBuffer:(CMSampleBufferRef)bufferRef
{
    //制作 CVImageBufferRef
    CVImageBufferRef buffer;
    if(bufferRef)
    {
        buffer = CMSampleBufferGetImageBuffer(bufferRef);
        CFRetain(buffer);
        CFRelease(bufferRef);
    }
    else
    {
        return NULL;
    }
    
    CVPixelBufferLockBaseAddress(buffer, 0);
    //从 CVImageBufferRef 取得影像的细部信息
    uint8_t *base;
    size_t width, height, bytesPerRow;
    base = (uint8_t *)CVPixelBufferGetBaseAddressOfPlane(buffer, 0);
    width = CVPixelBufferGetWidth(buffer);
    height = CVPixelBufferGetHeight(buffer);
    bytesPerRow = CVPixelBufferGetBytesPerRow(buffer);
    
    //利用取得影像细部信息格式化 CGContextRef
    CGColorSpaceRef colorSpace;
    CGContextRef cgContext;
    colorSpace = CGColorSpaceCreateDeviceRGB();
    cgContext = CGBitmapContextCreate(base, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    CGColorSpaceRelease(colorSpace);
    
    if (!cgContext)
    {
        //千万别调用 CGColorSpaceRelease(colorSpace);
        return NULL;
    }
    //这里没有释放？？？，这里不应该释放
    CGImageRef cgImage = CGBitmapContextCreateImage(cgContext);
    CVPixelBufferUnlockBaseAddress(buffer, 0);
    CGContextRelease(cgContext);
    //透过 CGImageRef 将 CGContextRef 转换成 UIImage
    UIImage *image = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    
    return image;

}
+ (CVPixelBufferRef)pixelBufferFromCGImage:(CGImageRef)image
{
    CVPixelBufferRef pxbuffer = NULL;
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey,
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey,
                             nil];
    
    size_t width =  CGImageGetWidth(image);
    size_t height = CGImageGetHeight(image);
    size_t bytesPerRow = CGImageGetBytesPerRow(image);
    
    CFDataRef  dataFromImageDataProvider = CGDataProviderCopyData(CGImageGetDataProvider(image));
    GLubyte  *imageData = (GLubyte *)CFDataGetBytePtr(dataFromImageDataProvider);
    
    CVPixelBufferCreateWithBytes(kCFAllocatorDefault,width,height,kCVPixelFormatType_32BGRA,imageData,bytesPerRow,NULL,NULL,(__bridge CFDictionaryRef)options,&pxbuffer);
    
    
    CFRelease(dataFromImageDataProvider);
    
    return pxbuffer;
}
@end
