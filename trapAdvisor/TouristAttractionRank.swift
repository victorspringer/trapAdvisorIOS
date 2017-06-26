//
//  TouristAttractionRank.swift
//  trapAdvisor
//
//  Created by Victor Springer on 19/06/17.
//  Copyright © 2017 Victor Springer. All rights reserved.
//

import UIKit

public struct TouristAttractionRank {
    let name: String
    let location: String
    let total: String
    
    init?(values: [String]) {
        self.name = values[0]
        self.location = values[1]
        self.total = values[2]
    }
}

