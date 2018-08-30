//
//  LivePhotoPreviewViewController.swift
//  MyFirstGPUImage
//
//  Created by LiuYong on 2018/8/28.
//  Copyright © 2018年 LiuYong. All rights reserved.
//

import Foundation
import Photos
import ProgressHUD
import PhotosUI
import MobileCoreServices


@available(iOS 9.1, *)
class LivePhotoPreviewController:UIViewController{

    lazy var livePhotoView: PHLivePhotoView =  {
        let v = PHLivePhotoView()
        return v
    }()
    
    var furl:URL!
    
    init(url:URL) {
        furl = url
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(livePhotoView)
        livePhotoView.snp.makeConstraints({
            make in
            make.width.height.left.top.equalToSuperview()
        })
        loadVideoWithVideoURL(furl)
        
        
    }
    
    
    func loadVideoWithVideoURL(_ videoURL: URL) {
        livePhotoView.livePhoto = nil
        let asset = AVURLAsset(url: videoURL)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        let time = NSValue(time: CMTimeMakeWithSeconds(CMTimeGetSeconds(asset.duration)/2, asset.duration.timescale))
        generator.generateCGImagesAsynchronously(forTimes: [time]) { [weak self] _, image, _, _, _ in
            
            //生成livePhoto封面图
            if let image = image, let data = UIImagePNGRepresentation(UIImage(cgImage: image)) {
                let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
                let imageURL = urls[0].appendingPathComponent("image.jpg")
                try? data.write(to: imageURL, options: [.atomic])
                
                let image = imageURL.path
                let mov = videoURL.path
                let output = FilePaths.VidToLive.livePath
                let assetIdentifier = UUID().uuidString
                let _ = try? FileManager.default.createDirectory(atPath: output, withIntermediateDirectories: true, attributes: nil)
                do {
                    try FileManager.default.removeItem(atPath: output + "/IMG.JPG")
                    try FileManager.default.removeItem(atPath: output + "/IMG.MOV")
                    
                } catch {
                    
                }
                JPEG(path: image).write(output + "/IMG.JPG",
                                        assetIdentifier: assetIdentifier)
                
                QuickTimeMov(path: mov).write(output + "/IMG.MOV",
                                              assetIdentifier: assetIdentifier, filter: nil)

                 DispatchQueue.main.sync {
                    PHLivePhoto.request(withResourceFileURLs: [ URL(fileURLWithPath: FilePaths.VidToLive.livePath + "/IMG.MOV"), URL(fileURLWithPath: FilePaths.VidToLive.livePath + "/IMG.JPG")],
                                        placeholderImage: nil,
                                        targetSize: self!.view.bounds.size,
                                        contentMode: PHImageContentMode.aspectFit,
                                        resultHandler: { (livePhoto, info) -> Void in
                                            self?.livePhotoView.livePhoto = livePhoto
                                            self?.exportLivePhoto()
                    })
                }
            }
        }
    }
    
    
    //保存livePhoto
    func exportLivePhoto () {
        PHPhotoLibrary.shared().performChanges({ () -> Void in
            let creationRequest = PHAssetCreationRequest.forAsset()
            let options = PHAssetResourceCreationOptions()
            
            
            creationRequest.addResource(with: PHAssetResourceType.pairedVideo, fileURL: URL(fileURLWithPath: FilePaths.VidToLive.livePath + "/IMG.MOV"), options: options)
            creationRequest.addResource(with: PHAssetResourceType.photo, fileURL: URL(fileURLWithPath: FilePaths.VidToLive.livePath + "/IMG.JPG"), options: options)
            
        }, completionHandler: { (success, error) -> Void in
            if !success {
               // DTLog((error?.localizedDescription)!)
            }
        })
    }
    
    
    
    
}


