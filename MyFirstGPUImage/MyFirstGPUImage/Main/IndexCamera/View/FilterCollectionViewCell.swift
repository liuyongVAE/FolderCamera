//
//  FilterCollectionViewCell.swift
//  MyFirstGPUImage
//
//  Created by LiuYong on 2018/8/1.
//  Copyright © 2018年 LiuYong. All rights reserved.
//

import UIKit

class FilterCollectionViewCell: UICollectionViewCell {
    
    
    lazy var filterLabel:UILabel = {
        let label = UILabel()
        label.textColor = UIColor.black
        label.font = UIFont.systemFont(ofSize: 13)
        label.textAlignment = .center
        return  label
    }()
    lazy var filterImage:UIImageView = {
        let label = UIImageView()
        return  label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }
    
    func setUI(){
        
        self.addSubview(filterImage)
        self.addSubview(filterLabel)
        
        filterImage.snp.makeConstraints({
            make in
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-20)
            make.height.equalToSuperview().offset(-20)
            make.bottom.equalToSuperview().offset(-16)
            
        })
        
        
        filterLabel.snp.makeConstraints({
            make in
            make.centerX.equalToSuperview()
            make.top.equalTo(self.filterImage.snp.bottom)
            make.left.right.equalTo(0)
            make.height.equalTo(15)
            
        })
        
        
        
    }
    
    
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
    
    
    
}
