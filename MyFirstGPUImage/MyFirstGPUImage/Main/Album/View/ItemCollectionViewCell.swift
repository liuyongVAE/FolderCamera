//
//  ItemCollectionViewCell.swift
//  MyFirstGPUImage
//
//  Created by LiuYong on 2018/9/12.
//  Copyright © 2018年 LiuYong. All rights reserved.
//

import UIKit

class ItemCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageView.contentMode = .scaleAspectFill
        imageView.snp.makeConstraints({
            make in
            make.left.right.top.bottom.equalToSuperview()
        })
        // Initialization code
    }

}
