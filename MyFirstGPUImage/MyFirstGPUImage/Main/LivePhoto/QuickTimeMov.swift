
//
//  QuickTimeMov.swift
//  LoveLiver
//
//  Created by mzp on 10/10/15.
//  Copyright © 2015 mzp. All rights reserved.
//

import Foundation
import AVFoundation
import GPUImage

class QuickTimeMov {
    fileprivate let kKeyContentIdentifier =  "com.apple.quicktime.content.identifier"
    fileprivate let kKeyStillImageTime = "com.apple.quicktime.still-image-time"
    fileprivate let kKeySpaceQuickTimeMetadata = "mdta"
    fileprivate let path : String
    fileprivate let dummyTimeRange = CMTimeRangeMake(CMTimeMake(0, 1000), CMTimeMake(200, 3000))
    
    fileprivate lazy var asset : AVURLAsset = {
        let url = URL(fileURLWithPath: self.path)
        return AVURLAsset(url: url)
    }()
    
    init(path : String) {
        self.path = path
    }
    
    func readAssetIdentifier() -> String? {
        for item in metadata() {
            if item.key as? String == kKeyContentIdentifier &&
                item.keySpace!.rawValue == kKeySpaceQuickTimeMetadata {
                return item.value as? String
            }
        }
        return nil
    }
    
    func readStillImageTime() -> NSNumber? {
        if let track = track(AVMediaType.video) {
            let (reader, output) = try! self.reader(track, settings: nil)
            reader.startReading()
            
            while true {
                guard let buffer = output.copyNextSampleBuffer() else { return nil }
                if CMSampleBufferGetNumSamples(buffer) != 0 {
                    let group = AVTimedMetadataGroup(sampleBuffer: buffer)
                    for item in group?.items ?? [] {
                        if item.key as? String == kKeyStillImageTime &&
                            item.keySpace!.rawValue == kKeySpaceQuickTimeMetadata {
                            return item.numberValue
                        }
                    }
                }
            }
        }
        return nil
    }
    
