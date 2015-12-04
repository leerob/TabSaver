//
//  Location.swift
//  MapTest
//
//  Created by Lee Robinson on 12/3/15.
//  Copyright © 2015 Lee Robinson. All rights reserved.
//

import Foundation

class Location {
    
    var city, state, taxiService, taxiNumber: String
    var lat, long: Double
    
    init(city: String, state: String, taxiService: String, taxiNumber: String, lat: Double, long: Double) {
        
        self.city = city
        self.state = state
        self.taxiService = taxiService
        self.taxiNumber = taxiNumber
        self.lat = lat
        self.long = long
    }
}