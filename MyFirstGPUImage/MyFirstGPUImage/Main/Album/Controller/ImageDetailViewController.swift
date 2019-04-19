//
//  ImageDetailViewController.swift
//  MyFirstGPUImage
//
//  Created by LiuYong on 2018/9/13.
//  Copyright © 2018年 LiuYong. All rights reserved.
//

import UIKit
import Photos
class ImageDetailViewController: UIViewController {
    
    //lazy loading
    
    lazy var bannerView:BannerView = {
        var big = BannerView(index: indexPath)
        big.delegate = self
        return  big
    }()
    
    //取得的资源结果，用了存放的PHAsset
    var assetsFetchResults:PHFetchResult<PHAsset>!
    var indexPath:IndexPath!;
    /// 带缓存的图片管理对象
    var imageManager:PHCachingImageManager!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        self.view.backgroundColor = UIColor.white
        self.bannerView.assetsFetchResults = assetsFetchResults
      // self.bannerView.index = self.indexPath
    
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - UI
    func setUI(){
        self.view.backgroundColor = UIColor.white
        self.view.addSubview(bannerView)
        
        //解决scrollview 全屏时，会被自动调整到导航栏以下的问题，collectionview页同理
        self.automaticallyAdjustsScrollViewInsets = false
        
        bannerView.snp.makeConstraints({
            make in
            make.left.equalTo(0)
            make.top.width.height.equalToSuperview()
        })

    }
    
    


}
extension ImageDetailViewController:BannerViewDelegate{
    
    
    func hideNavi(){
        //设置导航栏隐藏
        self.navigationController?.navigationBar.isHidden = !((navigationController?.navigationBar.isHidden) ?? true)
    }
    
    func bannerViewDidSelectedItemAtIndex(_ image: UIImage) {
        let vc = CheckViewController(image: image, type: 0)
        //当其返回时返回根视图
        vc.willDismiss = {
           self.navigationController?.popToRootViewController(animated: false)
        
        }
        self.present(vc, animated: true, completion: nil)
    }
}
