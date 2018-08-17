> 本项目基于GPUImage实现
# FolderGamera # 折纸相机
[![Support](https://img.shields.io/badge/support-iOS%208%2B%20-blue.svg?style=flat)](https://www.apple.com/nl/ios/)
![](https://img.shields.io/badge/lanuage-Swift-brightgreen.svg)

![image](https://i.imgur.com/ooykcPB.png)
>

---
# Description
- 折纸相机是基于GPUImage实现的具有滤镜和美颜功能、支持短视频拍摄的相机APP。
- 本项目基于GPUImage实现。
- 开发者博客:[Ly's Blog](https://www.liuyongvae.com)
# Get Started
```
git clone https://github.com/liuyongVAE/FolderCamera.git
```
# Frame
![image](https://i.imgur.com/EmiLpd3.jpg)
## Features
- [x] 实时滤镜
- [x] 拍摄后滤镜编辑
- [x] 小视频拍摄
- [x] 轻美颜
- [x] 比例切换
- [x] 闪光灯
- [x] 聚焦
- [ ] 高级美颜
- [ ] 设置页
- [ ] 水印
# Contact Me
ly@liuyongvae.com

---
## 思路分析
### 1.集成
```
pod install GPUImage
```
### 2.滤镜相机实现
全局变量定义
实现拍照功能需要三个核心的变量：</br>
***GPUStillCamera ：继承自VideoCamera的相机类***</br>
**GPUImageFilterGroup : 滤镜组，将多个滤镜串接在一起成为一个滤镜**</br>
**GPUImageView : 相机预览页面**</br>

```
//MAKR: - 属性
//拍摄视频camera
var mCamera:GPUImageStillCamera!
// var mFillter:GPUImageFilterGroup!
var ifFilter:GPUImageFilterGroup!
var mGpuimageView:GPUImageView!
/*
拍摄比例
0表示4:3,表示16:9
*/
var scaleRate:Int?
var ifaddFilter:Bool!
var isBeauty = false
//焦距缩放
var beginGestureScale:CGFloat!
var effectiveScale:CGFloat!
//聚焦层
var focusLayer:CALayer?
var videoUrl:URL?

```
初始化之后，要学会认识GPUIMage中的 链 的概念，在本项目中，GPUImage处理图片的流程如下：

```
graph LR
GPUImageStillCamera-->GPUImageFilterGroup
GPUImageFilterGroup-->GPUImageView
```

总结就是，GPUImage可以创建一个滤镜链，链中可以有多个分支，载入输入资源后，经过每个步骤的处理可以得到一个或多个结果。<br/>


这里用@ANTI_JAM的文档翻译来解释GPUImage的工作流程就是:
> 视频或图片载入后会以GPUImageOutput的一种子类为类型的资源对象存在。GPUImage具备的资源类有：GPUImageVideoCamera、GPUImageStillCamera、GPUImagePicture、GPUImageMovie（我记得还有一种：GPUImageRawDataInput。具体使用之后细说）。资源对象会把图片或视频载入到纹理（OpenGLES中的一种存储图片信息的具体对象），并且把这些纹理传入具体的处理流程。

> 在整个处理流程链中的滤镜或者说除了输入源之后的对象，都需要遵循GPUImageInput协议，只有这样才能拿到上一个步骤处理完成的纹理进行相应处理。这些对象会经过预先设置好的所有目标对象中，并且处理过程中可以有多个分支的存在，即有多个下一步骤的路径。

所以GPUImage在处理图片或者视频的时候，都需要遵循这样一个流程，反应在代码中就是:

```
mCamera.addTarget(mFillter)
mFillter.addTarget(mGpuimageView)
```
这两行代码就能实现将滤镜加到当前的Camera的功能，并且在GPUImageView中实现预览。

### 3.视频的处理

如果只是想实现简单的拍照功能，那么在GPUImage中，正如你所见非常简单。可以参照我的上一篇简书，介绍了如何实践最简单的滤镜拍照功能
<br/>[GPUImage实现简单拍照功能：](https://www.jianshu.com/p/8c0dddf55db7)
而对视频的处理，需要在拍照的基础上增加MoviewWrite对象，此时的 链 表示如下：
```
graph LR
GPUImageStillCamera-->GPUImageFilterGroup
GPUImageFilterGroup-->GPUImageView
```
反映在代码中：

```
mCamera.addTarget(ifFilter)
ifFilter.addTarget(mGpuimageView)
ifFilter.addTarget(movieWriter)

videoUrl = URL(fileURLWithPath: "\(NSTemporaryDirectory())folder_demo.mp4")
unlink(videoUrl?.path)
movieWriter =    GPUImageMovieWriter(movieURL:videoUrl, size:size )
//解决录制MP4帧失败的问题
movieWriter?.assetWriter.movieFragmentInterval = kCMTimeInvalid
movieWriter?.encodingLiveVideo = true
movieWriter?.setHasAudioTrack(true, audioSettings: nil)
self.mCamera.audioEncodingTarget = self.movieWriter
self.movieWriter?.startRecording()
```
所以录制视频的核心思路是：
通过GPUImageVideoCamera(StillCamera)采集视频和音频的信息，音频信息直接发送给GPUImageMovieWriter；视频信息传入响应链作为源头，渲染后的视频信息再写入GPUImageMovieWriter，同时通过GPUImageView显示在屏幕上。
图示：

![image](https://upload-images.jianshu.io/upload_images/1049769-61d8460e0779413f.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/602)

可以看到，与拍摄图片的思路不同的是，此处的滤镜链中增加了从滤镜到MovieWrite的路径，因为拍摄视频需要预分配沙盒空间，才能开始录制。而Write负责的就是讲视频文件写入存储空间。
### 4.给图片添加滤镜
这部分比较简单，通过传入UIImage对象，调用滤镜对应方法就可以了，代码如下:

```
//GPUImageFilterGroup的实例对象有这样的方法返回UIImage对象
image =  ifFilter?.image(byFilteringImage:imageNormal )
//主线程修改image
DispatchQueue.main.async {
self.photoView.image = self.image
}
```
### 5.给本地视频添加滤镜

这部分是我最头疼的部分，因为一开始做的时候对文件操作不太熟悉，加之，这里需要一些小的细节问题，所以我先说一下关于视频存储的文件和目录问题。

不然你会疯狂遇到这样一个错误：

```
[AVAssetWriter startWriting Cannot call method when status is 3]
```
其实这个错误的原因只有一个，就是文件写入失败。也就是本地已经存在同样目录下的文件，名字也相同。我们网上看，我在录制视频的时候用了这样一句话：

```
videoUrl = URL(fileURLWithPath: "\(NSTemporaryDirectory())folder_demo.mp4")
unlink(videoUrl?.path)
```

没错，这句unlink的效果就是，删除本地已存在的同样的文件。如果不进行这样的操作，你的代码就是一次性的不是么？
其实这句还有更加Swift化的写法，用FileManager:

```
let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
let videopath = paths[0].appendingPathComponent("TmpVideo.m4v")
try? FileManager.default.removeItem(at: videopath)
```
是的，这让我们认识了在存储视频时所需要注意的第一点，就是注意删除本地视频缓存（可以这么说吧）。

那么问题来了，如何给本地视频加滤镜呢？

解决了上面的问题，我们还需要解决另外两个问题，认识下这个对象：

**GPUImageMovie**
> GPUImageMovie 主要的作用是读取与解码音视频文件。它继承自GPUImageOutput，可以输出帧缓存对象，由于没有实现GPUImageInput协议，因此只能作为响应源。

> 初始化。可以通过NSURL、AVPlayerItem、AVAsset初始化
- (id)initWithAsset:(AVAsset *)asset;
- (id)initWithPlayerItem:(AVPlayerItem *)playerItem;
- (id)initWithURL:(NSURL *)url;

其中，通过AVplayerItem初始化的可以播放声音，此时你还就需要对AVPlayer对象进行管理。
而预览视频的方式我们依然可以使用GPUImageView：

```
//带声音的视频播放

//注释：playView是我封装的简单播放器管理类，继承自UIView的，这里偷懒没有做进一步简化。
//这里放一下简单实现
var player:AVPlayer?
var playerItem:AVPlayerItem?
var playerLayer:AVPlayerLayer?
//视频地址
var videoUrl:URL?{
didSet{
playerItem = AVPlayerItem(url: videoUrl!)
player = AVPlayer(playerItem: playerItem!)
playerLayer = AVPlayerLayer(player: player!)
playerLayer?.videoGravity = .resizeAspectFill
playerLayer?.frame = self.bounds
self.layer.addSublayer(playerLayer!)
}
}


//
playView.videoUrl = videoUrl
//
//初始化预览页面
moviePreview = GPUImageView()

//movieFile  = GPUImageMovie.init(url:videoUrl)
movieFile = GPUImageMovie.init(playerItem: playView.playerItem!)
movieFile?.playAtActualSpeed = false
//movieFile?.addTarget(ifFilter)
movieFile?.addTarget(moviePreview)
moviePreview?.backgroundColor = UIColor.clear
self.view.addSubview(moviePreview!)
//将该view加到最后面
self.view.sendSubview(toBack: moviePreview!)
moviePreview?.contentMode = .scaleAspectFill
//视频文件开始渲染
movieFile?.startProcessing()
movieFile?.shouldRepeat = true
```
以上就是本地视频的预览。说是本地视频，其实是上一个页面，也就是拍照页面拍摄录像时传来的缓存路径。真正的存储要在接下来实现。

预览后，要给视频加滤镜啦，这时候同样是滤镜组链的操作，只是我们这时候 
如果我们需要存储文件的话，还需要将滤镜组指向Write
movieFile滤镜组要指向滤镜组，简单的示意图如下：

```
graph LR
GPUImageMovie-->GPUImageFilterGroup
GPUImageFilterGroup-->GPUImageView
GPUImageFilterGroup-->GPUMovieWrite

```

给视频加滤镜的方法：
实际就是上图滤镜组链的实现。

```
movieFile?.shouldRepeat = true
movieFile?.runBenchmark = false
movieFile?.playAtActualSpeed = true
movieFile?.cancelProcessing()
movieFile?.removeAllTargets()
ifFilter?.removeAllTargets()
movieFile?.addTarget(ifFilter)
ifFilter?.addTarget(moviePreview)
movieFile?.startProcessing()
```






最后，加完滤镜需要存储，这里需要特别注意的是，一定要开辟新的空间新的URL给要存储的视频，嗯非常重要。我在这里爬了两天的坑，最后才发现什么博客都去死吧我要看官方文档==
是的，看官方文档才发现，官方给的方法你只要实现一次就可以了，根本不会出任何问题 ==

贴一下官方实现本地视频加滤镜的代码:

```
movieFile = [[GPUImageMovie alloc] initWithURL:sampleURL];
pixellateFilter = [[GPUImagePixellateFilter alloc] init];

[movieFile addTarget:pixellateFilter];

NSString *pathToMovie = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Movie.m4v"];
unlink([pathToMovie UTF8String]);
NSURL *movieURL = [NSURL fileURLWithPath:pathToMovie];

movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:CGSizeMake(480.0, 640.0)];
[pixellateFilter addTarget:movieWriter];

movieWriter.shouldPassthroughAudio = YES;
movieFile.audioEncodingTarget = movieWriter;
[movieFile enableSynchronizedEncodingUsingMovieWriter:movieWriter];

[movieWriter startRecording];
[movieFile startProcessing];
//Once recording is finished, you need to remove the movie recorder from the filter chain and close off the recording using code like the following:

[pixellateFilter removeTarget:movieWriter];
[movieWriter finishRecording];
```

我自己项目中用的Swift版本：

```
movieFile = GPUImageMovie(url: videoUrl)
//重新初始化滤镜，去掉不必要的链条
let pixellateFilter = ifFilter ?? GPUImageFilter()
//movie添加滤镜链
movieFile?.addTarget(pixellateFilter as! GPUImageInput)
let pathToMovie = URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("Documents/Movie.m4v")
//创建新路径存储渲染后的视频
unlink(pathToMovie.path)
let movieURL = URL(fileURLWithPath: pathToMovie.path)
//初始化Write
movieWriter = GPUImageMovieWriter(movieURL: movieURL, size: CGSize(width: 480.0, height: 640.0))
pixellateFilter.addTarget(movieWriter)
movieWriter?.shouldPassthroughAudio = true
movieFile?.audioEncodingTarget = movieWriter
movieFile?.enableSynchronizedEncoding(using: movieWriter)
//开始录制，开始渲染
movieWriter?.startRecording()
movieFile?.startProcessing()
//成功回调

weak var weakSelf = self
movieWriter?.completionBlock = {
pixellateFilter.removeTarget(weakSelf?.movieWriter)
weakSelf?.movieWriter?.finishRecording()
print("done")
UISaveVideoAtPathToSavedPhotosAlbum((movieURL.path), self,#selector(self.saveVideo(videoPath:didFinishSavingWithError:contextInfo:)), nil)
}
//失败回调
movieWriter?.failureBlock = {
error in
print(error ?? "")
ProgressHUD.showError("保存失败")
pixellateFilter.removeTarget(self.movieWriter)
self.movieWriter?.finishRecording()
}

```
存储成功后调用的saveVideo方法:

```
@objc  func saveVideo(videoPath:String,didFinishSavingWithError:NSError,contextInfo info:AnyObject){
print(didFinishSavingWithError.code)
if didFinishSavingWithError.code == 0{
print("success！！！！！！！！！！！！！！！！！")
//print(info)
ProgressHUD.showSuccess("保存成功")
self.dismiss(animated: true, completion: nil)
}else{
ProgressHUD.showError("保存失败")
}

}
```

好啦，实现方案到这里就结束啦，具体的细节可以看仓库中代码。


### 6.总结
其实做这样一个简单的相机Demo，我在写这篇文章的时候才发现其实也没有我一开始想象的那么难。我把时间很多时候还是花在了构建界面也好、和bug死磕也好。而且这也是我第一个使用AutoLayout布局的App,通过这次项目对snpkit的使用也称得上是熟练了。总而言之，我在学习中做到了这样的程度花了三周的时间，还是比较长的。接下来接触到真正的需求和有着严格时间要求的任务不知道自己能够做到什么程度。<br/>

嘛，写这篇博的目的还是给自己一个记录点。在日后的工作中遇到相似的问题能够快速地定位到。我会继续努力的233。
