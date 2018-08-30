
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
            let video_timeRange:CMTimeRange = CMTimeRange.init(start: kCMTimeZero, end: (videoAsset?.duration) ?? kCMTimeZero)
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
                try? a_compositionVideoTrack?.insertTimeRange(video_timeRange, of: aindex, at: CMTimeMakeWithSeconds(temDuration, 0))
            }
            if let audioindex = videoAsset?.tracks(withMediaType: .audio).first{
                try? audio?.insertTimeRange(video_timeRange, of: audioindex, at: CMTimeMakeWithSeconds(temDuration, 0))
            }
            temDuration += CMTimeGetSeconds(videoAsset?.duration ?? kCMTimeZero)
        }
        return mixComposition
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
