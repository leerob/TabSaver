//
//  BarAnnotation.swift
//  TabSaver
//
//  Created by Lee Robinson on 12/7/14.
//  Copyright (c) 2014 Lee Robinson. All rights reserved.
//

import UIKit
import MapKit

class BarAnnotation: MKPointAnnotation {
    
    var latitude, longitude, distance: Double
    var name, deal: String
    var location: CLLocationCoordinate2D
    var loc: CLLocation
    var annotation: MKPointAnnotation
    var town: String
    var isFavorite: Bool
    
    
    init(latitude: Double, longitude: Double, name: String, deal: String) {
        self.latitude = latitude
        self.longitude = longitude
        self.name = name
        self.deal = deal
        self.distance = 0
        self.isFavorite = false
        self.town = ""
        self.location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        self.loc = CLLocation(latitude: latitude, longitude: longitude)
        self.annotation = MKPointAnnotation()
        annotation.coordinate = self.location
        annotation.title = name
        annotation.subtitle = deal
    }
}
