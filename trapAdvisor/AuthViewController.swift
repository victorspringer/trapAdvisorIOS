//
//  AuthController.swift
//  trapAdvisor
//
//  Created by Victor Springer on 16/06/17.
//  Copyright © 2017 Victor Springer. All rights reserved.
//

import UIKit

class AuthViewController: UIViewController, UIWebViewDelegate {
    
    @IBOutlet weak var fbWebView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //hiding the navigation button
        let backButton = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: navigationController, action: nil)
        navigationItem.leftBarButtonItem = backButton
        
        let url = URL(string: "http://trapadvisor.us-east-2.elasticbeanstalk.com/login")
        let urlRequest = URLRequest(url: url!)
        
        fbWebView.delegate = self
        fbWebView.loadRequest(urlRequest)
    }
    
    public func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if request.url?.absoluteString.range(of: "trapadvisor.us-east-2.elasticbeanstalk.com/auth_callback") != nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                _ = self.navigationController?.popToRootViewController(animated: false)
            })
        }
        
        return true
    }
}
