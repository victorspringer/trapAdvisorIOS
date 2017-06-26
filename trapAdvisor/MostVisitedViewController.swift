//
//  MostVisitedViewController.swift
//  trapAdvisor
//
//  Created by Victor Springer on 19/06/17.
//  Copyright © 2017 Victor Springer. All rights reserved.
//

import UIKit

class MostVisitedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var menuView: UIView!
    @IBAction func buttonLogout(_ sender: UIButton) {}
    var menuShowing = false
    var touristAttractions = [TouristAttractionRank]()
    
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
        
        touristAttractions = retrieveTouristAttractions()
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return touristAttractions.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TouristAttractionCell", for: indexPath) as! TableViewCell
        
        cell.name?.text = touristAttractions[indexPath.row].name
        cell.location?.text = touristAttractions[indexPath.row].location
        cell.total?.text = touristAttractions[indexPath.row].total
        
        return cell
    }
    
    private func retrieveTouristAttractions() -> [TouristAttractionRank] {
        let endPoint = "http://trapadvisor.us-east-2.elasticbeanstalk.com/v1/ta/most_visited"
        let url = URL(string: endPoint)
        let urlRequest = URLRequest(url: url!)
        
        let session = URLSession.shared
        
        let semaphore = DispatchSemaphore(value: 0)

        var tas = [TouristAttractionRank]()
        
        let task = session.dataTask(with: urlRequest) {
            (data, response, error) in
            guard error == nil else {
                print("error to find tourist attractions")
                print(error!)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 401 {
                    self.performSegue(withIdentifier: "MostVisitedToLogin", sender: nil)
                }
            }
            
            if let data = data {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: [String]] {
                        for index in 0..<json.count {
                            tas.append(TouristAttractionRank(values: json[String(index)]!)!)
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
        
        return tas
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        switch identifier {
        case "MostVisitedToLogin":
            return logout()
        default:
            return true
        }
    }
}
