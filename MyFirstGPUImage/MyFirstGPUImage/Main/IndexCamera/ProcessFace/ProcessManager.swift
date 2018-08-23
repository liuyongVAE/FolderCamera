//
//  ProcessManager.swift
//  MyFirstGPUImage
//
//  Created by LiuYong on 2018/8/23.
//  Copyright © 2018年 LiuYong. All rights reserved.
//

import Foundation

//人脸特征值配置
enum PHOTOS_EXIF_ENUM : Int {
    case photos_EXIF_0ROW_TOP_0COL_LEFT = 1
    //   1  =  0th row is at the top, and 0th column is on the left (THE DEFAULT).
    case photos_EXIF_0ROW_TOP_0COL_RIGHT = 2
    //   2  =  0th row is at the top, and 0th column is on the right.
    case photos_EXIF_0ROW_BOTTOM_0COL_RIGHT = 3
    //   3  =  0th row is at the bottom, and 0th column is on the right.
    case photos_EXIF_0ROW_BOTTOM_0COL_LEFT = 4
    //   4  =  0th row is at the bottom, and 0th column is on the left.
    case photos_EXIF_0ROW_LEFT_0COL_TOP = 5
    //   5  =  0th row is on the left, and 0th column is the top.
    case photos_EXIF_0ROW_RIGHT_0COL_TOP = 6
    //   6  =  0th row is on the right, and 0th column is the top.
    case photos_EXIF_0ROW_RIGHT_0COL_BOTTOM = 7
    //   7  =  0th row is on the right, and 0th column is the bottom.
    case photos_EXIF_0ROW_LEFT_0COL_BOTTOM = 8
}

class processManager{
    var faceDetetor:CIDetector?
    
    init() {
        
    }
    
    func loadFaceDetector() {
        // Detector 的配置初始化：
        let detectorOptions = [CIDetectorAccuracy: CIDetectorAccuracyLow, CIDetectorTracking: true] as [String : Any]
        faceDetetor = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: detectorOptions)
    }
    
    func processFaceFeatures(withPicBuffer sampleBuffer: CMSampleBuffer?, cameraPosition currentCameraPosition: AVCaptureDevice.Position) -> [CIFeature]? {
        return processManager.processFaceFeatures(sampleBuffer: sampleBuffer, faceDetector: faceDetetor, currentCameraPosition: currentCameraPosition)
    }
    
    //获取face的边界
    class func faceRect(_ feature: CIFeature?) -> CGRect {
        var faceRects: CGRect? = feature?.bounds
        var temp: CGFloat? = faceRects?.size.width
        temp = faceRects?.origin.x
        let v = faceRects?.origin.y ?? 0.0
        faceRects?.origin.x = v
        faceRects?.origin.y = temp ?? 0.0
        return faceRects ?? CGRect.zero
    }
    
    
    class func processFaceFeatures(sampleBuffer: CMSampleBuffer?,faceDetector: CIDetector?,currentCameraPosition: AVCaptureDevice.Position) -> [CIFeature]? {
        let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer!)
        let attachments = CMCopyDictionaryOfAttachments(kCFAllocatorDefault, sampleBuffer!, kCMAttachmentMode_ShouldPropagate)
        //从帧中获取到的图片相对镜头下看到的会向左旋转90度，所以后续坐标的转换要注意。
        let convertedImage = CIImage(cvPixelBuffer: pixelBuffer!, options: attachments as? [AnyHashable : Any] as? [String : Any])
        if attachments != nil {
            
        }
        var imageOptions: [AnyHashable : Any]? = nil
        let curDeviceOrientation: UIDeviceOrientation = UIDevice.current.orientation
        var exifOrientation: Int
        let isUsingFrontFacingCamera: Bool = currentCameraPosition != .back
        switch curDeviceOrientation {
        case .portraitUpsideDown:
            exifOrientation = PHOTOS_EXIF_ENUM.photos_EXIF_0ROW_LEFT_0COL_BOTTOM.rawValue
        case .landscapeLeft:
            if isUsingFrontFacingCamera {
                exifOrientation = PHOTOS_EXIF_ENUM.photos_EXIF_0ROW_BOTTOM_0COL_RIGHT.rawValue
            } else {
                exifOrientation = PHOTOS_EXIF_ENUM.photos_EXIF_0ROW_TOP_0COL_LEFT.rawValue//PHOTOS_EXIF_0ROW_TOP_0COL_LEFT
            }
        case .landscapeRight:
            if isUsingFrontFacingCamera {
                exifOrientation = PHOTOS_EXIF_ENUM.photos_EXIF_0ROW_TOP_0COL_LEFT.rawValue
            } else {
                exifOrientation = PHOTOS_EXIF_ENUM.photos_EXIF_0ROW_BOTTOM_0COL_RIGHT.rawValue
            }
        default:
            exifOrientation =   PHOTOS_EXIF_ENUM.photos_EXIF_0ROW_RIGHT_0COL_TOP.rawValue//PHOTOS_EXIF_0ROW_RIGHT_0COL_TOP
            //值为6。确定初始化原点坐标的位置，坐标原点为右上。其中横的为y，竖的为x，表示真实想要显示图片需要顺时针旋转90度
        }
        //exifOrientation的值用于确定图片的方向
        imageOptions = [CIDetectorImageOrientation : Int32(exifOrientation)]
        return faceDetector?.features(in: convertedImage, options: imageOptions as? [String : Any])
    }

    
}
