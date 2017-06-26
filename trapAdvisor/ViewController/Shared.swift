//
//  Shared.swift
//  trapAdvisor
//
//  Created by Victor Springer on 25/06/17.
//  Copyright © 2017 Victor Springer. All rights reserved.
//

import UIKit

extension UIViewController {
    
    public func showToast(message: String, type: String) {
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 150, y: self.view.frame.size.height-55, width: 300, height: 35))
        
        switch type {
        case "success":
            toastLabel.backgroundColor = UIColor.green.withAlphaComponent(0.7)
        case "danger":
            toastLabel.backgroundColor = UIColor.red.withAlphaComponent(0.7)
        case "warning":
            toastLabel.backgroundColor = UIColor.orange.withAlphaComponent(0.7)
        default:
            toastLabel.backgroundColor = UIColor.green.withAlphaComponent(0.7)
        }
        
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.font = UIFont(name: "Helvetica", size: 15.0)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 2.5, delay: 1.5, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
    
    public func dismissKeyboard() {
        view.endEditing(true)
    }
    
    public func logout() -> Bool {
        let endPoint = "http://trapadvisor.us-east-2.elasticbeanstalk.com/logout"
        var loggedOut = false
        
        guard let url = URL(string: endPoint) else {
            print("Error: cannot create URL")
            return false
        }
        
        let urlRequest = URLRequest(url: url)
        
        let session = URLSession.shared
        
        let semaphore = DispatchSemaphore(value: 0)
        
        let task = session.dataTask(with: urlRequest) {
            (_, response, error) in
            guard error == nil else {
                print("error trying to logout")
                print(error!)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    loggedOut = true
                } else if httpResponse.statusCode == 401 {
                    let storage = HTTPCookieStorage.shared
                    for cookie in storage.cookies! {
                        if cookie.name == "travellerID" || cookie.name == "sessionToken" {
                            storage.deleteCookie(cookie)
                        }
                    }
                    loggedOut = true
                }
            }
            semaphore.signal()
        }
        
        task.resume()
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        
        return loggedOut
    }
}
