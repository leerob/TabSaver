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
    var name, imageName, deal: String
    var location: CLLocationCoordinate2D
    var loc: CLLocation
    var annotation: MKPointAnnotation
    var town: String
    var cellHeight: CGFloat
    
    init(latitude: Double, longitude: Double, name: String, deal: String) {
        self.latitude = latitude
        self.longitude = longitude
        self.name = name
        self.imageName = "location-25.png"
        self.deal = deal
        self.distance = 0
        self.town = ""
        self.location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        self.loc = CLLocation(latitude: latitude, longitude: longitude)
        self.annotation = MKPointAnnotation()
        self.cellHeight = 0.0
        annotation.setCoordinate(self.location)
        annotation.title = name
        annotation.subtitle = deal

    }
}
