//
//  videoCheckViewController.swift
//  MyFirstGPUImage
//
//  Created by LiuYong on 2018/8/15.
//  Copyright © 2018年 LiuYong. All rights reserved.
//

import UIKit
import ProgressHUD
import AssetsLibrary
class videoCheckViewController: UIViewController,GPUImageMovieDelegate{
    
    var movie: GPUImageMovie!
    //播放
    var filter: GPUImageFilter!
    //滤镜
    var filterView: GPUImageView! = {
 
          let  filter = GPUImageView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT - 44))
    
        return filter
    }()
    //播放视图
    var writer: GPUImageMovieWriter!
    
    var url:URL!{
        didSet{
            saveVideo()
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let button = UIButton(frame: CGRect(x: 0, y: view.frame.size.height - 44, width: 44, height: 44))
        view.addSubview(button)
        button.backgroundColor = UIColor.red
        button.addTarget(self, action: #selector(self.changeFilter), for: .touchUpInside)

        
        
    }
    
    func playVideo() {
        /**
         */
        let sampleURL: URL? = url
        /**
         *  初始化 movie
         */
        if let anURL = sampleURL {
            movie = GPUImageMovie(url: anURL)
        }
        /**
         *  是否重复播放
         */
        movie.shouldRepeat = false
        movie.playAtActualSpeed = true
        /**
         *  设置代理 GPUImageMovieDelegate，只有一个方法 didCompletePlayingMovie
         */
        movie.delegate = self
        /**
         *  This enables the benchmarking mode, which logs out instantaneous and average frame times to the console
         *
         *  这使当前视频处于基准测试的模式，记录并输出瞬时和平均帧时间到控制台
         *
         *  每隔一段时间打印： Current frame time : 51.256001 ms，直到播放或加滤镜等操作完毕
         */
        movie.runBenchmark = true
        /**
         *  添加卡通滤镜
         */
        filter = GPUImageToonFilter()
        movie.addTarget(filter)
        /**
         *  添加显示视图
         */
        filter.addTarget(filterView)
        view.addSubview(filterView)
        /**
         *  视频处理后输出到 GPUImageView 预览时不支持播放声音，需要自行添加声音播放功能
         *
         *  开始处理并播放...
         */
        movie.startProcessing()

    }
    
    func didCompletePlayingMovie() {
        print("播放完成")
        let pathToMovie = URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("Documents/Movie.mov")
        unlink(pathToMovie.path)
        // If a file already exists, AVAssetWriter won't let you record new frames, so delete the old movie
        let movieURL = URL(fileURLWithPath: pathToMovie.path)
        print("pathToMovie:  \(pathToMovie)")
        writer = GPUImageMovieWriter(movieURL: movieURL, size: CGSize(width: 320, height: 480))
        writer.encodingLiveVideo = false
        writer.shouldPassthroughAudio = false
        filter.addTarget(writer)
        movie.enableSynchronizedEncoding(using: writer)
        movie.audioEncodingTarget = writer
        writer.startRecording()
        writer.completionBlock = {
            
        }
        writer.failureBlock = { error in
            if let anError = error {
                print("失败！！！ \(anError)")
            }
        }
    }

   
    
    @objc func changeFilter() {
        let index: Int = Int(arc4random() % 8)
        switchCameraFilter(index)
    }
    
    
    //  Converted to Swift 4 by Swiftify v4.1.6792 - https://objectivec2swift.com/
    func switchCameraFilter(_ index: Int) {
        movie.removeAllTargets()
        switch index {
        case 0:
            filter = GPUImageBilateralFilter()
        case 1:
            filter = GPUImageHueFilter()
        case 2:
            filter = GPUImageColorInvertFilter()
        case 3:
            filter = GPUImageSepiaFilter()
        case 4:
            filter = GPUImageGaussianBlurPositionFilter()
            (filter as? GPUImageGaussianBlurPositionFilter)?.blurRadius = 40.0 / 320.0
        case 5:
            filter = GPUImageMedianFilter()
        case 6:
            filter = GPUImageVignetteFilter()
        case 7:
            filter = GPUImageKuwaharaRadius3Filter()
        default:
            filter = GPUImageBilateralFilter()
        }
        movie.addTarget(filter)
        if filterView != nil {
            filterView.removeFromSuperview()
        }
        filter.addTarget(filterView)
        view.addSubview(filterView)
    }
    //  Converted to Swift 4 by Swiftify v4.1.6792 - https://objectivec2swift.com/
    func saveVideo() {
        let sampleURL: URL? = url
        // 初始化 movie
        if let anURL = sampleURL {
            movie = GPUImageMovie(url: anURL)
        }
        movie.shouldRepeat = false
        movie.playAtActualSpeed = true
        // 设置加滤镜视频保存路径
        let pathToMovie = URL(fileURLWithPath: "\(NSTemporaryDirectory())folder_video.mp4")
        unlink(pathToMovie.path)
        let movieURL = pathToMovie
        
        
        
        // 初始化
        writer = GPUImageMovieWriter(movieURL: movieURL, size: CGSize(width: 480, height: 640))
        writer.encodingLiveVideo = false
        writer.shouldPassthroughAudio = false

        // 添加滤镜
        let filter = GPUImageToonFilter()
        movie.addTarget(filter)
        filter.addTarget(writer)
        movie.enableSynchronizedEncoding(using: writer)
        writer.startRecording()
        movie.startProcessing()
        weak var weakSelf = self
        writer.completionBlock = {
            print("OK")
            filter.removeTarget(weakSelf?.writer)
            weakSelf?.writer.finishRecording()
        }
        writer.completionBlock()
    }


    
}

