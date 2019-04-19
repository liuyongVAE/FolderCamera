//
//  AlbumTableViewCell.swift
//  MyFirstGPUImage
//
//  Created by LiuYong on 2018/9/12.
//  Copyright © 2018年 LiuYong. All rights reserved.
//

import UIKit

class AlbumTableViewCell: UITableViewCell {

    lazy var countLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = UIColor.gray
        return label
    }()
    
    lazy var imageLeft: UIImageView = UIImageView()
    
    lazy  var titleLabel: UILabel = UILabel()
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.addSubview(countLabel)
        self.addSubview(imageLeft)
        self.addSubview(titleLabel)
        // Initialization code
        self.imageLeft.snp.makeConstraints({
            make in
            make.left.equalTo(5)
            make.centerY.equalToSuperview()
            make.height.equalToSuperview().offset(-20)
            make.width.equalTo(80)
        })
    
        self.titleLabel.snp.makeConstraints({
            make in
            make.left.equalTo(95)
            make.width.equalToSuperview().offset(-100)
            make.height.equalTo(16)
            make.centerY.equalToSuperview()
        })
        
        countLabel.snp.makeConstraints({
            make in
            make.left.equalTo(95)
            make.width.equalToSuperview().offset(-100)
            make.height.equalTo(16)
            make.centerY.equalToSuperview().offset(25)

        })
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
