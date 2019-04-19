//
//  BannerLayout.swift
//  MyFirstGPUImage
//
//  Created by LiuYong on 2018/9/14.
//  Copyright © 2018年 LiuYong. All rights reserved.
//

import UIKit


class BannerFlowLayout:UICollectionViewFlowLayout{
    
    
    override func prepare() {
        super.prepare()
        minimumLineSpacing = 0
        minimumInteritemSpacing = 0
        sectionInset = UIEdgeInsets.zero
        itemSize = CGSize(width: SCREEN_WIDTH, height: SCREEN_HEIGHT-1)

        //水平滚动
        scrollDirection = .horizontal
        
    }
    
    
    
}
