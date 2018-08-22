//
//  LineProgress.swift
//  MyFirstGPUImage
//
//  Created by LiuYong on 2018/8/21.
//  Copyright © 2018年 LiuYong. All rights reserved.
//

import Foundation
import UIKit

class lineProgress:UIView{
    
    var progressLayer:CAShapeLayer!
    var progressLineLayer:CAShapeLayer!
    var time:Timer?
    var progress:CGFloat = 0.0
    //长视频录制变量
    var progressPause:[CGFloat]? = [CGFloat]()
    var width:CGFloat = 0.0
    //进度条暂停间隔
    private var  whiteOverlay = [CAShapeLayer]()
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setLinePath(){
        progressLineLayer.fillColor = nil
        progressLineLayer.lineCap = kCALineCapSquare//线端点类型
        progressLineLayer.frame = CGRect.init(x: -152, y: -543, width: SCREEN_WIDTH, height: 5)
        progressLineLayer.lineWidth = width
        progressLineLayer.strokeColor = bgColor.cgColor
        let progressPath = UIBezierPath()
        progressPath.move(to: CGPoint(x:0,y:0))
        progressPath.addLine(to: CGPoint(x:0,y:0))
        //outView.layer.addSublayer(progressLineLayer)
        
        //UIBezierPath(arcCenter: centerView.center, radius: (outView.frame.size.width - (1.5*width))/3, startAngle: CGFloat(Double.pi*2)*progress + CGFloat(-Double.pi/2), endAngle:CGFloat(Double.pi*2)*(progress+0.0005) + CGFloat(-Double.pi/2) , clockwise: true)
        // progress = progress+0.0005
        progressLineLayer.path = progressPath.cgPath
    }
    
    
    func addIntervalPath(){
        let progressLayer2 = CAShapeLayer()
        progressLayer2.fillColor = nil
        progressLayer2.lineCap = kCALineCapButt//线端点类型
        progressLayer2.frame = CGRect.init(x: -152, y: -543, width: SCREEN_WIDTH, height: 5)
        progressLayer2.lineWidth = width
        progressLayer2.strokeColor = UIColor.white.cgColor
        progressLayer2.zPosition = 2
        whiteOverlay.append(progressLayer2)
        let progressPath = UIBezierPath()
        progressPath.move(to: CGPoint(x:SCREEN_WIDTH*(progress+0.005),y:0))
        // let progressPath = UIBezierPath(arcCenter: centerView.center, radius: (outView.frame.size.width - (1.5*width))/3, startAngle: CGFloat(Double.pi*2)*progress + CGFloat(-Double.pi/2), endAngle:CGFloat(Double.pi*2)*(progress+0.0005) + CGFloat(-Double.pi/2) , clockwise: true)
        progress = progress+0.01
        progressPath.addLine(to: CGPoint(x:progress*SCREEN_WIDTH,y:0))
        progress = progress+0.005
        // progressPath.stroke()
        whiteOverlay.last?.path = progressPath.cgPath
        self.layer.addSublayer(whiteOverlay.last!)
    }
    
    func updateLinePath(){
        let progressPath = UIBezierPath()
        progressPath.move(to: CGPoint(x:0,y:0))
        progressPath.addLine(to: CGPoint(x:progress*SCREEN_WIDTH,y:0))
        progressLineLayer.path = progressPath.cgPath
    }
    
    
    
    
}