    func write(_ dest : String, assetIdentifier : String ,filter:GPUImageOutput?) {
        
        var audioReader : AVAssetReader? = nil
        var audioWriterInput : AVAssetWriterInput? = nil
        var audioReaderOutput : AVAssetReaderOutput? = nil
        do {
            // --------------------------------------------------
            // reader for source video
            // --------------------------------------------------
            guard let track = self.track(AVMediaType.video) else {
                print("not found video track")
                return
            }
            let (reader, output) = try self.reader(track,
                                                   settings: [kCVPixelBufferPixelFormatTypeKey as String:
                                                    NSNumber(value: kCVPixelFormatType_32BGRA as UInt32)])
            // --------------------------------------------------
            // writer for mov
            // --------------------------------------------------
            let writer = try AVAssetWriter(outputURL: URL(fileURLWithPath: dest), fileType: .mov)
            
            writer.metadata = [metadataFor(assetIdentifier)]
            
            // video track
            let input = AVAssetWriterInput(mediaType: .video,
                                           outputSettings: videoSettings(track.naturalSize))
            input.expectsMediaDataInRealTime = true
            input.transform = track.preferredTransform
            writer.add(input)
            
            
            let url = URL(fileURLWithPath: self.path)
            let aAudioAsset : AVAsset = AVAsset(url: url)
            
            if aAudioAsset.tracks.count > 1 {
                print("Has Audio")
                //setup audio writer
                audioWriterInput = AVAssetWriterInput(mediaType: .audio, outputSettings: nil)
                
                audioWriterInput?.expectsMediaDataInRealTime = false
                if writer.canAdd(audioWriterInput!){
                    writer.add(audioWriterInput!)
                }
                //setup audio reader
                let audioTrack:AVAssetTrack = aAudioAsset.tracks(withMediaType: .audio).first!
                audioReaderOutput = AVAssetReaderTrackOutput(track: audioTrack, outputSettings: nil)
                
                do{
                    audioReader = try AVAssetReader(asset: aAudioAsset)
                }catch{
                    fatalError("Unable to read Asset: \(error) : ")
                }
                //let audioReader:AVAssetReader = AVAssetReader(asset: aAudioAsset, error: &error)
                if (audioReader?.canAdd(audioReaderOutput!))! {
                    audioReader?.add(audioReaderOutput!)
                } else {
                    print("cant add audio reader")
                }
            }
            
            // metadata track
            let adapter = metadataAdapter()
            writer.add(adapter.assetWriterInput)
            
            // --------------------------------------------------
            // creating video
            // --------------------------------------------------
            writer.startWriting()
            reader.startReading()
            writer.startSession(atSourceTime: kCMTimeZero)
            
            // write metadata track
            adapter.append(AVTimedMetadataGroup(items: [metadataForStillImageTime()],
                                                timeRange: dummyTimeRange))
            
            // write video track
            input.requestMediaDataWhenReady(on: DispatchQueue(label: "assetVideoWriterQueue", attributes: [])) {
                while(input.isReadyForMoreMediaData) {
                    if reader.status == .reading {
                        if let buffer = output.copyNextSampleBuffer() {
                            if !input.append(buffer) {
                                print("cannot write: \((describing: writer.error?.localizedDescription))")
                                reader.cancelReading()
                            }
                        }
                    } else {
                        input.markAsFinished()
                        if reader.status == .completed && aAudioAsset.tracks.count > 1 {
                            audioReader?.startReading()
                            writer.startSession(atSourceTime: kCMTimeZero)
                            let media_queue = DispatchQueue(label: "assetAudioWriterQueue", attributes: [])
                            audioWriterInput?.requestMediaDataWhenReady(on: media_queue) {
                                while (audioWriterInput?.isReadyForMoreMediaData)! {
                                    //DTLog("Second loop")
                                    let sampleBuffer2:CMSampleBuffer? = audioReaderOutput?.copyNextSampleBuffer()
                                    if audioReader?.status == .reading && sampleBuffer2 != nil {
                                        if !(audioWriterInput?.append(sampleBuffer2!))! {
                                            audioReader?.cancelReading()
                                        }
                                    }else {
                                        audioWriterInput?.markAsFinished()
                                        print("Audio writer finish")
                                        writer.finishWriting() {
                                            if let e = writer.error {
                                                print("cannot write: \(e)")
                                            } else {
                                                print("finish writing.")
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        else {
                            print("Video Reader not completed")
                            writer.finishWriting() {
                                if let e = writer.error {
                                    print("cannot write: \(e)")
                                } else {
                                    print("finish writing.")
                                }
                            }
                        }
                    }
                }
            }
            while writer.status == .writing {
                RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.5))
            }
            if let e = writer.error {
                print("cannot write: \(e)")
            }
        } catch {
            print("error")
        }
    }
    
    
    
    
//    func write(toDirectory path: String?, withAssetIdentifier assetIdentifier: String?, filter: (GPUImageOutput & GPUImageInput)?) {
//        
//        let track: AVAssetTrack? = self.track(AVMediaType.video)
//        let audioTrack: AVAssetTrack? = self.track(AVMediaType.audio)
//        if track == nil {
//            return
//        }
//        var output: AVAssetReaderOutput? = nil
//        if let aTrack = track {
//            output = AVAssetReaderTrackOutput(track: aTrack, outputSettings: [kCVPixelBufferPixelFormatTypeKey as String: Int(truncating: NSNumber(kCVPixelFormatType_32BGRA))])
//        }
//        //声音输出
//        let audioDic = [AVFormatIDKey: kAudioFormatLinearPCM, AVLinearPCMIsBigEndianKey: false, AVLinearPCMIsFloatKey: false, AVLinearPCMBitDepthKey: 16] as [String : Any]
//
//        var audioOutput: AVAssetReaderTrackOutput? = nil
//        if let aTrack = audioTrack {
//            audioOutput = AVAssetReaderTrackOutput(track: aTrack, outputSettings: audioDic)
//        }
//        var error: Error?
//        let reader = try? AVAssetReader(asset: asset)
//        if let anOutput = output {
//            reader?.add(anOutput)
//        }
//        if let anOutput = audioOutput {
//            reader?.add(anOutput)
//        }
//
//        let input = AVAssetWriterInput(mediaType: .video, outputSettings: videoSettings(track?.naturalSize))
//        //声音输入
//        let audioSettings = [
//            AVFormatIDKey : kAudioFormatMPEG4AAC,
//            AVNumberOfChannelsKey : 1,
//            AVSampleRateKey : 44100,
//            AVEncoderBitRateKey : 128000
//        ]
//
//        var audioInput = AVAssetWriterInput(mediaType: audioTrack.mediaType, outputSettings: audioSettings)
//        input.expectsMediaDataInRealTime = true
//        input.transform = track.preferredTransform
//        var error_two: Error?
//        var writer = try? AVAssetWriter(url: URL(fileURLWithPath: path), fileType: .mov)
//
//        writer?.metadata = [metaData(withAssetIdentifier: assetIdentifier)]
//        writer?.add(input)
//        writer?.add(audioInput)
//        //pixel
//        var sourcePixelBufferAttributesDictionary = [
//            kCVPixelBufferPixelFormatTypeKey : kCVPixelFormatType_32BGRA
//        ]
//        var adaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: input, sourcePixelBufferAttributes: sourcePixelBufferAttributesDictionary as? [String : Any])
//
//        var adapter: AVAssetWriterInputMetadataAdaptor? = metadataAdapter()
//        if let anInput = adapter?.assetWriterInput {
//            writer?.add(anInput)
//        }
//
//        writer?.startWriting()
//        reader.startReading()
//        writer?.startSession(atSourceTime: kCMTimeZero)
//
//        var dummyTimeRange: CMTimeRange = CMTimeRangeMake(CMTimeMake(0, 1000), CMTimeMake(200, 3000))
//        if let aTime = [metadataForStillImageTime()] as? [AVMetadataItem] {
//            adapter?.append(AVTimedMetadataGroup(items: aTime, timeRange: dummyTimeRange))
//        }
//        //不加滤镜的情况
//        if type(of: filter) === GPUImageSaturationFilter.self {
//            var innerFilter = filter as? GPUImageSaturationFilter
//            if innerFilter?.saturation == 1 {
//                filter = nil
//            }
//            //  The converted code is limited to 2 KB.
//            //  Upgrade your plan to remove this limitation.
//            //
//            //  Converted to Swift 4 by Swiftify v4.1.6809 - https://objectivec2swift.com/
//            var readDataQueue = DispatchQueue(label: "readDataQueue")
//            readDataQueue.async(execute: {
//                while reader.status == .reading {
//                    var videoBuffer = output.copyNextSampleBuffer()
//                    var audioBuffer = audioOutput.copyNextSampleBuffer()
//
//                    var startTime: CMTime = CMSampleBufferGetPresentationTimeStamp(videoBuffer)
//                    var image: UIImage? = MTImageTool.image(from: videoBuffer)
//
//                    var buffer: CVPixelBuffer?
//                    if image != nil && filter {
//                        image = filter.image(byFilteringImage: image)
//                        buffer = MTImageTool.pixelBuffer(from: image?.cgImage) as? CVPixelBuffer?
//                    } else if image != nil && !filter {
//                        buffer = MTImageTool.pixelBuffer(from: image?.cgImage) as? CVPixelBuffer?
//                    } else {
//                        //                CFRelease(buffer);
//                        continue
//                    }
//
//                    if buffer != nil {
//                        while !input.isReadyForMoreMediaData || !audioInput.isReadyForMoreMediaData {
//                            usleep(1)
//                        }
//                        if audioBuffer != nil {
//                            if let aBuffer = audioBuffer {
//                                audioInput.append(aBuffer)
//                            }
//                        }
//                        if let aBuffer = buffer {
//                            if !adaptor.append(aBuffer, withPresentationTime: startTime) {
//                                print("fail")
//                            }
//                        }
//                    } else {
//                        continue
//                    }
//                }
//                DispatchQueue.main.sync(execute: {
//                    writer.finishWriting(completionHandler: {
//                        //结束发通知
//                        NotificationCenter.default.post(name: NSNotification.Name("MTAudioVideoFinished"), object: self)
//
//                    })
//                })
//            })
//
//
//            while writer.status == .writing {
//                RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.5))
//            }
//
//
//
//
//        }
//    }
//
//    //  The converted code is limited to 2 KB.
//    //  Upgrade your plan to remove this limitation.
//    //
//    //  Converted to Swift 4 by Swiftify v4.1.6809 - https://objectivec2swift.com/
//    func track(_ type: String?) -> AVAssetTrack? {
//        return asset.tracks(withMediaType: AVMediaType(type)).first
//    }
//
//    func videoSetting(_ size: CGSize) -> [AnyHashable : Any]? {
//        return [AVVideoCodecKey: AVVideoCodecH264, AVVideoWidthKey: Float(size.width), AVVideoHeightKey: Float(size.height)]
//    }
//
//    func metaData(withAssetIdentifier assetIdentifier: String?) -> AVMetadataItem? {
//        let item = AVMutableMetadataItem.metadataItem as? AVMutableMetadataItem
//        item?.key = kKeyContentIdentifier
//        item?.keySpace = kKeySpaceQuickTimeMetadata
//        item?.value = assetIdentifier
//        item?.dataType = "com.apple.metadata.datatype.UTF-8"
//        return item
//    }
//
//    func metadataForStillImageTime() -> AVMetadataItem? {
//        let item = AVMutableMetadataItem.metadataItem as? AVMutableMetadataItem
//        item?.key = kKeyStillImageTime
//        item?.keySpace = kKeySpaceQuickTimeMetadata
//        item?.value = nil
//        item?.dataType = "com.apple.metadata.datatype.int8"
//        return item
//    }
//
    
    
    
    
    
    
    
    
    //s-----------
    
    fileprivate func metadata() -> [AVMetadataItem] {
        return asset.metadata(forFormat: .quickTimeMetadata)
    }
    
    fileprivate func track(_ mediaType : AVMediaType) -> AVAssetTrack? {
        return asset.tracks(withMediaType: mediaType).first
    }
    
    fileprivate func reader(_ track : AVAssetTrack, settings: [String:AnyObject]?) throws -> (AVAssetReader, AVAssetReaderOutput) {
        let output = AVAssetReaderTrackOutput(track: track, outputSettings: settings)
        let reader = try AVAssetReader(asset: asset)
        reader.add(output)
        return (reader, output)
    }
    
    fileprivate func metadataAdapter() -> AVAssetWriterInputMetadataAdaptor {
        let spec : NSDictionary = [
            kCMMetadataFormatDescriptionMetadataSpecificationKey_Identifier as NSString:
            "\(kKeySpaceQuickTimeMetadata)/\(kKeyStillImageTime)",
            kCMMetadataFormatDescriptionMetadataSpecificationKey_DataType as NSString:
            "com.apple.metadata.datatype.int8"            ]
        
        var desc : CMFormatDescription? = nil
        CMMetadataFormatDescriptionCreateWithMetadataSpecifications(kCFAllocatorDefault, kCMMetadataFormatType_Boxed, [spec] as CFArray, &desc)
        let input = AVAssetWriterInput(mediaType: .metadata,
                                       outputSettings: nil, sourceFormatHint: desc)
        return AVAssetWriterInputMetadataAdaptor(assetWriterInput: input)
    }
    
    fileprivate func videoSettings(_ size : CGSize) -> [String:AnyObject] {
        return [
            AVVideoCodecKey: AVVideoCodecH264 as AnyObject,
            AVVideoWidthKey: size.width as AnyObject,
            AVVideoHeightKey: size.height as AnyObject
        ]
    }
    
    fileprivate func metadataFor(_ assetIdentifier: String) -> AVMetadataItem {
        let item = AVMutableMetadataItem()
        item.key = kKeyContentIdentifier as (NSCopying & NSObjectProtocol)?
        item.keySpace = AVMetadataKeySpace(rawValue: kKeySpaceQuickTimeMetadata)
        item.value = assetIdentifier as (NSCopying & NSObjectProtocol)?
        item.dataType = "com.apple.metadata.datatype.UTF-8"
        return item
    }
    
    fileprivate func metadataForStillImageTime() -> AVMetadataItem {
        let item = AVMutableMetadataItem()
        item.key = kKeyStillImageTime as (NSCopying & NSObjectProtocol)?
        item.keySpace = AVMetadataKeySpace(rawValue: kKeySpaceQuickTimeMetadata)
        item.value = 0 as (NSCopying & NSObjectProtocol)?
        item.dataType = "com.apple.metadata.datatype.int8"
        return item
    }
}
