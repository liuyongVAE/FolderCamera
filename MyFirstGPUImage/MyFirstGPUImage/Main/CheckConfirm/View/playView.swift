//
//  playView.swift
//  MyFirstGPUImage
//
//  Created by LiuYong on 2018/8/13.
//  Copyright © 2018年 LiuYong. All rights reserved.
//

import UIKit



class VideoPlayView: UIView{


    var player:AVPlayer?
    var playerItem:AVPlayerItem?
    var playerLayer:AVPlayerLayer?
    //视频地址
    var videoUrl:URL?{
        didSet{
            
            playerItem = AVPlayerItem(url: videoUrl!)
            player = AVPlayer(playerItem: playerItem!)
            playerLayer = AVPlayerLayer(player: player!)
            playerLayer?.videoGravity = .resizeAspectFill
            playerLayer?.frame = self.bounds
            self.layer.addSublayer(playerLayer!)
            addNotification()
        }
    }


    init(){
        super.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT*3/4))
    }

    //视频播放器控制
    func play(){
        if player != nil{
          player!.play()
        }else{
            
        }
        
    }

    func pause(){
        player?.pause()
        player?.seek(to: CMTime.init(value: 0, timescale: 1))
    }
    

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func deadlloc() {
        player = nil
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: player?.currentItem)
    }
    
    func removeNotification(){
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: player?.currentItem)
    }
    

}
//添加播放通知
extension VideoPlayView{
    
    func addNotification(){
        NotificationCenter.default.addObserver(self, selector: #selector(didFinished), name:.AVPlayerItemDidPlayToEndTime, object: player?.currentItem)
    }
    @objc func didFinished(){
        player?.seek(to: CMTime.init(value: 0, timescale: 1))
        player?.play()
    }
    
    
    
}
