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

//给拍照按钮归位传值给Fillter
typealias shotPositionResetBlock = ()->(Void)


class FillterSelectView: UIView {
    
    
    fileprivate let cell_width:CGFloat = 58
    fileprivate let cell_height:CGFloat = 58
    fileprivate var images = [UIImage]()
    fileprivate let layout = UICollectionViewFlowLayout()
    var collectionView:UICollectionView!
    //滤镜选择代理
    var filterDelegate:FillterSelectViewDelegate?
    var isShow:Bool
    //传值闭包
    var mb:shotPositionResetBlock?
    //UI lazy loading
//  返回按钮
    lazy var backButton:UIButton = {
        var btn = NewUIButton()
        btn.setImage(#imageLiteral(resourceName: "imageback"), for: .normal)
       //btn.setTitle("返回", for: .normal)
        btn.setTitleColor(UIColor.black, for: .normal)
        btn.addTarget(self, action: #selector(self.back), for: .touchUpInside)
        return btn
    }()
    
    lazy var bacImage:UIImageView = {
        var img = UIImageView()
        return img
    }()

    override init(frame: CGRect) {
        self.isShow = false
        super.init(frame: frame)
        setCollectionView()
        let notify = Notification.Name.init("CameraModeDidChanged")
        NotificationCenter.default.addObserver(self, selector: #selector(modeDidChanged), name: notify, object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func modeDidChanged(){
        self.collectionView.reloadData()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}
extension FillterSelectView:UICollectionViewDelegate,UICollectionViewDataSource{
    
   //初始化CollectionView
    private func setCollectionView(){
        layout.itemSize = CGSize(width: cell_width, height: cell_height)
        layout.minimumInteritemSpacing = 2
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 3
        layout.sectionInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
        collectionView = UICollectionView(frame: self.frame, collectionViewLayout: layout)
        collectionView.register(FilterCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = UIColor.clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.allowsMultipleSelection = false
        bacImage.image = CameraModeManage.shared.currentBackImageView.image

        self.addSubview(bacImage)
        self.addSubview(collectionView)
        //self.addSubview(backButton)
        setUI()
    }
    
    /// 设置 layout
   private func setUI(){
        let cH = cell_width+2
        collectionView.snp.makeConstraints({
            make in
            make.width.equalToSuperview()
            make.left.equalToSuperview().offset(4)
            make.top.equalToSuperview().offset(4)
            make.height.equalTo(cH)
        })
    bacImage.snp.makeConstraints ({ (ConstraintMaker) in
        ConstraintMaker.edges.equalToSuperview()
    })
//        backButton.snp.makeConstraints({
//            make in
//            make.centerY.equalToSuperview().offset(50)
//            make.width.height.equalTo(70)
//            make.right.equalToSuperview().offset(-20)
//        })
    
    }
 //设置图片
    
    
    
//   返回操作
    @objc func back(){
          UIView.animate(withDuration: 0.2, animations: {
           self.center.y = SCREEN_HEIGHT*9/8
            if self.mb != nil{
                self.mb!()
            }
    
          })
     
    }
    
    
    
    
    //MARK: - collection 方法
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return FilterGroup.shared.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier:"cell", for: indexPath) as! FilterCollectionViewCell
        
        //为每个cell添加image
        cell.filterLabel.text = FilterGroup.shared.getFilterWithIndex(index: indexPath.row).name
        cell.filterImage.image = UIImage(named:FilterGroup.shared.getFilterWithIndex(index: indexPath.row).imageCode)
        cell.selectedLayer.isHidden = true
   
        cell.backgroundColor = UIColor.clear
        return cell
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: cell_width, height: cell_height)
    }
    
    
    
//  点击cell的操作，调用代理切换滤镜
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let cell =  collectionView.cellForItem(at: indexPath) as? FilterCollectionViewCell {
            cell.selectedLayer.isHidden = false
        }
        
        filterDelegate?.switchFillter(index: indexPath.row)
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
         collectionView.reloadItems(at: [indexPath])
        
        if let cell =  collectionView.cellForItem(at: indexPath) as? FilterCollectionViewCell {
            cell.selectedLayer.isHidden = true
        }
    }
    
}

