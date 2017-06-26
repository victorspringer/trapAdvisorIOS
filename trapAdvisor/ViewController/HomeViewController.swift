//
//  HomeViewController.swift
//  trapAdvisor
//
//  Created by Victor Springer on 15/06/17.
//  Copyright © 2017 Victor Springer. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBAction func buttonLogout(_ sender: UIButton) {}
    var menuShowing = false
    
    @IBAction func openMenu(_ sender: Any) {
        if !menuShowing {
            leadingConstraint.constant = 0
        } else {
            leadingConstraint.constant = -210
        }
        
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
        })
        
        menuShowing = !menuShowing
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        menuView.layer.shadowOpacity = 0.5
        menuView.layer.shadowRadius = 3
        
        let traveller = retrieveTravellerData()
        
        if traveller != nil {
            if let checkedUrl = URL(string: (traveller?.picture)!) {
                downloadImage(url: checkedUrl)
            }
            
            profilePic.layer.borderWidth = 5
            profilePic.layer.borderColor = UIColor.white.cgColor
            profilePic.layer.cornerRadius = profilePic.frame.width / 2
            profilePic.clipsToBounds = true
            welcomeLabel.text = "Bem vindx " + (traveller?.name)!
        }
    }
    
    private func retrieveTravellerData() -> Traveller? {
        var endPoint = "http://trapadvisor.us-east-2.elasticbeanstalk.com/v1/traveller/find/"
        
        if let cookies = HTTPCookieStorage.shared.cookies {
            for cookie in cookies {
                if cookie.name == "travellerID" {
                    endPoint += cookie.value
                }
            }
        }
        
        let url = URL(string: endPoint)
        let urlRequest = URLRequest(url: url!)
        
        let session = URLSession.shared
        
        let semaphore = DispatchSemaphore(value: 0)
        
        let empty = ["id": "", "name": ""]
        var traveller = Traveller(json: empty)
        
        let task = session.dataTask(with: urlRequest) {
            (data, response, error) in
            guard error == nil else {
                print("error to find traveller")
                print(error!)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 401 {
                    self.performSegue(withIdentifier: "HomeToLogin", sender: nil)
                }
            }
            
            if let data = data {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: String] {
                        if let trav = Traveller(json: json) {
                            traveller = trav
                        }
                    }
                } catch {
                    print("json serialization failed")
                }
            }
            
            semaphore.signal()
        }
        
        task.resume()
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        
        return traveller
    }
    
    private func getDataFromUrl(url: URL, completion: @escaping (_ data: Data?, _  response: URLResponse?, _ error: Error?) -> Void) {
        URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            completion(data, response, error)
            }.resume()
    }
    
    private func downloadImage(url: URL) {
        getDataFromUrl(url: url) { (data, response, error)  in
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async() { () -> Void in
                self.profilePic.image = UIImage(data: data)
            }
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        switch identifier {
            case "HomeToLogin":
                return logout()
            default:
                return true
        }
    }
}
