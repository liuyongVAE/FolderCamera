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
}

extension CGRect {
    var center: CGPoint {
        return CGPoint(x: (minX + maxX) / 2.0, y: (minY + maxY) / 2.0)
    }
}
