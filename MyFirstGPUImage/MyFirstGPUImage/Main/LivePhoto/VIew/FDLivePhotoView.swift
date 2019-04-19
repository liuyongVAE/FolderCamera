//
//  GPULivePhotoView.swift
//  MyFirstGPUImage
//
//  Created by LiuYong on 2018/8/30.
//  Copyright © 2018年 LiuYong. All rights reserved.
//

import Foundation
import GPUImage

typealias livePhotoLongPressStartBlock = (_ states:Int)->()

class FDLivePhotoView: UIView {
    
    lazy var presentImageView:UIImageView = {
        let v  = UIImageView()
        return v
    }()
    
    lazy var videoPlayView:GPUImageView = {
        let v = GPUImageView()
        return v
    }()
    
    //长按事件反馈Block
    var stateBlock:livePhotoLongPressStartBlock?
    
     init() {
        super.init(frame: CGRect.zero)
        self.addSubview(videoPlayView)
        self.addSubview(presentImageView)
        
        videoPlayView.snp.makeConstraints({
            make in
            make.left.width.top.height.equalToSuperview()
        })
        presentImageView.snp.makeConstraints({
            make in
            make.left.width.top.height.equalToSuperview()
        })
        
         let longpress = UILongPressGestureRecognizer(target: self, action: #selector(self.longPress(_:)))
        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(longpress)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setImage(image:UIImage){
        DispatchQueue.main.async {
            self.presentImageView.image = image
        }
    }
    
    //长按事件处理
    @objc func longPress(_ gesture:UILongPressGestureRecognizer){
        switch gesture.state {
        case .began:
            print("begin")
            //震动反馈
            if #available(iOS 10.0, *) {
                let feed = UIImpactFeedbackGenerator(style: .medium)
                feed.impactOccurred()
            }
            //缩放动画
            let trans = CGAffineTransform.init(scaleX: 1.1, y: 1.1)

            UIView.animate(withDuration: 0.3, animations: {
                self.videoPlayView.transform = trans

            })
            
            DispatchQueue.main.async {
                
                self.bringSubview(toFront: self.videoPlayView)
                self.stateBlock!(0)
            }
        case .ended:
            print("end")
            
            UIView.animate(withDuration: 0.3, animations: {
                    self.videoPlayView.transform = CGAffineTransform.init(scaleX: 1, y: 1)
            })
            
        
            DispatchQueue.main.async {
                self.bringSubview(toFront: self.presentImageView)
                self.stateBlock!(1)
            }
        default:
            break
        }
        
        
    }
    
    
}
