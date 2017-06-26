//
//  TripFormViewController.swift
//  trapAdvisor
//
//  Created by Victor Springer on 24/06/17.
//  Copyright © 2017 Victor Springer. All rights reserved.
//

import UIKit

class TripFormViewController: UIViewController {
    
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var startDate: UITextField!
    @IBOutlet weak var endDate: UITextField!
    @IBOutlet weak var rating: UITextField!
    @IBOutlet weak var review: UITextView!
    var tripId: Int?
    var success = false
    var touristAttractions = [String]()
    
    @IBAction func dateFieldEditing(_ sender: UITextField) {
        let datePickerView = UIDatePicker()
        datePickerView.datePickerMode = UIDatePickerMode.date
        sender.inputView = datePickerView
        datePickerView.tag = sender.tag
        datePickerView.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
    }
    
    func dateChanged(_ sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        if sender.tag == startDate.tag {
            startDate.text = dateFormatter.string(from: sender.date)
        } else {
            endDate.text = dateFormatter.string(from: sender.date)
        }
    }
    
    @IBAction func saveTrip(_ sender: Any) {
        if !validateForm() {
            success = false
            return
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        let sDateD = dateFormatter.date(from: startDate.text!)
        let eDateD = dateFormatter.date(from: endDate.text!)
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let sDate = dateFormatter.string(from: sDateD!)
        let eDate = dateFormatter.string(from: eDateD!)
        
        let rtg = rating.text!.replacingOccurrences(of: ",", with: ".")
        
        var trip = [String: Any]()
        trip["id"] = tripId
        trip["name"] = name.text
        trip["startDate"] = sDate
        trip["endDate"] = eDate
        trip["rating"] = Float64(rtg)
        trip["review"] = review.text
        
        if let cookies = HTTPCookieStorage.shared.cookies {
            for cookie in cookies {
                if cookie.name == "travellerID" {
                    trip["travellerId"] = Int(cookie.value)
                }
            }
        }
        
        let jsonData = try? JSONSerialization.data(withJSONObject: trip, options: .prettyPrinted)
        
        let url = URL(string: "http://trapadvisor.us-east-2.elasticbeanstalk.com/v1/trip/store")
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        
        let semaphore = DispatchSemaphore(value: 0)
        
        let task = URLSession.shared.dataTask(with: request) {
            (data, response, error) in
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 401 {
                    self.performSegue(withIdentifier: "TripFormToLogin", sender: nil)
                } else if httpResponse.statusCode != 201 {
                    self.showToast(message: "⨉ Falha na requisição", type: "danger")
                    return
                }
            }
            if let data = data {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Int] {
                        self.tripId = json["tripId"]!
                    }
                } catch {
                    print("json serialization failed")
                }
            }
            
            semaphore.signal()
        }
        
        task.resume()
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        
        success = true
        showToast(message: "✓ Viagem salva com sucesso", type: "success")
    }
    
    private func validateForm() -> Bool {
        if (name.text?.isEmpty)! || (startDate.text?.isEmpty)! || (endDate.text?.isEmpty)! ||
            (rating.text?.isEmpty)! || (review.text?.isEmpty)! {
            showToast(message: "⚠︎ Todos os campos devem ser preenchidos", type: "warning")
            return false
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        
        var sDate: Date
        var eDate: Date
        if let sDateF = dateFormatter.date(from: startDate.text!) {
            sDate = sDateF
        } else {
            showToast(message: "⚠︎ Data de partida inválida", type: "warning")
            return false
        }
        if let eDateF = dateFormatter.date(from: endDate.text!) {
            eDate = eDateF
        } else {
            showToast(message: "⚠︎ Data da volta inválida", type: "warning")
            return false
        }
        if sDate > Date() {
            showToast(message: "⚠︎ Data de partida posterior à data atual", type: "warning")
            return false
        }
        if eDate > Date() {
            showToast(message: "⚠︎ Data da volta posterior à data atual", type: "warning")
            return false
        }
        if sDate > eDate {
            showToast(message: "⚠︎ Data de partida posterior à volta", type: "warning")
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startDate.tag = 1
        endDate.tag = 2
        tripId = nil
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if tripId != nil && touristAttractions.count > 0 {
            if touristAttractions.count == 1 {
                if review.text.range(of: touristAttractions[0]) == nil {
                    review.text! += "\n\nLocais visitados:\n" + touristAttractions[0]
                }
            } else {
                if review.text.range(of: touristAttractions[touristAttractions.count-1]) == nil {
                    review.text! += "\n" + touristAttractions[touristAttractions.count-1]
                }
            }
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        switch identifier {
        case "TripFormToLogin":
            return logout()
        case "AddTripToAddTA":
            saveTrip(self)
            return success
        default:
            return true
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddTripToAddTA" {
            if let toViewController = segue.destination as? TouristAttractionFormViewController {
                toViewController.tripId = tripId
            }
        }
    }
}
