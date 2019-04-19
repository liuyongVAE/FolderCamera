//
//  FolderWebViewController.swift
//  MyFirstGPUImage
//
//  Created by LiuYong on 2018/9/11.
//  Copyright © 2018年 LiuYong. All rights reserved.
//

import UIKit
import WebKit
import ProgressHUD
class FolderWebViewController: UIViewController {

    var url:URL! = nil
    lazy var webview:WKWebView = {
        let configuration = WKWebViewConfiguration()
        let wb = WKWebView(frame: CGRect.zero, configuration: configuration)
        wb.navigationDelegate = self
        return wb
    }()
    
    
    init(weburl:URL) {
        url = weburl
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = false
        navigationItem.title = ""
        setUI()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //
    
    func setUI(){
        view.addSubview(webview)
        webview.snp.makeConstraints({
            make in
            make.width.height.top.bottom.equalToSuperview()
            
        })
        
        let request = URLRequest(url: url)
        webview.load(request)
        
    }
    

}


extension FolderWebViewController:WKNavigationDelegate{
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("请求")
        ProgressHUD.show()
    }
   
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        print("开始")
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        ProgressHUD.dismiss()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("失败")
    }
    
}
