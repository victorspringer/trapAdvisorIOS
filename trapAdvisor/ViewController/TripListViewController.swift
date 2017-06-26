//
//  TripListViewController.swift
//  trapAdvisor
//
//  Created by Victor Springer on 20/06/17.
//  Copyright © 2017 Victor Springer. All rights reserved.
//

import UIKit

class TripListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var menuView: UIView!
    @IBAction func buttonLogout(_ sender: UIButton) {}
    var menuShowing = false
    var trips = [Trip]()
    
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
        
        trips = retrieveTrips()
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trips.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TripCell", for: indexPath) as! TableViewCell
        
        cell.name?.text = trips[indexPath.row].name
        cell.location?.text = trips[indexPath.row].startDate
        cell.total?.text = String(trips[indexPath.row].rating)
        
        return cell
    }
    
    private func retrieveTrips() -> [Trip] {
        var endPoint = "http://trapadvisor.us-east-2.elasticbeanstalk.com/v1/trip/find/traveller/"
        
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
        
        var tas = [Trip]()
        
        let task = session.dataTask(with: urlRequest) {
            (data, response, error) in
            guard error == nil else {
                print("error to find tourist attractions")
                print(error!)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 401 {
                    self.performSegue(withIdentifier: "TripListToLogin", sender: nil)
                }
            }
            
            if let data = data {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
                        for j in json {
                            tas.append(Trip(json: j)!)
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
        case "TripListToLogin":
            return logout()
        default:
            return true
        }
    }
}
