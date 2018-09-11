//
//  UpdateManager.swift
//  MyFirstGPUImage
//
//  Created by LiuYong on 2018/9/11.
//  Copyright © 2018年 LiuYong. All rights reserved.
//

import Foundation

class UpdateManager:NSObject{
    
    
    /// app版本更新检测
    ///
    /// - Parameter appId: apple ID - 开发者帐号对应app处获取
    override init() {
        super.init()
        let appId:String = "1421026171"
        //获取appstore上的最新版本号
        let appUrl = URL.init(string: "http://itunes.apple.com/lookup?id=" + appId)
        let appMsg = try? String.init(contentsOf: appUrl!, encoding: .utf8)
        let appMsgDict:NSDictionary = getDictFromString(jString: appMsg!)
        let appResultsArray:NSArray = (appMsgDict["results"] as? NSArray)!
        let appResultsDict:NSDictionary = appResultsArray.lastObject as! NSDictionary
        let appStoreVersion:String = appResultsDict["version"] as! String
        let appStoreVersion_Float:Float = Float(appStoreVersion)!
        
        //获取当前手机安装使用的版本号
        let localVersion:String = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
        let localVersion_Float:Float = Float(localVersion)!
        
        //用户是否设置不再提示
        let userDefaults = UserDefaults.standard
        let res = userDefaults.bool(forKey: "NO_ALERt_AGAIN")
        //appstore上的版本号大于本地版本号 - 说明有更新
        if appStoreVersion_Float > localVersion_Float && !res {
            let alertC = UIAlertController.init(title: "版本更新了", message: "是否前往更新", preferredStyle: .alert)
            let yesAction = UIAlertAction.init(title: "去更新", style: .default, handler: { (handler) in
                self.updateApp(appId:appId)
            })
            let noAction = UIAlertAction.init(title: "下次再说", style: .cancel, handler: nil)
            let cancelAction = UIAlertAction.init(title: "不再提示", style: .default, handler: { (handler) in
                self.noAlertAgain()
            })
            alertC.addAction(yesAction)
            alertC.addAction(noAction)
            alertC.addAction(cancelAction)
            UIApplication.shared.keyWindow?.rootViewController?.present(alertC, animated: true, completion: nil)
        }
        
    }
    
    //去更新
    func updateApp(appId:String) {
        let updateUrl:URL = URL.init(string: "http://itunes.apple.com/app/id" + appId)!
        UIApplication.shared.openURL(updateUrl)
       // UIApplication.shared.open(updateUrl, options: [:], completionHandler: nil)
    }
    
    //不再提示
    func noAlertAgain() {
        let userDefaults = UserDefaults.standard
        userDefaults.set(true, forKey: "NO_ALERt_AGAIN")
        userDefaults.synchronize()
    }
    
    //JSONString转字典
    func getDictFromString(jString:String) -> NSDictionary {
        let jsonData:Data = jString.data(using: .utf8)!
        let dict = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers)
        if dict != nil {
            return dict as! NSDictionary
        }
        
        return NSDictionary()
    }
    
    
}
