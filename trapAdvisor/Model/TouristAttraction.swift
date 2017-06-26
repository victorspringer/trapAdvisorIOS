//
//  TouristAttraction.swift
//  trapAdvisor
//
//  Created by Victor Springer on 19/06/17.
//  Copyright © 2017 Victor Springer. All rights reserved.
//

import UIKit

public struct TouristAttraction {
    let id: Int
    let name: String
    let location: String
    let visitDate: String
    let rating: Float64
    let pros: String
    let cons: String
    let tripId: Int
    
    init?(json: [String: Any]) {
        guard let id = json["id"] as? Int,
            let name = json["name"] as? String,
            let location = json["location"] as? String,
            let visitDate = json["visitDate"] as? String,
            let rating = json["rating"] as? Float64,
            let pros = json["pros"] as? String,
            let cons = json["cons"] as? String,
            let tripId = json["tripId"] as? Int
            else {
                return nil
        }
        
        self.id = id
        self.name = name
        self.location = location
        self.visitDate = visitDate
        self.rating = rating
        self.pros = pros
        self.cons = cons
        self.tripId = tripId
    }
}
