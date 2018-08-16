////
////  new.swift
////  MyFirstGPUImage
////
////  Created by LiuYong on 2018/8/16.
////  Copyright © 2018年 LiuYong. All rights reserved.
////
//
//import Foundation
//import UIKit
//import GPUImage
//import AssetsLibrary
//
//
//class ExistsVideoFilterViewController: UIViewController {
//
//    var filterNum: Int = 0
//    let filters = [
//        GPUImageSepiaFilter(),
//        GPUImagePolkaDotFilter(),
//        GPUImageGrayscaleFilter()
//    ]
//
//    var filter: GPUImageFilter!
//
//    var movieWriter:GPUImageMovieWriter!
//    var movieFile:GPUImageMovie!
//    var newFilePath : String!
//
//    private var myButtonStart : UIButton!
//    private var myButtonStop : UIButton!
//
//    //var barView = MBCircularProgressBarView()
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        filter = filters[filterNum]
//
//        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
//        let documentsDirectory = paths[0] as! String
//        let filePath : String? = "\(documentsDirectory)/temp.mp4"
//        let mediaURL : NSURL = NSURL(fileURLWithPath: filePath!)!
//
//        //表示用ビュー
//        var fileView = GPUImageView()
//        fileView.frame = CGRectMake(0, 0, 480, 480)
//
//        //保存用パス
//        newFilePath = "\(documentsDirectory)/newTemp.mp4"
//
//        //一時保存先を空にしておく
//        var contentsPath = Path(documentsDirectory)
//        for path in contentsPath.contents! {
//            if(path.toString() == newFilePath){
//                path.remove()
//            }
//        }
//        let movieURL = NSURL(fileURLWithPath: newFilePath!)!
//
//        self.movieWriter = GPUImageMovieWriter(movieURL: movieURL, size: CGSize(width: 480, height: 480),fileType:AVFileTypeMPEG4, outputSettings:nil)
//        //"Couldn't write a frame" エラーが出ないための一行
//        self.movieWriter.assetWriter.movieFragmentInterval = kCMTimeInvalid
//        self.movieWriter.shouldPassthroughAudio = true
//        movieWriter.encodingLiveVideo = true
//
//
//        movieFile = GPUImageMovie(URL: mediaURL)
//        movieFile.playAtActualSpeed = true
//        //movieFile.audioEncodingTarget = movieWriter!
//
//        //フィルター関連
//        filter.addTarget(fileView)
//        //self.view.addSubview(fileView)
//        movieFile.addTarget(filter)
//        filter.addTarget(movieWriter)
//
//        makeButton()
//        makeBar()
//
//    }
//
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }
//
//
//    func onClickStartButton() {
//        movieFile.startProcessing()
//        movieWriter.startRecording()
//        println("started")
//        var timer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: Selector("printProgress"), userInfo: nil, repeats: false)
//    }
//
//    func printProgress(){
//        //規定のレンダリング時間に達するまでは0.5秒に一度進捗を監視する
//        barView.percent = CGFloat(movieFile.progress*100)
//        println(movieFile.progress)
//        if(movieFile.progress >= 1){
//            onClickStopButton()
//        }else{
//            var timer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: Selector("printProgress"), userInfo: nil, repeats: false)
//        }
//    }
//
//    func onClickStopButton() {
//        filter.removeTarget(self.movieWriter!)
//        movieWriter!.finishRecording()
//        savePhotoAlbum(newFilePath)
//        println("completed")
//    }
//
//    func savePhotoAlbum(filePath:String!){
//
//        UISaveVideoAtPathToSavedPhotosAlbum(filePath, self, Selector("filePath:didFinishSavingWithError:contextInfo:"), nil)
//    }
//
//    func filePath(filePath: String!, didFinishSavingWithError: NSError, contextInfo:UnsafePointer<Void>)       {
//
//        if let error = didFinishSavingWithError as NSError? {
//            println("error")
//        }
//        else{
//            let removePath = Path(newFilePath)
//            removePath.remove()
//            println("success!")
//        }
//    }
//
//    func makeButton(){
//
//        // UIボタンを作成.
//        myButtonStart = UIButton(frame: CGRectMake(0,0,120,50))
//        myButtonStop = UIButton(frame: CGRectMake(0,0,120,50))
//
//        myButtonStart.backgroundColor = UIColor.redColor();
//        myButtonStop.backgroundColor = UIColor.grayColor();
//
//        myButtonStart.layer.masksToBounds = true
//        myButtonStop.layer.masksToBounds = true
//
//        myButtonStart.setTitle("記録", forState: .Normal)
//        myButtonStop.setTitle("停止", forState: .Normal)
//
//        myButtonStart.layer.cornerRadius = 20.0
//        myButtonStop.layer.cornerRadius = 20.0
//
//        myButtonStart.layer.position = CGPoint(x: self.view.bounds.width/2 - 70, y:self.view.bounds.height-50)
//        myButtonStop.layer.position = CGPoint(x: self.view.bounds.width/2 + 70, y:self.view.bounds.height-50)
//
//        myButtonStart.addTarget(self, action: "onClickStartButton", forControlEvents: .TouchUpInside)
//        myButtonStop.addTarget(self, action: "onClickStopButton", forControlEvents: .TouchUpInside)
//
//        // UIボタンをViewに追加.
//        self.view.addSubview(myButtonStart);
//        self.view.addSubview(myButtonStop);
//
//    }
//
//    func makeBar(){
//        //プログレスバー
//        barView.percent = 0
//        barView.fontColor = UIColor.orangeColor()
//        barView.progressRotationAngle = 0
//        barView.progressAngle = 100
//        barView.progressLineWidth = 10
//        barView.progressColor = UIColor.redColor()
//        barView.progressStrokeColor = UIColor.redColor()
//        barView.emptyLineColor = UIColor.orangeColor()
//        barView.emptyLineWidth = 10
//        barView.backgroundColor = UIColor.clearColor()
//        barView.frame = CGRectMake(self.view.bounds.width/2-100, self.view.bounds.height/2-200, 200, 200)
//        self.view.addSubview(barView)
//
//    }
//
//}
