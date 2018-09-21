
//
//  File.swift
//  MyFirstGPUImage
//
//  Created by LiuYong on 2018/8/20.
//  Copyright © 2018年 LiuYong. All rights reserved.
//

import Foundation
import AVFoundation
import ProgressHUD

class SaveVieoManager:NSObject{
    
    //    static let shared:SaveVieoManager = {
    //        let m = SaveVieoManager()
    //        return m
    //
    //    }()
    //
    var videoUrls:[URL] = [URL]()
    
    
    init(urls:[URL]) {
        self.videoUrls = urls
    }
    
    func getTopUrl()->URL?{
        return videoUrls[(videoUrls.endIndex)]
    }
    
    func deleteCurrentUrl(){
        videoUrls.removeLast()
    }
    
    func combineVideos()->AVMutableComposition{
        let mixComposition = AVMutableComposition()
        
        let a_compositionVideoTrack:AVMutableCompositionTrack? = mixComposition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
        let audio = mixComposition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
        var temDuration = Float64(0.0)
        for i in 0...videoUrls.count-1{
            var videoAsset:AVURLAsset?
            videoAsset = AVURLAsset.init(url: videoUrls[i])

            let tt = videoAsset!.duration
            let getLengthOfVideo2 = Double(tt.value)/Double(tt.timescale)
            print(getLengthOfVideo2)
            
            let video_timeRange:CMTimeRange = CMTimeRange.init(start: CMTime.zero, end: (videoAsset?.duration) ?? CMTime.zero)
            /**
             *  依次加入每个asset
             *
             *  @param TimeRange 加入的asset持续时间
             *  @param Track     加入的asset类型,这里都是video
             *  @param Time      从哪个时间点加入asset,这里用了CMTime下面的CMTimeMakeWithSeconds(tmpDuration, 0),timesacle为0
             *
             */
            //            var error:Error?
            //            var tbBool:Bool? = nil
            if let aindex = videoAsset?.tracks(withMediaType: .video).first{
                try? a_compositionVideoTrack?.insertTimeRange(video_timeRange, of: aindex, at: CMTimeMakeWithSeconds(temDuration, preferredTimescale: 0))
            }
            if let audioindex = videoAsset?.tracks(withMediaType: .audio).first{
                try? audio?.insertTimeRange(video_timeRange, of: audioindex, at: CMTimeMakeWithSeconds(temDuration, preferredTimescale: 0))
            }
            temDuration += CMTimeGetSeconds(videoAsset?.duration ?? CMTime.zero)

        }
        let tt =  mixComposition.tracks[0].asset?.duration
        let length = Double(tt!.value)/Double(tt!.timescale)
        print("总长度:",length)
        return mixComposition
    }
    
    
    /// 剪辑视频
    ///
    /// - Parameters:
    ///   - frontOffset: 前面剪几秒
    ///   - endOffset: 后面剪几秒
    ///   - index: url的下标
    /// - Returns: 合成
    func cutLiveVideo(frontOffset:Float64,endOffset:Float64,index:Int)->AVMutableComposition{
        let composition = AVMutableComposition()
        // Create the video composition track.
        let compositionVideoTrack: AVMutableCompositionTrack? = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
        // Create the audio composition track.
        let compositionAudioTrack: AVMutableCompositionTrack? = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
        let pathUrl = videoUrls[index]
        let asset = AVURLAsset(url: pathUrl, options: nil)
        
        let videoTrack: AVAssetTrack = asset.tracks(withMediaType: .video)[0]
        let audioTrack: AVAssetTrack = asset.tracks(withMediaType: .audio)[0]
        compositionVideoTrack?.preferredTransform = videoTrack.preferredTransform
        
        // CMTime
        let trackDuration: CMTime = videoTrack.timeRange.duration
        let trackTimescale: CMTimeScale = trackDuration.timescale
        // 用timescale构造前后截取位置的CMTime
        let startTime: CMTime = CMTimeMakeWithSeconds(frontOffset, preferredTimescale: trackTimescale)
        let endTime: CMTime = CMTimeMakeWithSeconds(endOffset, preferredTimescale: trackTimescale)
        let intendedDuration: CMTime = CMTimeSubtract(asset.duration, CMTimeAdd(startTime, endTime))

        try? compositionVideoTrack?.insertTimeRange(CMTimeRangeMake(start: startTime, duration: intendedDuration), of: videoTrack, at: CMTime.zero)
        try? compositionAudioTrack?.insertTimeRange(CMTimeRangeMake(start: startTime, duration: intendedDuration), of: audioTrack, at: CMTime.zero)

        return composition
    
    }
    
    
    func combineLiveVideos(success:@escaping(_ mixComposition:AVMutableComposition)->()){

            //剪第一段
                //求liveVideo第二段长度n,需要用1.5 - 此长度作为第一段需要减去的长度
                if videoUrls.count > 2{

                    //最后一段剪黑屏
                    let getBlack =  0.06
                    //减黑屏
                    let video3Composition = cutLiveVideo(frontOffset: 0, endOffset: Float64(getBlack), index: 2)
                    let newUrl3 = URL(fileURLWithPath: "\(NSTemporaryDirectory())foldercut_3.mp4")
                    unlink(newUrl3.path)
                    videoUrls[2] = newUrl3

                    var videoAsset2:AVURLAsset?
                    videoAsset2 = AVURLAsset.init(url: videoUrls[1])
                    let tt = videoAsset2!.duration
                    let getLengthOfVideo2 = Double(tt.value)/Double(tt.timescale)
                    //减掉开始 n 秒
                    let video1Composition = cutLiveVideo(frontOffset: getLengthOfVideo2, endOffset: 0.0, index: 0)
                    let newUrl = URL(fileURLWithPath: "\(NSTemporaryDirectory())foldercut_1.mp4")
                    unlink(newUrl.path)
                    videoUrls[0] = newUrl
                    //裁剪完第一段视频后，开始进行三段视频的合成
                    store(video1Composition, storeUrl: newUrl, success: {
                        self.store(video3Composition, storeUrl: newUrl3, success: {
                            let mixCom = self.combineVideos()
                            success(mixCom)
                        })
                    })
                    
                }else if videoUrls.count<3{

                    let getBlack =  0.06
                    //减黑屏
                    let video3Composition = cutLiveVideo(frontOffset: 0, endOffset: Float64(getBlack), index: 1)
                    let newUrl3 = URL(fileURLWithPath: "\(NSTemporaryDirectory())foldercut_3.mp4")
                    unlink(newUrl3.path)
                    videoUrls[1] = newUrl3
                    //裁剪完第一段视频后，开始进行三段视频的合成
                    store(video3Composition, storeUrl: newUrl3, success: {
                            let mixCom = self.combineVideos()
                            success(mixCom)
                    })
                }

    }
    
    
    
