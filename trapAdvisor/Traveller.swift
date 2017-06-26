//
//  Traveller.swift
//  trapAdvisor
//
//  Created by Victor Springer on 18/06/17.
//  Copyright © 2017 Victor Springer. All rights reserved.
//

import UIKit

public struct Traveller {
    let id: String
    let name: String
    let picture: String
    
    init?(json: [String: String]) {
        self.id = json["id"]!
        self.name = json["name"]!
        self.picture = "http://graph.facebook.com/" + self.id + "/picture?type=normal"
    }
}
