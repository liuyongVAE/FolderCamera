//
//  FaceLayerView.swift
//  MyFirstGPUImage
//
//  Created by LiuYong on 2018/8/23.
//  Copyright © 2018年 LiuYong. All rights reserved.
//

import UIKit


struct FaceLayer {
    let layer: CAShapeLayer
    let area: FaceArea
}


final class FaceLayerView: UIView {
    //脸部layer数组
    private var drawnFaceLayers = [FaceLayer]()
    private var layerColor = UIColor.init(red: 252/255, green: 228/255, blue: 236/255, alpha: 0.7)
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
        isUserInteractionEnabled = false
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("")
    }
    
    func update(areas:[FaceArea]){
        let drawnAreas = drawnFaceLayers.map{$0.area}//将area的数值提取
        //将TrackingId值提取为集合Set
        let drawnTrackingIDs: Set<Int32> = Set(drawnAreas.map { $0.trackingID })
        //将传入的FaceArea数组的tracking 提取，不重复存储
        let newTrackingIDs: Set<Int32> = Set(areas.map { $0.trackingID })
        //取集合相减的结果
        let trackingIDsToBeAdded: Set<Int32> = newTrackingIDs.subtracting(drawnTrackingIDs)
        //相交
        let trackingIDsToBeMoved: Set<Int32> = drawnTrackingIDs.intersection(newTrackingIDs)
        let trackingIDsToBeRemoved: Set<Int32> = drawnTrackingIDs.subtracting(newTrackingIDs)
        
        let areasToBeAdded: [FaceArea] = trackingIDsToBeAdded.compactMap { trackingID in
            areas.first { $0.trackingID == trackingID }
        }
        let areasToBeMoved: [FaceArea] = trackingIDsToBeMoved.compactMap { trackingID in
            areas.first { $0.trackingID == trackingID }
        }
        
        
        if let zz = layer.sublayers {
            for i in zz{
                i.removeFromSuperlayer()
            }
        }
        drawCircles(of: areasToBeAdded)
        drawCircles(of: areasToBeMoved)
        removeCircles(of: Array(trackingIDsToBeRemoved))
    }
    
    

    private func moveCircles(of areas: [FaceArea]) {
        areas.forEach { moveCircle(of: $0) }
    }
    
    private func moveCircle(of area: FaceArea) {
        guard let drawnLayerIndex = (drawnFaceLayers.index { $0.area.trackingID == area.trackingID }) else {
            return
        }
        let drawnLayer = drawnFaceLayers[drawnLayerIndex]
        let fromCentroid = drawnLayer.layer.position
        let toCentroid = area.bounds.center
        let moveAnimation = CABasicAnimation(keyPath: "position")
        moveAnimation.fromValue = NSValue(cgPoint: fromCentroid)
        moveAnimation.toValue = NSValue(cgPoint: toCentroid)
        moveAnimation.duration = 0.3
        moveAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        drawnLayer.layer.position = toCentroid
        drawnLayer.layer.add(moveAnimation, forKey: "position")
    }
    
    private func drawCircles(of areas: [FaceArea]) {
        //forEach 相当于循环for i in...
        areas.forEach { drawCircle(of: $0) }
    }
    
    //为人脸画圆形区域
    private func drawCircle(of area: FaceArea) {
        
        
        let bounds = area.bounds
        let radius: CGFloat = (bounds.maxX - bounds.minX) / 2.0
        let circleLayer = CAShapeLayer.circle(radius: radius)
        circleLayer.frame = CGRect(x: 0, y: 0, width: radius * 2, height: radius * 2)
        circleLayer.position = bounds.center
        circleLayer.fillColor = UIColor.clear.cgColor
       
        //定义完贝塞尔曲线，添加到layer，更新path
       // Layer.path = progressPath.cgPath
        circleLayer.strokeColor = lightPink.cgColor
        drawnFaceLayers.append(FaceLayer(layer: circleLayer, area: area))
    
        layer.addSublayer(drawnFaceLayers.last!.layer)
    }
    
    
    private func removeCircles(of indexes:[Int32]){
        indexes.forEach{ index  in
            //$0 表示闭包中第一个参数，相当于 a in  a.area
            guard let drawnLayer = (drawnFaceLayers.first{ $0.area.trackingID == index })else{ return }
            drawnLayer.layer.removeFromSuperlayer()
            drawnFaceLayers = drawnFaceLayers.filter({m in m.area.trackingID != index })
        }
    }
    
    
    
    
    
    
    


}
