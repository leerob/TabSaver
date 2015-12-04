//
//  ParseHelper.swift
//  MapTest
//
//  Created by Lee Robinson on 12/3/15.
//  Copyright © 2015 Lee Robinson. All rights reserved.
//

import Foundation

class ParseHelper {
    
    let analytics = Analytics()
    
    func getLocations() -> NSMutableArray {
        
        let locations = NSMutableArray()
        let query = PFQuery(className:"Locations")
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]?, error: NSError?) -> Void in
            
            if error == nil {
                if let objects = objects as? [PFObject] {
                    for object in objects {
                        locations.addObject(Location(city: object["cityName"] as! String,
                                                     state: object["state"] as! String,
                                                     taxiService: object["taxiService"] as! String,
                                                     taxiNumber: object["taxiNumber"] as! String,
                                                     lat: object["lat"] as! Double,
                                                     long: object["long"] as! Double))
                    }
                }
            } else {
                self.analytics.log("Error: Retrieving Locations", secondary: error!.localizedDescription)
            }
        }
        
        return locations
    }
}