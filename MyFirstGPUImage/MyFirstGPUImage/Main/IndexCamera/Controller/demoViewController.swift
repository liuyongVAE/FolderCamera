//
//  demoViewController.swift
//  MyFirstGPUImage
//
//  Created by LiuYong on 2018/8/10.
//  Copyright © 2018年 LiuYong. All rights reserved.
//

import Foundation
import UIKit
import GPUImage
import AVKit

class DemoViewController: UIViewController {
    
    var bjImage: UIImageView! = UIImageView()
    // MARK:- 创建视频源
    fileprivate lazy var camera: GPUImageVideoCamera = GPUImageVideoCamera(sessionPreset: AVCaptureSession.Preset.high.rawValue, cameraPosition: .back)
    
    // MARK:- 创建预览图层
    fileprivate lazy var preView: GPUImageView = GPUImageView(frame: self.view.bounds)
    
    fileprivate lazy var fileGroup: GPUImageFilterGroup =  {
        // 1、创建滤镜组
        let fileterGroup = GPUImageFilterGroup()
        
        // 2、创建滤镜（设置滤镜的引用关系）
        // 2-1、 初始化滤镜
        let bilateralFilter = GPUImageBilateralFilter() // 磨皮
        let exposureFilter = GPUImageExposureFilter() // 曝光
        let brightnessFilter = GPUImageBrightnessFilter() // 美白
        let satureationFilter = GPUImageSaturationFilter() // 饱和
        
        // 2-2、设置滤镜的引用关系
        bilateralFilter.addTarget(brightnessFilter)
        brightnessFilter.addTarget(exposureFilter)
        exposureFilter.addTarget(satureationFilter)
        
        // 3、设置滤镜组链的起点&&终点
        fileterGroup.initialFilters = [bilateralFilter]
        fileterGroup.terminalFilter = satureationFilter
        
        return fileterGroup
    }()
    
    // MARK:- 视频写入文件的路径
    var fileURL: URL {
        let url = URL(fileURLWithPath: "\(NSTemporaryDirectory())liyng_demo.mp4")
        unlink(url.path)
        return url
        
    }
    
    // MARK:- 创建写入对象
    fileprivate lazy var movieWrite: GPUImageMovieWriter = { [unowned self] in
        let writer = GPUImageMovieWriter(movieURL: self.fileURL, size: self.view.bounds.size)
        return writer!
        }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //1、设置camera方向
        camera.outputImageOrientation = .portrait // 输出是竖直方向
        camera.horizontallyMirrorFrontFacingCamera = true // 使用前置
        camera.delegate = self
        camera.audioEncodingTarget = movieWrite
        //2、创建预览图层
        view.insertSubview(preView, at: 0)
        
        //3、给视频源添加上滤镜组
        camera.addTarget(fileGroup)
        fileGroup.addTarget(preView)
        
        //4、设置writer属性
        movieWrite.encodingLiveVideo = true // 对视频进行编码
        fileGroup.addTarget(movieWrite) // 给写入的视频添加滤镜
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        // 开始采集画面
        camera.startCapture()
        
        // 开始录制
        movieWrite.startRecording()
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // 结束采集画面
        camera.stopCapture()
        
        // 结束录制
        movieWrite.finishRecording()
        // 播放视频
        let playerVc = AVPlayerViewController()
        playerVc.player = AVPlayer(url: fileURL)
        present(playerVc, animated: true, completion: nil)
    }
    
    @IBAction func startRecord(_ sender: Any) {
  
    }
    
    
    @IBAction func endRecord(_ sender: Any) {

    }
    
    @IBAction func rotateCamera(_ sender: Any) {
        camera.rotateCamera()
    }
    
    @IBAction func playVideo(_ sender: Any) {
        // 播放视频
        let playerVc = AVPlayerViewController()
        playerVc.player = AVPlayer(url: fileURL)
        present(playerVc, animated: true, completion: nil)
    }
    
}

extension DemoViewController: GPUImageVideoCameraDelegate {
    func willOutputSampleBuffer(_ sampleBuffer: CMSampleBuffer!) {
        print("采集到画面")
    }

}


