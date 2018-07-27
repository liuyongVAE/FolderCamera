//
//  FillterSelectViewController.swift
//  MyFirstGPUImage
//
//  Created by LiuYong on 2018/7/27.
//  Copyright © 2018年 LiuYong. All rights reserved.
//

import UIKit


protocol FillterSelectViewDelegate {
    func switchFillter(index:Int)//滤镜选择
}

typealias shotPositionResetBlock = ()->(Void)//给拍照按钮归位传值给Fillter


class FillterSelectView: UIView {
    
    
    fileprivate let cell_width:CGFloat = getWidth(184)
    fileprivate let cell_height:CGFloat = getHeight(184)
 
    fileprivate let layout = UICollectionViewFlowLayout()
    fileprivate var collectionView:UICollectionView!
    var picArray:[UIImage]?
    var filterDelegate:FillterSelectViewDelegate?
    //传值闭包
    var mb:shotPositionResetBlock?
    //UI lazy loading
    
    lazy var backButton:UIButton = {
        var btn = NewUIButton(frame: CGRect(x:SCREEN_WIDTH - getWidth(109) - getWidth(78), y: getHeight(250), width:getWidth(78) , height: getHeight(154)))
        btn.setImage(#imageLiteral(resourceName: "返回"), for: .normal)
        btn.setTitle("返回", for: .normal)
        btn.setTitleColor(UIColor.black, for: .normal)
        btn.addTarget(self, action: #selector(self.back), for: .touchUpInside)
        return btn
    }()
    


    
    


    override init(frame: CGRect) {
        super.init(frame: frame)
        setCollectionView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
extension FillterSelectView:UICollectionViewDelegate,UICollectionViewDataSource{
    
   
    func setCollectionView(){
        layout.itemSize = CGSize(width: cell_width, height: cell_height)
        layout.minimumInteritemSpacing = getWidth(20)
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = getHeight(0)
        layout.sectionInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
        collectionView = UICollectionView(frame:FloatRect(0, 4, SCREEN_WIDTH, getHeight(170)),collectionViewLayout:layout)
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.dataSource = self
        collectionView.delegate = self
        self.backgroundColor = UIColor.white
        collectionView.backgroundColor = UIColor.white
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.allowsMultipleSelection = false
        self.addSubview(collectionView)
        self.addSubview(backButton)
    }
    
    
    @objc func back(){
          UIView.animate(withDuration: 0.2, animations: {
           self.center.y = SCREEN_HEIGHT*9/8
            if self.mb != nil{
                self.mb!()
            }
    
          })
     
    }
    
    
    
    
    //collection 方法
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return picArray?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: UICollectionViewCell? = collectionView.dequeueReusableCell(withReuseIdentifier:"cell", for: indexPath)
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: cell_width - 4, height: cell_height - 8 ))
        imageView.center = (cell?.contentView.center)!
       
        imageView.image = picArray![indexPath.row]
        
        
        cell?.addSubview(imageView)

        cell?.backgroundColor = UIColor.white
        return cell!
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: cell_width, height: cell_height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        collectionView.cellForItem(at: indexPath)?.backgroundColor = naviColor

        filterDelegate?.switchFillter(index: indexPath.row)
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        collectionView.cellForItem(at: indexPath)?.backgroundColor = UIColor.white
    }
    
}

