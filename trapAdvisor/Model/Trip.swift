//
//  Trip.swift
//  trapAdvisor
//
//  Created by Victor Springer on 20/06/17.
//  Copyright © 2017 Victor Springer. All rights reserved.
//

import UIKit

public struct Trip {
    let id: Int
    let name: String
    let startDate: String
    let endDate: String
    let rating: Float64
    let review: String
    let travellerId: Int
    
    init?(json: [String: Any]) {
        guard let id = json["id"] as? Int,
            let name = json["name"] as? String,
            let startDate = json["startDate"] as? String,
            let endDate = json["endDate"] as? String,
            let rating = json["rating"] as? Float64,
            let review = json["review"] as? String,
            let travellerId = json["travellerId"] as? Int
            else {
                return nil
        }
        
        self.id = id
        self.name = name
        self.startDate = startDate
        self.endDate = endDate
        self.rating = rating
        self.review = review
        self.travellerId = travellerId
    }
}
