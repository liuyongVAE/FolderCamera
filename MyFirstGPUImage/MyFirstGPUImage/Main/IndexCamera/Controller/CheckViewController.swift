//
//  CheckViewController.swift
//  MyFirstGPUImage
//
//  Created by LiuYong on 2018/7/26.
//  Copyright © 2018年 LiuYong. All rights reserved.
//

import UIKit
import Photos


class CheckViewController: UIViewController {

    
    //UI
    lazy var saveButton:UIButton = {
        let widthofme = getWidth(190)
        var btn = UIButton(frame: CGRect(x: SCREEN_WIDTH/2 - widthofme/2 , y: getHeight(1543), width: widthofme, height: widthofme))
        btn.layer.cornerRadius = widthofme/2
        btn.setImage(#imageLiteral(resourceName: "确认") , for: .normal)
        btn.addTarget(self, action: #selector(self.savePhoto), for: .touchUpInside)
        return btn
    }()
    
    lazy var backButton:UIButton = {
        var btn = NewUIButton(frame: CGRect(x:getWidth(109), y: getHeight(1593), width:getWidth(102) , height: getHeight(171)))
        btn.setImage(#imageLiteral(resourceName: "返回") , for: .normal)
        btn.setTitle("返回", for: .normal)
        btn.setTitleColor(UIColor.black, for: .normal)
        btn.addTarget(self, action: #selector(self.back), for: .touchUpInside)
        return btn
    }()
    
    
    lazy var defaultBottomView:UIView = {
        let v = UIView(frame: FloatRect(0, SCREEN_HEIGHT*3/4, SCREEN_WIDTH, SCREEN_HEIGHT/4))
        v.backgroundColor = UIColor.white
        
        return v
    }()
    
    lazy var photoView:UIImageView = {
        let v = UIImageView(frame: FloatRect(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT*3/4))
        v.image = image
        
        return v
    }()
    
    
    //属性
    
    let image:UIImage!
    
    
    
    
    
    
    
    //初始化
    init(image:UIImage){
        self.image = image
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(photoView)
        view.addSubview(defaultBottomView)
        view.addSubview(saveButton)
        view.addSubview(backButton)

        // Do any additional setup after loading the view.
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

extension CheckViewController{
    
    //按钮点击
    
    @objc func  savePhoto(){
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        self.dismiss(animated: false, completion: nil)

    }
    
    @objc func back(){
        self.dismiss(animated: false, completion: nil)
        
    }
    

    
    
    
    
}
