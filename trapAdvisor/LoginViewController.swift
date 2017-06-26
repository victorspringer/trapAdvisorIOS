//
//  LoginViewController.swift
//  trapAdvisor
//
//  Created by Victor Springer on 14/06/17.
//  Copyright © 2017 Victor Springer. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var fbButton: UIButton!
    @IBAction func buttonLogin(_ sender: UIButton) {}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //hiding the navigation button
        let backButton = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: navigationController, action: nil)
        navigationItem.leftBarButtonItem = backButton
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fbButton.isHidden = true
        activityIndicator.startAnimating()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        auth()
    }
    
    private func auth() {
        if let cookies = HTTPCookieStorage.shared.cookies {
            var required = 0
            for cookie in cookies {
                if cookie.name == "travellerID" {
                    required += 1
                }
                if cookie.name == "sessionToken" {
                    required += 1
                }
                if required == 2 {
                    performSegue(withIdentifier: "LoginToHome", sender: nil)
                    return
                }
            }
        }
        
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
        fbButton.isHidden = false
    }
}
