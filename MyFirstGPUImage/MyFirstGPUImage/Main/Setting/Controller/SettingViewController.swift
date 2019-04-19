//
//  SettingViewController.swift
//  MyFirstGPUImage
//
//  Created by LiuYong on 2018/9/10.
//  Copyright © 2018年 LiuYong. All rights reserved.
//

import UIKit

class SettingViewController: UIViewController {

    //MARK: - Lazy Loading
    lazy var tableView:UIView = {
        let v = SettingTableView(frame: CGRect.zero)
        v.delegate = self
        return v
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = false
        navigationItem.title = "设置"
        setUI()

        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
       //self.navigationController?.navigationBar.isHidden = true
    }
    
    
    func setUI(){
        view.addSubview(tableView)
        tableView.snp.makeConstraints({
            make in
            make.width.height.left.top.equalToSuperview()
            
        })
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
extension SettingViewController:SettingViewDelegate{
    func push(vc: UIViewController) {
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
}
