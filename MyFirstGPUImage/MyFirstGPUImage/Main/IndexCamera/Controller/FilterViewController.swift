//
//  FilterViewController.swift
//  MyFirstGPUImage
//
//  Created by LiuYong on 2018/8/3.
//  Copyright © 2018年 LiuYong. All rights reserved.
//

import UIKit

class FilterViewController: UIViewController,FillterSelectViewDelegate{
    func switchFillter(index: Int) {
        
    }
    
    
    
    lazy var cameraFillterView:FillterSelectView = {
        let v = FillterSelectView()
        v.backgroundColor = UIColor.white
        
        v.filterDelegate = self
        return v
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(cameraFillterView)
        self.view.backgroundColor = UIColor.clear
        cameraFillterView.snp.makeConstraints({
                make in
                make.bottom.equalToSuperview()
                make.width.equalToSuperview()
                make.height.equalTo(SCREEN_HEIGHT*1/4)
            })
        // Do any additional setup after loading the view.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.dismiss(animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
