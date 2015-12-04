//
//  SuggestedBar.swift
//  MapTest
//
//  Created by Lee Robinson on 11/27/15.
//  Copyright © 2015 Lee Robinson. All rights reserved.
//

import UIKit
import MapKit

class SuggestedBar: MKPointAnnotation {
    
    var latitude, longitude, distance: Double
    var name, address, website, phone: String
    var rating: NSNumber
    var location: CLLocation
    var annotation: MKPointAnnotation
    var town: String
    
    
    init(latitude: Double, longitude: Double, name: String, rating: NSNumber, phone: String, address: String, website: String) {
        self.latitude = latitude
        self.longitude = longitude
        self.name = name
        self.address = address
        self.website = website
        self.rating = rating
        self.phone = phone
        self.distance = 0
        self.town = ""
        self.location = CLLocation(latitude: latitude, longitude: longitude)
        self.annotation = MKPointAnnotation()
        annotation.coordinate = self.location.coordinate
        annotation.title = name
        annotation.subtitle = rating.stringValue
    }
}