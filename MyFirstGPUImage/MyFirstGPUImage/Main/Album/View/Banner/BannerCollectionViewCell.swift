//
//  BannerCollectionViewCell.swift
//  MyFirstGPUImage
//
//  Created by LiuYong on 2018/9/14.
//  Copyright © 2018年 LiuYong. All rights reserved.
//

import UIKit

class BannerCollectionViewCell: UICollectionViewCell {
    
    
    
    var image : UIImage? {
        didSet{
            bigImage.image = image
        }
    }
   lazy var scrollView:UIScrollView = {
        let sco = UIScrollView()
        sco.maximumZoomScale = 10
        sco.minimumZoomScale = 0.7//最小缩放
        sco.delegate = self
        sco.clipsToBounds = false//不让内部元素越界
        sco.isScrollEnabled = false//不允许滑动，在放大时允许，缩小和原大小时不允许
    
        return sco
   }()
    
    //lazy loading
    
    lazy var bigImage:UIImageView = {
        var big = UIImageView()
        big.contentMode = .scaleAspectFit
        big.clipsToBounds = true
        return  big
    }()
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //MARK: setui
    
    fileprivate func setUI(){
        self.backgroundColor = UIColor.white
        self.addSubview(scrollView)
        scrollView.addSubview(bigImage)
        scrollView.snp.makeConstraints({
            make in
            make.top.equalTo(0)
            make.left.right.bottom.equalTo(0)
        })
        bigImage.snp.makeConstraints({
            make in
           // make.top.equalTo(0)
            make.centerY.equalTo(SCREEN_HEIGHT/2)
            make.width.equalTo(SCREEN_WIDTH)
            make.height.equalTo(SCREEN_HEIGHT)
            make.left.right.equalTo(0)
        })
        scrollView.contentSize =  bigImage.frame.size

    }
    
    
}

// MARK: - SCROLLVIEW Delegate
extension BannerCollectionViewCell:UIScrollViewDelegate{
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.bigImage
    }
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        
        //不断调整图片在中心位置

        bigImage.snp.updateConstraints({
            u in
            u.centerY.equalTo(SCREEN_HEIGHT/2)
        })
        //增大滑动区域
        scrollView.contentSize = CGSize(width: bigImage.frame.size.width + 30, height: bigImage.frame.size.height + 30)
        
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        //缩放结束后，如果是缩小回复正常图片
        if scale<=1{
            bigImage.snp.updateConstraints({
                make in
                make.centerY.equalTo(SCREEN_HEIGHT/2)
                make.width.equalTo(SCREEN_WIDTH)
                make.height.equalTo(SCREEN_HEIGHT)
                make.left.right.equalTo(0)
            })
            scrollView.zoomScale = 1
            scrollView.contentSize =  bigImage.frame.size
            scrollView.isScrollEnabled = false
        }else{
            scrollView.isScrollEnabled = true
        }
    }
    
    
    
}
