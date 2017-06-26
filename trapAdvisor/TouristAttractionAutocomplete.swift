//
//  TouristAttractionAutocomplete.swift
//  trapAdvisor
//
//  Created by Victor Springer on 25/06/17.
//  Copyright © 2017 Victor Springer. All rights reserved.
//

import UIKit

public struct TouristAttractionAutocomplete {
    let name: String
    let location: String
    
    init?(values: [String]) {
        self.name = values[0]
        self.location = values[1]
    }
}
