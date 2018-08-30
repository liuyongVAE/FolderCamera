//
//  Mov.m
//  MTLivePhotoDemo
//
//  Created by wuxi on 16/9/14.
//  Copyright © 2016年 wuxi. All rights reserved.
//

#import "MTMov.h"
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
#import "GPUImageFilter.h"
#import "MTImageTool.h"

//第一个key不能改，不然会报invalid video metadata
NSString *const kKeyContentIdentifier = @"com.apple.quicktime.content.identifier";
NSString *const kKeyStillImageTime = @"com.apple.quicktime.still-image-time";
NSString *const kKeySpaceQuickTimeMetadata = @"mdta";

@interface MTMov ()

@property (nonatomic, retain)NSString *path;
@property (nonatomic, retain)AVURLAsset *asset;

@end

@implementation MTMov

- (instancetype)initWithPath:(NSString *)path
{
    if (self = [super init])
    {
        self.path = path;
        self.asset = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:path]];
    }
    return self;
}

- (void)writeToDirectory:(NSString *)path WithAssetIdentifier:(NSString *)assetIdentifier filter:(GPUImageOutput<GPUImageInput> *)filter
{
    
    
    
    AVAssetTrack *track = [self track:AVMediaTypeVideo];
    AVAssetTrack *audioTrack = [self track:AVMediaTypeAudio];
    if (!track)
    {
        return;
    }
    AVAssetReaderOutput *output = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:track outputSettings:@{(__bridge_transfer  NSString*)kCVPixelBufferPixelFormatTypeKey : [NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA]}];
    //声音输出
    NSDictionary *audioDic = @{AVFormatIDKey :@(kAudioFormatLinearPCM),
                          
                          AVLinearPCMIsBigEndianKey:@NO,
                          
                          AVLinearPCMIsFloatKey:@NO,
                          
                          AVLinearPCMBitDepthKey :@(16)
                          
                          };
    
    AVAssetReaderTrackOutput *audioOutput = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:audioTrack outputSettings:audioDic];
    NSError *error;
    AVAssetReader *reader = [AVAssetReader assetReaderWithAsset:self.asset error:&error];
    [reader addOutput:output];
    [reader addOutput:audioOutput];
    
    AVAssetWriterInput *input = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:[self videoSetting:track.naturalSize]];
    //声音输入
    NSDictionary *audioSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                   
                                   [ NSNumber numberWithInt: kAudioFormatMPEG4AAC], AVFormatIDKey,
                                   
                                   [ NSNumber numberWithInt: 1], AVNumberOfChannelsKey,
                                   
                                   [ NSNumber numberWithFloat: 44100], AVSampleRateKey,
                                   
                                   [ NSNumber numberWithInt: 128000], AVEncoderBitRateKey,
                                   
                                   nil];
    AVAssetWriterInput *audioInput = [AVAssetWriterInput assetWriterInputWithMediaType:[audioTrack mediaType] outputSettings:audioSettings];
    input.expectsMediaDataInRealTime = true;
    input.transform = track.preferredTransform;
    NSError *error_two;
    AVAssetWriter *writer = [AVAssetWriter assetWriterWithURL:[NSURL fileURLWithPath:path] fileType:AVFileTypeQuickTimeMovie error:&error_two];
    
    writer.metadata = @[[self metaDataWithAssetIdentifier:assetIdentifier]];
    [writer addInput:input];
    [writer addInput:audioInput];
    //pixel
    NSDictionary *sourcePixelBufferAttributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                                           
                                                           [NSNumber numberWithInt:kCVPixelFormatType_32BGRA], kCVPixelBufferPixelFormatTypeKey, nil];
    AVAssetWriterInputPixelBufferAdaptor *adaptor = [AVAssetWriterInputPixelBufferAdaptor assetWriterInputPixelBufferAdaptorWithAssetWriterInput:input sourcePixelBufferAttributes:sourcePixelBufferAttributesDictionary];
    
    AVAssetWriterInputMetadataAdaptor *adapter = [self metadataAdapter];
    [writer addInput:adapter.assetWriterInput];
    
    [writer startWriting];
    [reader startReading];
    [writer startSessionAtSourceTime:kCMTimeZero];
    
    CMTimeRange dummyTimeRange = CMTimeRangeMake(CMTimeMake(0, 1000), CMTimeMake(200, 3000));
    [adapter appendTimedMetadataGroup:[[AVTimedMetadataGroup alloc] initWithItems:[NSArray arrayWithObject:[self metadataForStillImageTime]] timeRange:dummyTimeRange]];
    //不加滤镜的情况
    if([filter isMemberOfClass:[GPUImageSaturationFilter class]])
    {
        GPUImageSaturationFilter *innerFilter = (GPUImageSaturationFilter*)filter;
        if (innerFilter.saturation == 1)
        {
            filter = nil;
        }
        
    }
    dispatch_queue_t readDataQueue = dispatch_queue_create("readDataQueue", DISPATCH_QUEUE_SERIAL);
    dispatch_async(readDataQueue, ^{
        while (reader.status == AVAssetReaderStatusReading) {
            CMSampleBufferRef videoBuffer = [output copyNextSampleBuffer];
            CMSampleBufferRef audioBuffer = [audioOutput copyNextSampleBuffer];
            
            CMTime startTime = CMSampleBufferGetPresentationTimeStamp(videoBuffer);
            UIImage *image = [MTImageTool imageFromSampleBuffer:videoBuffer];
            
            CVPixelBufferRef buffer;
            if (image && filter) {
                image = [filter imageByFilteringImage:image];
                buffer = (CVPixelBufferRef)[MTImageTool pixelBufferFromCGImage:[image CGImage]];
            }else if(image && !filter)
            {
                buffer = (CVPixelBufferRef)[MTImageTool pixelBufferFromCGImage:[image CGImage]];
            }
            else
            {
//                CFRelease(buffer);
                continue;
            }
            
            if (buffer)
            {
                while (!input.isReadyForMoreMediaData || !audioInput.isReadyForMoreMediaData) {
                    usleep(1);
                }
                if (audioBuffer)
                {
                    [audioInput appendSampleBuffer:audioBuffer];
                    CFRelease(audioBuffer);
                }
                if (![adaptor appendPixelBuffer:buffer withPresentationTime:startTime])
                {
                    NSLog(@"fail");
                    CFRelease(buffer);
                }
                
            }
            else
            {
                continue;
            }
        }
        dispatch_sync(dispatch_get_main_queue(), ^{
            [writer finishWritingWithCompletionHandler:^{
                //结束发通知
                [[NSNotificationCenter defaultCenter] postNotificationName:@"MTAudioVideoFinished" object:self];
                
            }];
        });
    });
    
    
    while (writer.status == AVAssetWriterStatusWriting) {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];
    }
    
}

