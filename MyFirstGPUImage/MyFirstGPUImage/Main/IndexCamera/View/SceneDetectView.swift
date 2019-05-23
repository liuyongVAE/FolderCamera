//
//  SceneDetectView.swift
//  MyFirstGPUImage
//
//  Created by liuyong on 2019/5/23.
//  Copyright © 2019年 LiuYong. All rights reserved.
//


import Foundation
import UIKit


class SceneDetectView: UIView {
    

    
    lazy var backImage:UIImageView =  {
        let label = UIImageView()
        label.image = #imageLiteral(resourceName: "AI提示底框")
        label.layer.cornerRadius = 4;
        label.layer.masksToBounds = true
        return label
    }()
    
    lazy var closeButton:UIButton =  {
        let label = UIButton()
        label.setImage(#imageLiteral(resourceName: "关闭AI提示按钮"), for: .normal)
        return label
    }()
    
    
    lazy var sceneLabel:UILabel = {
        let label = UILabel()
        label.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.7)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = label.font.withSize(12)
        return label
    }()
    
    var labelText:String? {
        didSet {
            sceneLabel.text = labelText
            
            
            if (labelText == "天空") {
                currentAIFilterIndex = 2
            } else if  labelText == "森林" {
                currentAIFilterIndex = 1
            } else {
                currentAIFilterIndex = 0
            }
            
            
        }
        
    }
    
    //0 normal 1 jungle 2 sky
    var currentAIFilterIndex:Int!
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(backImage)
        self.addSubview(sceneLabel)
        self.addSubview(closeButton)
        currentAIFilterIndex = 0
        backImage.snp.makeConstraints{make in
            make.edges.equalToSuperview()
        }
        sceneLabel.snp.makeConstraints{make in
            make.leading.equalTo(7)
            make.centerY.equalToSuperview()
        }
        
        closeButton.snp.makeConstraints{make in
            make.trailing.equalTo(-7)
            make.centerY.equalToSuperview()
            make.height.width.equalTo(8)
        }
        
        closeButton.addTarget(self, action: #selector(closeSelf), for: .touchUpInside)
        sceneLabel.isUserInteractionEnabled = true
        let gest = UITapGestureRecognizer(target: self, action: #selector(changeMode))
        sceneLabel.addGestureRecognizer(gest)
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    @objc func closeSelf(){
        self.removeFromSuperview()
    }
    
    @objc func changeMode(){
        //print(self.sceneLabel.text,"####")
        let modeT = self.labelText
        if (modeT == "风景" || modeT == "天空" || modeT == "森林" ) {
            CameraModeManage.shared.currentMode = .CameraModeScenery

        } else if (modeT == "人像") {
            CameraModeManage.shared.currentMode = .CameraModePeople
        } else if (modeT == "人像")  {
            CameraModeManage.shared.currentMode = .CameraModeFood

        }
        
        
        
        
        
    }
    
}