    /**
     *  存储合成的视频
     *
     *  @param mixComposition mixComposition参数
     *  @param storeUrl       存储的路径
     *  @param successBlock   successBlock
     *  @param failureBlcok   failureBlcok
     */
    func store(_ mixComposition:AVMutableComposition,storeUrl:URL,success successBlock:@escaping ()->()){
        //weak var weakSelf = self
        var assetExport: AVAssetExportSession? = nil
        assetExport = AVAssetExportSession.init(asset: mixComposition, presetName: AVAssetExportPreset640x480)
        assetExport?.outputFileType = AVFileType("com.apple.quicktime-movie")
        assetExport?.outputURL = storeUrl
        assetExport?.exportAsynchronously(completionHandler: {
            successBlock()
           // UISaveVideoAtPathToSavedPhotosAlbum((storeUrl.path), self,#selector(weakSelf?.saveVideo(videoPath:didFinishSavingWithError:contextInfo:)), nil)
        })
        
    }
    

    
    @objc  func saveVideo(videoPath:String,didFinishSavingWithError:NSError,contextInfo info:AnyObject){
        print(didFinishSavingWithError.code)
        if didFinishSavingWithError.code == 0{
            print("success！！！！！！！！！！！！！！！！！")
            //print(info)
            ProgressHUD.showSuccess("保存成功")
        }else{
            ProgressHUD.showError("保存失败")
        }
        
    }
    
    
}
