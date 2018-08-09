//
//  CaptureViewController.m
//  MyFirstGPUImage
//
//  Created by LiuYong on 2018/8/8.
//  Copyright © 2018年 LiuYong. All rights reserved.
//

#import "CaptureViewController.h"
#import "GPUImage.h"
#import "MyFirstGPUImage-Swift.h"
#import "ProgressHUD.h"
#import "Photos/Photos.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AssetsLibrary/ALAssetsLibrary.h>


@interface CaptureViewController ()<ProgresssButtonDelegate>{
    GPUImageVideoCamera *_videoCamera;  // 捕获画面
    GPUImageView *_imageView;   // 展示画面
    GPUImageMovieWriter *_movieWriter;  // 视频编解码
    NSString *_temPath;    // 录制视频的临时缓存地址
    GPUImageFilter *_filter;  // 滤镜效果
}
@property (nonatomic, strong) RoundProgressButtonView *recordBtn;
@property (nonatomic, strong) UILabel *tipLabel;
@property (nonatomic, strong) UIButton *backButton;




@end

@implementation CaptureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    CGFloat width = self.view.bounds.size.width;
    CGFloat height = self.view.bounds.size.height;
    _imageView = [[GPUImageView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    _imageView.center = self.view.center;
    [self.view addSubview:_imageView];
    
    // 卡通滤镜效果（黑色描边）
    _filter = [[GPUImageFilter alloc] init];
    
    _videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionFront];
    _videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    [_videoCamera addTarget:_filter];
    [_filter addTarget:_imageView];
    // GPUImageVideoCamera 开始捕获画面展示在 GPUImageView
    [_videoCamera startCameraCapture];
    _imageView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
    RoundProgressButtonView *recordBtn = [[RoundProgressButtonView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width / 2.0 - 30, height - 90,80,80)];
    recordBtn.center = CGPointMake(self.view.frame.size.width/2, height - 100);
    recordBtn.layer.cornerRadius = 35;
    [recordBtn setUserInteractionEnabled:YES];
    recordBtn.delegate = self;
    [self.view addSubview:recordBtn];
    
    self.tipLabel =[[UILabel alloc]initWithFrame: CGRectZero];
    [self.tipLabel setText:@"长按拍照键拍照"];
    [self.tipLabel setTextColor:[UIColor whiteColor]];
    [self.tipLabel setFont:[UIFont systemFontOfSize:12]];
    [self.tipLabel sizeToFit];
    [self.tipLabel setCenter:CGPointMake(recordBtn.center.x, height - 160)];
    [self.view addSubview:_tipLabel];
    
    self.backButton =[[UIButton alloc]initWithFrame: CGRectMake(0, 0, 50, 50)];
    [self.backButton setCenter:CGPointMake(self.view.bounds.size.width / 2.0 + 100, recordBtn.center.y)];
    [_backButton setImage:[UIImage imageNamed:@"imageback"] forState:UIControlStateNormal];
    [_backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_backButton];
    
    UIButton *lensBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    lensBtn.frame = CGRectMake(self.view.bounds.size.width - 50,15,30,30);
    [lensBtn setImage:[UIImage imageNamed:@"转换"] forState:UIControlStateNormal];
    // [lensBtn setTitle:@"后置" forState:UIControlStateNormal];
    // [lensBtn setTitle:@"前置" forState:UIControlStateSelected];
    [lensBtn addTarget:self action:@selector(lensBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    
    _videoCamera.horizontallyMirrorFrontFacingCamera = YES; // 前置摄像头需要 镜像反转
    _videoCamera.horizontallyMirrorRearFacingCamera = NO; // 后置摄像头不需要 镜像反转 （default：NO）
    [_videoCamera addAudioInputsAndOutputs]; //该句可防止允许声音通过的情况下，避免录制第一帧黑屏闪屏
    
    [self.view addSubview:lensBtn];
    
    
    // Do any additional setup after loading the view.
}

- (void)recordBtnFinish{
    
    // 录像状态结束
    [ProgressHUD show:@"保存中"];
    [_movieWriter finishRecording];
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    NSLog(@"视频录制完成 地址是这个 %@", _temPath);
   // NSURL *viderUrl = [NSURL URLWithString:_temPath];
    NSURL *viderUrl = [[NSURL alloc] initFileURLWithPath:_temPath];
    if ([library videoAtPathIsCompatibleWithSavedPhotosAlbum:viderUrl]) {
        [library writeVideoAtPathToSavedPhotosAlbum:viderUrl completionBlock:^(NSURL *assetURL, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error) {
                    ;
                } else {
                    [ProgressHUD showSuccess:@"录制成功，已保存"];
                    //先自定义一个全局的MPMoviePlayerViewController 对象
                    MPMoviePlayerViewController *mPMoviePlayerViewController;
                    //把下面的代码放到跳转播放的按钮方法里面
                    mPMoviePlayerViewController =[[MPMoviePlayerViewController alloc]initWithContentURL:viderUrl];
                    mPMoviePlayerViewController.view.frame = self.view.bounds;
                    [mPMoviePlayerViewController.moviePlayer setRepeatMode:MPMovieRepeatModeOne];
                    [self presentViewController:mPMoviePlayerViewController animated:YES completion:nil];
                }
            });
        }];
    }
    
    
    
    [_videoCamera removeTarget:_movieWriter];
    
    
}

-(void)recordCanceld{
    [_movieWriter cancelRecording];
}
- (void)recordBtnAction{
    

    
    // 录像
    _temPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Movie.mov"];
    unlink([_temPath UTF8String]);
    // 判断路径是否存在，如果存在就删除路径下的文件，否则是没法缓存新的数据的。
    
    NSURL *movieURL = [NSURL fileURLWithPath:_temPath];
    

    //判断屏幕状态（横屏）
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown) {
        _movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:_imageView.frame.size];
    }else {
        _movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:_imageView.frame.size];
    }
    
    
    
    [_movieWriter setHasAudioTrack:YES audioSettings:nil];
    _movieWriter.encodingLiveVideo = YES;
    _movieWriter.shouldPassthroughAudio = YES;
    _videoCamera.audioEncodingTarget = _movieWriter;
    [_filter addTarget:_movieWriter];
    
    [_movieWriter startRecording];
}


- (void)lensBtnAction:(UIButton *)sender{
    
    [_videoCamera rotateCamera];
    sender.selected = !sender.selected;
}

- (void)back{
    
    [self.navigationController popViewControllerAnimated:true];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */



- (void)videoControlWithControl:(RoundProgressButtonView * _Nonnull)control gest:(UIGestureRecognizer * _Nonnull)gest {
    if ([NSStringFromClass([gest class]) isEqualToString:@"UITapGestureRecognizer"]) {
        // [self recordBtnAction]
    }
    switch (gest.state) {
        case UIGestureRecognizerStateBegan:{
             _tipLabel.hidden = YES;
            [self recordBtnAction];
        }
            break;
        case UIGestureRecognizerStateCancelled:{
            [self recordCanceld];
            break;
            
        }
        case UIGestureRecognizerStateEnded:{
            if (_tipLabel.hidden){
                [self recordBtnFinish];
                _tipLabel.hidden = NO;

            }else{
            }
            //            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            //                [self removeScaleTemp];
            //            });
            break;
            
        }
        default:
            break;
            
    }
}


//


@end
