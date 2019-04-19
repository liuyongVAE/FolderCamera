//
//  AlbumViewController.swift
//  MyFirstGPUImage
//
//  Created by LiuYong on 2018/9/12.
//  Copyright © 2018年 LiuYong. All rights reserved.
//

import UIKit
import Photos


class AlbumViewController: UIViewController{

    
    var items:[AlbumItem] = []
    let identify:String = "myCell"
    //MARK: - Lazy Loading
    lazy var tableView:UITableView = {
        let v = UITableView()
        v.delegate = self
        v.dataSource = self
        
        return v
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = false
        //禁用右滑返回
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false

        navigationItem.title = "选择照片"
        registerNotifi()
        setUI()
        openAlbum()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @objc func back(){
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func setUI(){
        self.view.addSubview(tableView)
        tableView.register(UINib(nibName: "AlbumTableViewCell", bundle: nil), forCellReuseIdentifier: identify)
        tableView.snp.makeConstraints({
            make in
            make.width.height.left.top.equalToSuperview()
        })
        let leftBtn:UIBarButtonItem=UIBarButtonItem(title: "返回", style: UIBarButtonItemStyle.plain, target: self, action: #selector(back))
        
        leftBtn.title="返回";
        
        leftBtn.tintColor = naviColor;
        
        self.navigationItem.leftBarButtonItem=leftBtn;
    }

    
    //开启相册
    func openAlbum(){
        PHPhotoLibrary.requestAuthorization({ (status) in
            if status != .authorized {
                return
            }
            // 列出所有系统的智能相册
            let smartOptions = PHFetchOptions()
            let smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum,
                                                                      subtype: .albumRegular,
                                                                      options: smartOptions)
            self.convertCollection(collection: smartAlbums)
            
            //列出所有用户创建的相册
            let userCollections = PHCollectionList.fetchTopLevelUserCollections(with: nil)
            self.convertCollection(collection: userCollections
                as! PHFetchResult<PHAssetCollection>)

            //相册第一个保持为相机胶卷，使用如下排序
            self.items.sort { (item1, item2) -> Bool in
                switch(item1.title,item2.title){
                case ("相机胶卷", _):
                    return true
                default:
                    return false
                }
            }
            //记录不显示的相册下标
            var indexesToDelete:[Int] = []
            for i in 0...(self.items.count - 1){
                if self.items[i].title == "最近删除" || self.items[i].title == "动图"  {
                    indexesToDelete.append(i)
                }
            }
            //删除对应下标的相册
            for i in indexesToDelete{
                self.items.remove(at: i)
            }
            
            //异步加载表格数据,需要在主线程中调用reloadData() 方法
            DispatchQueue.main.async{
                self.openList(index: 0,animation: true)
                self.tableView.reloadData()
            }
            
        })
    }
    
    
    
    /// 注册相册刷新通知
    func registerNotifi(){
        NotificationCenter.default.addObserver(self, selector: #selector(albumRefresh), name: NSNotification.Name(rawValue:"albumRefresh"), object: nil)
        
    }
    
    /// 相册刷新
    @objc func albumRefresh(nofi : Notification){
        let str = nofi.userInfo!["go"]
        print(String(describing: str!) + "this notifi")
        // 列出所有系统的智能相册
        let smartOptions = PHFetchOptions()
        let smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum,
                                                                  subtype: .albumRegular,
                                                                  options: smartOptions)
        items.removeAll()
        self.convertCollection(collection: smartAlbums)
        
        //列出所有用户创建的相册
        let userCollections = PHCollectionList.fetchTopLevelUserCollections(with: nil)
        self.convertCollection(collection: userCollections
            as! PHFetchResult<PHAssetCollection>)
        
        self.tableView.reloadData()
    }
    
    
    /// 移除通知
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    

}

extension AlbumViewController{
    
   //打开特定相册
    private func openList(index:Int,animation:Bool){
        let cell_width = SCREEN_WIDTH/3 - 2
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: cell_width, height: cell_width)
        layout.minimumInteritemSpacing = 2
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 2
        
        //layout.sectionInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
        
        let collectionViewController =  ItemCollectionViewController.init(collectionViewLayout: layout)
        
        //获取选中的相簿信息
        let item = self.items[index]
        //设置标题
        collectionViewController.title = item.title
        //传递相簿内的图片资源
        collectionViewController.assetsFetchResults = item.fetchResult
        print("传给你的大小",item.fetchResult.count)
        self.navigationController?.pushViewController(collectionViewController, animated:animation )
    }
    
    
    //由于系统返回的相册集名称为英文，我们需要转换为中文
    private func titleOfAlbumForChinse(title:String?) -> String? {
        if title == "Slo-mo" {
            return "慢动作"
        } else if title == "Recently Added" {
            return "最近添加"
        } else if title == "Favorites" {
            return "个人收藏"
        } else if title == "Recently Deleted" {
            return "最近删除"
        } else if title == "Videos" {
            return "视频"
        } else if title == "All Photos" {
            return "所有照片"
        } else if title == "Selfies" {
            return "自拍"
        } else if title == "Screenshots" {
            return "屏幕快照"
        } else if title == "Camera Roll" {
            return "相机胶卷"
        }
        return title
    }
    
    
    //转化处理获取到的相簿
    private func convertCollection(collection:PHFetchResult<PHAssetCollection>){
        
        for i in 0..<collection.count{
            //获取出当前相簿内的图片
            let resultsOptions = PHFetchOptions()
            resultsOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate",
                                                               ascending: false)]
            resultsOptions.predicate = NSPredicate(format: "mediaType = %d",
                                                   PHAssetMediaType.image.rawValue)
            let c = collection[i]
            let assetsFetchResult = PHAsset.fetchAssets(in: c , options: resultsOptions)
            //没有图片的空相簿不显示
            if assetsFetchResult.count > 0{
                let title = titleOfAlbumForChinse(title: c.localizedTitle)
       
                items.append(AlbumItem(title: title,
                                       fetchResult: assetsFetchResult))
              
                
            
            }
        }
        
    }
    

    
    
}



// MARK: - TableView
extension AlbumViewController:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  items.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ""
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  self.tableView.dequeueReusableCell(withIdentifier: identify) as! AlbumTableViewCell
        cell.selectionStyle = .none

        cell.titleLabel.text  = self.items[indexPath.row].title
        cell.imageLeft.image = self.items[indexPath.row].coverImage
        cell.countLabel.text = "\(self.items[indexPath.row].fetchResult.count)" + "张"
        return cell
    }
    
    //点击跳转
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        openList(index: indexPath.row, animation: true)
    }
    
}
