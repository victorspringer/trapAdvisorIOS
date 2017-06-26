//
//  FriendsViewController.swift
//  trapAdvisor
//
//  Created by Victor Springer on 15/06/17.
//  Copyright © 2017 Victor Springer. All rights reserved.
//

import UIKit

class FriendsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var menuView: UIView!
    @IBAction func buttonLogout(_ sender: UIButton) {}
    var menuShowing = false
    var friends = [Traveller]()
    
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
        
        friends = retrieveFriends()
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendCell", for: indexPath) as! TableViewCell
        
        cell.name?.text = friends[indexPath.row].name
        if let checkedUrl = URL(string: friends[indexPath.row].picture) {
            downloadImage(url: checkedUrl, cell: cell)
        }
        cell.picture?.layer.borderWidth = 2
        cell.picture?.layer.borderColor = UIColor.white.cgColor
        cell.picture?.layer.cornerRadius = (cell.picture?.frame.width)! / 2
        cell.picture?.clipsToBounds = true
        
        return cell
    }
    
    private func retrieveFriends() -> [Traveller] {
        var endPoint = "http://trapadvisor.us-east-2.elasticbeanstalk.com/v1/friendship/find/traveller/"
        
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
        
        var friendsIds = [String]()
        
        let task = session.dataTask(with: urlRequest) {
            (data, response, error) in
            guard error == nil else {
                print("error to find friendships")
                print(error!)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 401 {
                    self.performSegue(withIdentifier: "FriendsToLogin", sender: nil)
                }
            }
            
            if let data = data {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
                        for j in json {
                            friendsIds.append(String(describing: j["friendId"]!))
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
        
        var friends = [Traveller]()
        for fId in friendsIds {
            let f = retrieveFriendData(id: fId)
            friends.append(f)
        }
        
        return friends
    }
    
    private func retrieveFriendData(id: String) -> Traveller {
        let endPoint = "http://trapadvisor.us-east-2.elasticbeanstalk.com/v1/traveller/find/" + id
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
                    self.performSegue(withIdentifier: "FriendsToLogin", sender: nil)
                }
            }
            
            if let data = data {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        if let trav = Traveller(json: json as! [String : String]) {
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
        
        return traveller!
    }
    
    private func getDataFromUrl(url: URL, completion: @escaping (_ data: Data?, _  response: URLResponse?, _ error: Error?) -> Void) {
        URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            completion(data, response, error)
            }.resume()
    }
    
    private func downloadImage(url: URL, cell: TableViewCell) {
        getDataFromUrl(url: url) { (data, response, error)  in
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async() { () -> Void in
                cell.picture?.image = UIImage(data: data)
            }
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        switch identifier {
        case "FriendsToLogin":
            return logout()
        default:
            return true
        }
    }
}
