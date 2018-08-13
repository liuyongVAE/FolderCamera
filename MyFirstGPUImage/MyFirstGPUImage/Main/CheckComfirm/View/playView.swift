//
//  playView.swift
//  MyFirstGPUImage
//
//  Created by LiuYong on 2018/8/13.
//  Copyright © 2018年 LiuYong. All rights reserved.
//

import UIKit

class VideoPlayView: UIView {

    
    
    var player:AVPlayer?
    var playerItem:AVPlayerItem?
    var playerLayer:AVPlayerLayer?
    var videoUrl:URL?{
        didSet{
            playerItem = AVPlayerItem(url: videoUrl!)
            player = AVPlayer(playerItem: playerItem!)
            playerLayer = AVPlayerLayer(player: player!)
            playerLayer?.videoGravity = .resizeAspectFill
            playerLayer?.frame = self.bounds
            playerLayer?.backgroundColor = UIColor.blue.cgColor
            self.layer.addSublayer(playerLayer!)
        }
    }


    init(){
        super.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT*3/4))
    }
    
    
    func play(){
        player?.play()
    }

    func pause(){
        player?.pause()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

}
