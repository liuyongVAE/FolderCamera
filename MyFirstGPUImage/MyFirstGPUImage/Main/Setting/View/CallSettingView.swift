//
//  CallSettingView.swift
//  MyFirstGPUImage
//
//  Created by LiuYong on 2018/9/7.
//  Copyright © 2018年 LiuYong. All rights reserved.
//

import UIKit


class CallSettingView:UIView{
    private var tWidth:CGFloat = 6
    private var tHeight:CGFloat = 5
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)

        var rect = rect
        
        var frame: CGRect = rect
        
        frame.size.height = frame.size.height - 20
        
        rect = frame
        // 获取当前图形，视图推入堆栈的图形，相当于你所要绘制图形的图纸
        
       let ctx:CGContext = UIGraphicsGetCurrentContext()!
        
        // 创建一个新的空图形路径。
        
        ctx.beginPath()
        
        //启始位置坐标x，y
        
        let origin_x: CGFloat = frame.origin.x
        
       let origin_y: CGFloat = frame.origin.y + 10
        
        //第一条线的位置坐标
        
        let line_1_x: CGFloat = frame.size.width
        
        let line_1_y: CGFloat = origin_y
        
        //第二条线的位置坐标
        
        let line_2_x: CGFloat = line_1_x
        
        let line_2_y: CGFloat = frame.size.height
        
        //第三条线的位置坐标
        
        let line_3_x: CGFloat = origin_x + 10 // (frame.size.width - 10)
        
       let line_3_y: CGFloat = origin_y
        
        //尖角的顶点位置坐标
        
        let line_4_x: CGFloat = line_3_x + 5
        
        let line_4_y: CGFloat = origin_y - 10
        
        //第五条线位置坐标
        
       let line_5_x: CGFloat = line_4_x + 5
        
        let line_5_y: CGFloat = line_3_y
        
        //第六条线位置坐标
        
        let line_6_x: CGFloat = origin_x
        
        let line_6_y: CGFloat = line_2_y
        ctx.move(to: CGPoint(x: origin_x, y: origin_y))
        ctx.addLine(to: CGPoint(x: line_3_x, y: line_3_y))
        ctx.addLine(to: CGPoint(x: line_4_x, y: line_4_y))
        ctx.addLine(to: CGPoint(x: line_5_x, y: line_5_y))
    
        ctx.addLine(to: CGPoint(x: line_1_x, y: line_1_y))
        
        ctx.addLine(to: CGPoint(x: line_2_x, y: line_2_y))
        
        ctx.addLine(to: CGPoint(x: line_6_x, y: line_6_y))


        ctx.closePath()

        let costomColor: UIColor = UIColor(red:0, green:0, blue: 0, alpha: 0.3)
        
        ctx.setFillColor(costomColor.cgColor)
        //ctx.setStrokeColor(UIColor.yellow.cgColor)
        //ctx.setLineWidth(3)

        ctx.fillPath()
        
        self.transform = .init(scaleX: 0.00001, y: 0.00001)
    }
    
    
    func open(){
        
        weak var weakSelf = self
        weakSelf?.layer.anchorPoint = CGPoint(x: 0.1, y: 0)

        UIView.animate(withDuration: 0.3, animations: {
            
            weakSelf?.transform = .init(scaleX: 1, y: 1)
        })

    }
    
    func close(){
        weak var weakSelf = self
        UIView.animate(withDuration: 0.3, animations: {
            weakSelf?.transform = .init(scaleX: 0.00001, y: 0.00001)
        })
    }
  
    
    
    
}


