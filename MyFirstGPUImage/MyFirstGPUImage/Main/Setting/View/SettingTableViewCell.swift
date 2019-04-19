//
//  SettingTableViewCell.swift
//  MyFirstGPUImage
//
//  Created by LiuYong on 2018/9/10.
//  Copyright © 2018年 LiuYong. All rights reserved.
//

import UIKit


protocol getCellIndex{
    func getCellIndex()->Int
}


class SettingTableViewCell: UITableViewCell {

    @IBOutlet weak var openSwitch: UISwitch!
    @IBOutlet weak var rightNextImage: UIImageView!
    var delegate:getCellIndex?
    override func awakeFromNib() {
        super.awakeFromNib()
        openSwitch.addTarget(self, action: #selector(switchValueChanged(_:)), for: .valueChanged)
        openSwitch.snp.makeConstraints({
            make in
            make.height.equalTo(25)
            make.width.equalTo(50)
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-10)
        })
        rightNextImage.snp.makeConstraints({
            make in
            make.height.width.equalTo(30)
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-10)
        })
        
       guard let flag = UserDefaults.standard.value(forKey: "isFaceLayer")else{
            return
        }
        
        openSwitch.setOn(flag as! Bool, animated: false)
        
 
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @objc func switchValueChanged(_ sw:UISwitch){
        SettingModel.share.setSelectedValue(index: delegate?.getCellIndex() ?? 0, value: sw.isOn)

    }
    
}
