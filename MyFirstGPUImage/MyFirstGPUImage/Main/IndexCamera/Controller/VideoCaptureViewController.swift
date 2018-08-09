//
//  VideoCaptureViewController.swift
//  MyFirstGPUImage
//
//  Created by LiuYong on 2018/8/7.
//  Copyright © 2018年 LiuYong. All rights reserved.
//

import UIKit

class VideoCaptureViewController: UIViewController {

    
    var videoCamera: GPUImageVideoCamera!
    // 捕获画面
    var imageView: GPUImageView!
    // 展示画面
    var movieWriter: GPUImageMovieWriter!
    // 视频编解码
    var temPath = ""
    // 录制视频的临时缓存地址
    var filter: GPUImageToonFilter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let width = view.bounds.size.width
        let height = view.bounds.size.height
        imageView = GPUImageView(frame: CGRect(x: 0, y: 0, width: width, height: width))
        imageView.center = view.center
        view.addSubview(imageView)
        // 卡通滤镜效果（黑色描边）
        filter = GPUImageToonFilter()
        videoCamera = GPUImageVideoCamera(sessionPreset: AVCaptureSession.Preset.vga640x480.rawValue, cameraPosition: AVCaptureDevice.Position.front)
        videoCamera.outputImageOrientation = UIInterfaceOrientation.portrait
        videoCamera.addTarget(filter)
        filter.addTarget(imageView)
        // GPUImageVideoCamera 开始捕获画面展示在 GPUImageView
        videoCamera.startCapture()
        // 调解滤镜值
        let slider = UISlider(frame: CGRect(x: 50, y: imageView.frame.origin.y + imageView.frame.size.height + 30, width: width - 100, height: 30))
        slider.value = 0.2
        slider.addTarget(self, action: #selector(self.sliderValueChanged(_:)), for: .valueChanged)
        view.addSubview(slider)
        let recordBtn = UIButton(type: .custom)
        recordBtn.frame = CGRect(x: view.bounds.size.width / 2.0 - 80, y: height - 80, width: 60, height: 60)
        recordBtn.setTitleColor(UIColor.orange, for: .normal)
        recordBtn.setTitle("开始", for: .normal)
        recordBtn.setTitle("暂停", for: .selected)
        recordBtn.addTarget(self, action: #selector(self.recordBtnAction(_:)), for: .touchUpInside)
        view.addSubview(recordBtn)
        let lensBtn = UIButton(type: .custom)
        lensBtn.frame = CGRect(x: view.bounds.size.width / 2.0 + 20, y: height - 80, width: 60, height: 60)
        lensBtn.setTitleColor(UIColor.orange, for: .normal)
        lensBtn.setTitle("后置", for: .normal)
        lensBtn.setTitle("前置", for: .selected)
        lensBtn.addTarget(self, action: #selector(self.lensBtnAction(_:)), for: .touchUpInside)
        view.addSubview(lensBtn)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @objc func sliderValueChanged(_ sender: UISlider?) {
        filter.threshold = CGFloat(sender?.value ?? 0)
    }
    
    @objc func recordBtnAction(_ sender: UIButton?) {
        if sender?.isSelected ?? false {
            // 录像状态
            movieWriter.finishRecording()
            UISaveVideoAtPathToSavedPhotosAlbum(temPath, nil, nil, nil)
            videoCamera.removeTarget(movieWriter)
        } else {
            // 没有录像
//            var documentsDirectory = URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("Documents").absoluteString
//            var path = URL(fileURLWithPath: documentsDirectory).appendingPathComponent("test").absoluteString
//            var fileManage = FileManager.default as?  FileManager
//            //先判断这个文件夹是否存在,如果不存在则创建,否则不创建
//            if !(fileManage?.fileExists(atPath: path) ?? false) {
//               try? fileManage?.createDirectory(atPath: path, withIntermediateDirectories: false, attributes: [:])
//            }else{
//               try? fileManage?.removeItem(atPath: path)
//            }
            //            do{
            //                try fileManage?.removeItem(atPath: temPath)
            //            }catch let error as NSError{
            //                print(error)
            //            }

            temPath = URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("Documents/Movie2213.m4v").absoluteString
            // 判断路径是否存在，如果存在就删除路径下的文件，否则是没法缓存新的数据的。
            let movieURL = URL(fileURLWithPath: temPath)
            let uu = NSURL.fileURL(withPath: NSHomeDirectory()).appendingPathComponent("stream.mp4")
            unlink(uu.path)
            movieWriter = GPUImageMovieWriter(movieURL: movieURL, size: CGSize(width: 640.0, height: 480.0))
            movieWriter.setHasAudioTrack(true, audioSettings: nil)
            filter.addTarget(movieWriter)
            self.videoCamera.audioEncodingTarget = self.movieWriter
            self.movieWriter.startRecording()
            
          
          

        }
        sender?.isSelected = !(sender?.isSelected ?? false)
    }
    
    @objc func lensBtnAction(_ sender: UIButton?) {
        videoCamera.rotateCamera()
        sender?.isSelected = !(sender?.isSelected ?? false)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
