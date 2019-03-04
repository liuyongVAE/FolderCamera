//
//  TestLookUpFilter.h
//  MyFirstGPUImage
//
//  Created by 刘勇 on 2019/3/3.
//  Copyright © 2019 LiuYong. All rights reserved.
//

#import <GPUImage/GPUImage.h>

NS_ASSUME_NONNULL_BEGIN

@interface TestLookUpFilter : GPUImageFilterGroup {
    GPUImagePicture *lookupImageSource;
}

@end

NS_ASSUME_NONNULL_END
