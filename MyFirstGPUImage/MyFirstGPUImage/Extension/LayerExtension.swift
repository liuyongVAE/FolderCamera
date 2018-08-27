//
//  LayerExtension.swift
//  MyFirstGPUImage
//
//  Created by LiuYong on 2018/8/23.
//  Copyright © 2018年 LiuYong. All rights reserved.
//

import UIKit
extension CAShapeLayer {
    static func circle(radius: CGFloat) -> CAShapeLayer {
        let layer = CAShapeLayer()
        layer.lineWidth = 2
        let rect = CGRect(x: 0, y: 0, width: 2.0 * radius, height: 2.0 * radius)
        layer.path = UIBezierPath.init(ovalIn: rect).cgPath
        return layer
    }
    
    static func square(width: CGFloat) -> CAShapeLayer {
        let layer = CAShapeLayer()
        layer.lineWidth = 2
        //let rect = CGRect(x: 0, y: 0, width: width, height: width)
        let path = UIBezierPath()
        path.lineCapStyle = .square
        path.lineJoinStyle = .round
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: 0, y: width))
        path.addLine(to: CGPoint(x:width,y:width))
        path.addLine(to: CGPoint(x:width,y:0))
        path.close()
        layer.path = path.cgPath
        return layer
    }
}

extension CGRect {
    var center: CGPoint {
        return CGPoint(x: (minX + maxX) / 2.0, y: (minY + maxY) / 2.0)
    }
}