- (AVAssetTrack *)track:(NSString *)type
{
    return [self.asset tracksWithMediaType:type].firstObject;
}
- (NSDictionary *)videoSetting:(CGSize)size
{
    return @{AVVideoCodecKey: AVVideoCodecH264,
             AVVideoWidthKey: [NSNumber numberWithFloat:size.width],
             AVVideoHeightKey: [NSNumber numberWithFloat:size.height]
             };
}
- (AVMetadataItem *)metaDataWithAssetIdentifier:(NSString *)assetIdentifier
{
    AVMutableMetadataItem *item = [AVMutableMetadataItem metadataItem];
    item.key = kKeyContentIdentifier;
    item.keySpace = kKeySpaceQuickTimeMetadata;
    item.value = assetIdentifier;
    item.dataType = @"com.apple.metadata.datatype.UTF-8";
    return item;
}
- (AVAssetWriterInputMetadataAdaptor *)metadataAdapter
{
    NSString *identifier = [kKeySpaceQuickTimeMetadata stringByAppendingFormat:@"/%@",kKeyStillImageTime];
    const NSDictionary *spec = @{(__bridge_transfer  NSString*)kCMMetadataFormatDescriptionMetadataSpecificationKey_Identifier :
                                     identifier,
                                 (__bridge_transfer  NSString*)kCMMetadataFormatDescriptionMetadataSpecificationKey_DataType :
                                     @"com.apple.metadata.datatype.int8"
                                 };
    CMFormatDescriptionRef desc;
    CMMetadataFormatDescriptionCreateWithMetadataSpecifications(kCFAllocatorDefault, kCMMetadataFormatType_Boxed, (__bridge CFArrayRef)@[spec], &desc);
    AVAssetWriterInput *input = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeMetadata outputSettings:nil sourceFormatHint:desc];
    CFRelease(desc);
    return [AVAssetWriterInputMetadataAdaptor assetWriterInputMetadataAdaptorWithAssetWriterInput:input];
}
- (AVMetadataItem *)metadataForStillImageTime
{
    AVMutableMetadataItem *item = [AVMutableMetadataItem metadataItem];
    item.key = kKeyStillImageTime;
    item.keySpace = kKeySpaceQuickTimeMetadata;
    item.value = [NSNumber numberWithInt:0];
    item.dataType = @"com.apple.metadata.datatype.int8";
    return item;
}

@end
