//
//  TouristAttractionFormViewController.swift
//  trapAdvisor
//
//  Created by Victor Springer on 25/06/17.
//  Copyright © 2017 Victor Springer. All rights reserved.
//

import UIKit

class TouristAttractionFormViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var location: UITextField!
    @IBOutlet weak var visitDate: UITextField!
    @IBOutlet weak var rating: UITextField!
    @IBOutlet weak var pros: UITextView!
    @IBOutlet weak var cons: UITextView!
    @IBOutlet weak var tableView: UITableView!
    var autocompleteList = [TouristAttractionAutocomplete]()
    var tripId: Int!
    var taId: Int?
    
    @IBAction func nameFieldChanged(_ sender: UITextField) {
        if (name.text?.characters.count)! >= 5 {
            autocompleteList = retrieveTouristAttractions(namePart: name.text!)
            if autocompleteList.count > 0 {
                tableView.reloadData()
                tableView.isHidden = false
            } else {
                tableView.isHidden = true
            }
        } else {
            tableView.isHidden = true
        }
    }
    
    @IBAction func focusOut(_ sender: UITextField) {
        tableView.isHidden = true
    }
    
    @IBAction func dateFieldEditing(_ sender: UITextField) {
        let datePickerView = UIDatePicker()
        datePickerView.datePickerMode = UIDatePickerMode.date
        sender.inputView = datePickerView
        datePickerView.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
    }
    
    public func dateChanged(_ sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        visitDate.text = dateFormatter.string(from: sender.date)
    }
    
    @IBAction func saveTouristAttraction(_ sender: Any) {
        if !validateForm() {
            return
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        let dateD = dateFormatter.date(from: visitDate.text!)
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let date = dateFormatter.string(from: dateD!)
        
        let rtg = rating.text!.replacingOccurrences(of: ",", with: ".")
        
        var ta = [String: Any]()
        ta["id"] = taId
        ta["name"] = name.text
        ta["location"] = location.text
        ta["visitDate"] = date
        ta["rating"] = Float64(rtg)
        ta["pros"] = pros.text
        ta["cons"] = cons.text
        ta["tripId"] = tripId
        
        let jsonData = try? JSONSerialization.data(withJSONObject: ta, options: .prettyPrinted)
        
        let url = URL(string: "http://trapadvisor.us-east-2.elasticbeanstalk.com/v1/ta/store")
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        
        let semaphore = DispatchSemaphore(value: 0)
        
        let task = URLSession.shared.dataTask(with: request) {
            (data, response, error) in
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 401 {
                    self.performSegue(withIdentifier: "TAFormToLogin", sender: nil)
                } else if httpResponse.statusCode != 201 {
                    self.showToast(message: "⨉ Falha na requisição", type: "danger")
                    return
                }
            }
            if let data = data {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Int] {
                        self.taId = json["touristAttractionId"]!
                    }
                } catch {
                    print("json serialization failed")
                }
            }
            
            semaphore.signal()
        }
        
        task.resume()
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        
        let vcsCount = self.navigationController?.viewControllers.count
        let tripFormVC = self.navigationController?.viewControllers[vcsCount!-2] as! TripFormViewController
        tripFormVC.touristAttractions.append(name.text! + " - " + location.text!)
        _ = navigationController?.popViewController(animated: true)
    }
    
    private func validateForm() -> Bool {
        if (name.text?.isEmpty)! || (location.text?.isEmpty)! || (visitDate.text?.isEmpty)! ||
            (rating.text?.isEmpty)! || (pros.text?.isEmpty)! || (cons.text?.isEmpty)! {
            showToast(message: "⚠︎ Todos os campos devem ser preenchidos", type: "warning")
            return false
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        
        var vDate: Date
        if let vDateF = dateFormatter.date(from: visitDate.text!) {
            vDate = vDateF
        } else {
            showToast(message: "⚠︎ Data da visita inválida", type: "warning")
            return false
        }
        if vDate > Date() {
            showToast(message: "⚠︎ Data de visita posterior à data atual", type: "warning")
            return false
        }
        
        let rtgS = rating.text!.replacingOccurrences(of: ",", with: ".")
        if let rtg = Float64(rtgS) {
            if rtg > 10.0 || rtg < 0.0 {
                showToast(message: "⚠︎ Nota (avaliação) inválida", type: "warning")
                return false
            }
        } else {
            showToast(message: "⚠︎ Nota (avaliação) inválida", type: "warning")
            return false
        }
        
        return true
    }
    
    private func retrieveTouristAttractions(namePart: String) -> [TouristAttractionAutocomplete] {
        var endPoint = "http://trapadvisor.us-east-2.elasticbeanstalk.com/v1/ta/find/name_part/"
        endPoint += namePart.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        let url = URL(string: endPoint)
        let urlRequest = URLRequest(url: url!)
        
        let session = URLSession.shared
        
        let semaphore = DispatchSemaphore(value: 0)
        
        var tas = [TouristAttractionAutocomplete]()
        
        let task = session.dataTask(with: urlRequest) {
            (data, response, error) in
            guard error == nil else {
                print("error to find tourist attractions")
                print(error!)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 401 {
                    self.performSegue(withIdentifier: "TAFormToLogin", sender: nil)
                }
            }
            
            if let data = data {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: [String]] {
                        for index in 0..<json.count {
                            tas.append(TouristAttractionAutocomplete(values: json[String(index)]!)!)
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
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return autocompleteList.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TouristAttractionAutocompleteCell", for: indexPath) as! TableViewCell
        
        cell.name?.text = autocompleteList[indexPath.row].name + " - " + autocompleteList[indexPath.row].location
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        name.text = autocompleteList[indexPath.row].name
        location.text = autocompleteList[indexPath.row].location
        tableView.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.isHidden = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        switch identifier {
        case "TAFormToLogin":
            return logout()
        default:
            return true
        }
    }
}
