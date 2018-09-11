//
//  SettingTableView.swift
//  MyFirstGPUImage
//
//  Created by LiuYong on 2018/9/10.
//  Copyright © 2018年 LiuYong. All rights reserved.
//

import UIKit


protocol SettingViewDelegate{
    func push(vc:UIViewController)
    
}
//设置页面的展示view
class SettingTableView: UIView {
    
    //MARK: -  Lazy Loading
    lazy var tableView:UITableView = {
        let tableview = UITableView(frame: CGRect.zero)
        tableview.tableFooterView = UIView(frame: CGRect.zero)
        tableview.isScrollEnabled = false
        tableview.delegate = self
        tableview.dataSource = self
        return  tableview
    }()
    
    var delegate:SettingViewDelegate?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(tableView)
        tableView.register(UINib(nibName: "SettingTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        tableView.snp.makeConstraints({
            make in
            make.width.height.left.top.equalToSuperview()
        })
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    



}


// MARK: - TableViewDelegate
extension SettingTableView:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return SettingModel.share.section.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  SettingModel.share.titles[section]!.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
       return SettingModel.share.section[section]
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         let cell =  self.tableView.dequeueReusableCell(withIdentifier: "cell") as! SettingTableViewCell
        cell.selectionStyle = .none
 
        if(indexPath.section == 0){
            cell.openSwitch.isHidden = false
            cell.rightNextImage.isHidden = true
        }else{
            cell.openSwitch.isHidden = true
            cell.rightNextImage.isHidden = false
        }
        
        cell.textLabel?.text = SettingModel.share.titles[indexPath.section]?[indexPath.row]
         return cell
    }
    
    //点击跳转
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 { return }
        switch indexPath.row {
        case 0:
           _ =  UpdateManager()
        case 1:
            
            delegate?.push(vc: FolderWebViewController(weburl:URL(string: "https://www.jianshu.com/p/b8fe2bb0a9b6")! ))
        case 2:
            delegate?.push(vc: FolderWebViewController(weburl:URL(string: "http://www.liuyongvae.com")! ))
        case 3:
            delegate?.push(vc: FolderWebViewController(weburl:URL(string: "https://github.com/liuyongVAE/FolderCamera/blob/master/README.md")! ))
        case 4:
             UpdateManager.commentApp()
        default:
            break
        }
        
        
    }
    
    
    
}
