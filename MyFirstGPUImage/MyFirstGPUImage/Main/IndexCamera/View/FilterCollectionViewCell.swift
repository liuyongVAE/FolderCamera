//
//  FilterCollectionViewCell.swift
//  MyFirstGPUImage
//
//  Created by LiuYong on 2018/8/1.
//  Copyright © 2018年 LiuYong. All rights reserved.
//

import UIKit

class FilterCollectionViewCell: UICollectionViewCell {
    
    //UI
    lazy var filterLabel:UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 10)
        label.textAlignment = .center
        return  label
    }()
    lazy var filterImage:UIImageView = {
        let label = UIImageView()
        return  label
    }()
    
    lazy var nameBack:UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "灰色条幅")

        return  view;
    }()
    
    lazy var selectedLayer:UIView = {
        let view = UIView()
        view.backgroundColor = filterLabelBack;
        let checkImage = UIImage(named: "对号");
        let ci = UIImageView()
        ci.image = checkImage;
        view.addSubview(ci);

        ci.snp.makeConstraints({ make in
            make.width.height.equalTo(15);
            make.center.equalToSuperview()
        })
        
        
        
        return  view;
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
        let notify = Notification.Name.init("CameraModeDidChanged")
        NotificationCenter.default.addObserver(self, selector: #selector(modeDidChanged), name: notify, object: nil)
    }
    
    @objc func modeDidChanged(){
        
        if (CameraModeManage.shared.currentMode == CameraMode.CameraModeFilm) {
           nameBack.image = UIImage(named: "胶片模式条幅")
            
        } else {
            nameBack.image = UIImage(named: "灰色条幅")
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)

    }
    
    func setUI(){
        self.addSubview(filterImage)
        self.addSubview(selectedLayer)
        self.addSubview(nameBack)
        nameBack.addSubview(filterLabel)
        
        filterImage.snp.makeConstraints({
            make in
            make.edges.equalToSuperview()
//            make.centerX.equalToSuperview()
//            make.width.equalToSuperview().offset(-20)
//            make.height.equalToSuperview().offset(-20)
//            make.bottom.equalToSuperview().offset(-16)
        })
        nameBack.snp.makeConstraints { make in
            make.bottom.equalTo(-4)
            make.height.equalTo(14)
            make.leading.trailing.equalToSuperview()
        }
        
        filterLabel.snp.makeConstraints({
            make in
            make.center.equalToSuperview()
        })
        
        
        selectedLayer.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        selectedLayer.isHidden = true;
        
    }
    
    
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    
    
    
    
    
    
    
}
