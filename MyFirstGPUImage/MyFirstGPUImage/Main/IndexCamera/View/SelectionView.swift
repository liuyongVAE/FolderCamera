//
//  SelectionView.swift
//  MyFirstGPUImage
//
//  Created by LiuYong on 2018/8/27.
//  Copyright © 2018年 LiuYong. All rights reserved.
//

import UIKit
protocol selectedDelegate {
    
    /// 选中操作
    ///
    /// - Parameter index: left 0,right 1
    func didSelected(index:Int)
}


class SelectionView: UIView {

    var titles = [String]()
    let point = UIView()
    var titleWidth:CGFloat = 0
    let interval:CGFloat = 25//title高度
    let naviOffset:CGFloat = 64 // 导航栏偏移
    var titleButton = [UIButton]()
    let topback = UIView()
    //总宽度
    let ssWidth:CGFloat = 260
    var currentIndex = 0
    var delegate:selectedDelegate?
    
    init(frame: CGRect,titles: [String],parentViewController: UIViewController?) {
        self.titles = titles
        super.init(frame: frame)
        self.setTitle()
        addGesture()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setTitle(){
        

        
        if titles.count<5{
            titleWidth =  (ssWidth/CGFloat(titles.count));
        }else{
            titleWidth = ssWidth/5
        }
        self.addSubview(topback)
        topback.snp.makeConstraints({
            make in
            make.top.bottom.equalToSuperview()
            make.centerX.equalToSuperview().offset(titleWidth*2)
            make.width.equalTo(ssWidth)
        })
        for i in 0...self.titles.count-1{
            let tyest = UIButton();
            tyest.setTitle(titles[i], for: .normal)
            tyest.setTitleColor(UIColor.white, for: .normal)
            tyest.frame = CGRect(x: CGFloat(i)*titleWidth,y:10,width: (titleWidth),height:interval)
            tyest.backgroundColor = UIColor.clear
            tyest.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
            tyest.setTitleColor(UIColor.white, for: .normal)
            tyest.tag = i
            tyest.titleLabel?.adjustsFontSizeToFitWidth = true
            tyest.addTarget(self, action: #selector(changeto(btn:)), for: .touchUpInside)
            titleButton.append(tyest)
        }
        
        for i in titleButton{
            i.setTitleColor(UIColor.white, for: .selected)
            self.topback.addSubview(i)
        }
        
        titleButton[0].isSelected = true
        
        
        
        point.backgroundColor = UIColor.white
        self.addSubview(point)
        point.snp.makeConstraints({
            make in
            make.centerX.equalToSuperview()
            make.width.height.equalTo(5)
            make.top.equalToSuperview().offset(5)
        })
        point.layer.cornerRadius = 2.5
        //point.layer.masksToBounds = true

        
        
        
        
        
    }
    
    
    @objc  func  changeto(btn:UIButton){
        currentIndex = btn.tag
        print(currentIndex)
        //如果是点击事件，和滑动的index是相反的，这里需要进行处理
        let ff = self.titles.count-currentIndex-1
        delegate?.didSelected(index:ff)
        transfrom(index:currentIndex)
    }
 
 
    
}

extension SelectionView{
    
    func addGesture(){
        let swip = UISwipeGestureRecognizer(target: self, action: #selector(swipLeft))
        swip.direction = .left
        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(swip)
        let swip2 = UISwipeGestureRecognizer(target: self, action: #selector(swipRight))
        swip2.direction = .right
        self.addGestureRecognizer(swip2)
    }

    @objc func swipLeft(){
        print("left",currentIndex)
        if currentIndex < titleButton.count-1 && currentIndex >= 0 {
            delegate?.didSelected(index: currentIndex)

            currentIndex = currentIndex+1
            transfrom(index: currentIndex)
            
        }
    }
    @objc func swipRight(){
        print("right",currentIndex)

        if currentIndex < titleButton.count && currentIndex > 0{
            delegate?.didSelected(index: currentIndex)

            currentIndex = currentIndex-1
            transfrom(index: currentIndex)
        }
    }

    
    func transfrom(index:Int){
        for i in self.titleButton{
            if i.tag != index{
                i.isSelected = false
            }else{
                i.isSelected = true
            }
        }
        UIView.animate(withDuration: 0.3, animations: {
            self.topback.transform = CGAffineTransform(translationX: (self.titleWidth)*CGFloat(-index), y: 0)

        })
    
    }
    

}
