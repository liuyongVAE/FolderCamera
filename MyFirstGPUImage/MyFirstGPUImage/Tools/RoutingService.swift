//
//  RoutingService.swift
//  MyFirstGPUImage
//
//  Created by 刘勇 on 2019/2/12.
//  Copyright © 2019 LiuYong. All rights reserved.
//

import Foundation

class RoutingService: NSObject {
    
    
    class func presentVC(vc :UIViewController!){
        guard let nav =  RoutingService.getCurrentVC().navigationController else {
            vc.present(vc, animated: true, completion: nil)
            return
        }
        nav.present(vc, animated: true, completion: nil)
        
    }
    class func pushVC(vc :UIViewController!){
        guard let nav =  RoutingService.getCurrentVC().navigationController else {
            return
        }
        nav.pushViewController(vc, animated: true)
    }
    
    class func getCurrentVC() -> UIViewController {
        let keywindow = (UIApplication.shared.delegate as! AppDelegate).window//UIApplication.shared.keyWindow使用此有时会崩溃
        let firstView: UIView = (keywindow?.subviews.first)!
        let secondView: UIView = firstView.subviews.first!
        var vc =  RoutingService.viewForController(view: secondView)!
        vc = ((vc as! UITabBarController).selectedViewController! as! UINavigationController).visibleViewController!
        
        return vc
    }
    
    private class func viewForController(view:UIView)->UIViewController?{
        var next:UIView? = view
        repeat{
            if let nextResponder = next?.next, nextResponder is UIViewController {
                return (nextResponder as! UIViewController)
            }
            next = next?.superview
        }while next != nil
        return nil
    }
    
    
    
    // 获取顶层控制器 根据window
   class func getTopVC() -> (UIViewController?) {
        var window = UIApplication.shared.keyWindow
        //是否为当前显示的window
        if window?.windowLevel != UIWindowLevelNormal{
            let windows = UIApplication.shared.windows
            for  windowTemp in windows{
                if windowTemp.windowLevel == UIWindowLevelNormal{
                    window = windowTemp
                    break
                }
            }
        }
        
        let vc = window?.rootViewController
        return RoutingService.getTopVC(withCurrentVC: vc)
    }
    
    ///根据控制器获取 顶层控制器
   private class func getTopVC(withCurrentVC VC :UIViewController?) -> UIViewController? {
        
        if VC == nil {
            print("找不到顶层控制器")
            return nil
        }
        
        if let presentVC = VC?.presentedViewController {
            //modal出来的 控制器
            return getTopVC(withCurrentVC: presentVC)
        }
        else if let tabVC = VC as? UITabBarController {
            // tabBar 的跟控制器
            if let selectVC = tabVC.selectedViewController {
                return getTopVC(withCurrentVC: selectVC)
            }
            return nil
        } else if let naiVC = VC as? UINavigationController {
            // 控制器是 nav
            return getTopVC(withCurrentVC:naiVC.visibleViewController)
        }
        else {
            // 返回顶控制器
            return VC
        }
    }
    
}


