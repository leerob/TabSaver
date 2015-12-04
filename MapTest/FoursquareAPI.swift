//
//  FoursquareAPI.swift
//  MapTest
//
//  Created by Lee Robinson on 11/27/15.
//  Copyright © 2015 Lee Robinson. All rights reserved.
//

import Foundation

class FoursquareAPI: NSObject {
    
    let clientId = "LKKYNIHDYTYPLXR33D54IFIO2SU2UHMLJHREIV0CT4MW3RQU"
    let clientSecret = "KL3LKEHNIN2IGQN3BM3FS1VJNKMPOEJQMLHYBFOF5O1OJSWB"
    let version = "20140613"
    
    let radiusInMeters = 10000
    let categoryId = "4d4b7105d754a06376d81259"
    
    let data = NSMutableData()

    
    func searchForBarsAtLocation(userLocation: CLLocation) {
        
        let bars = [] as NSMutableArray
        let urlPath = "https://api.foursquare.com/v2/venues/explore?ll=\(userLocation.coordinate.latitude),\(userLocation.coordinate.longitude)&categoryId=\(categoryId)&radius=\(radiusInMeters)&client_id=\(clientId)&client_secret=\(clientSecret)&v=\(version)"
        
        let url = NSURL(string: urlPath)
        let request = NSURLRequest(URL: url!)
        
        let session: NSURLSession = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
        
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableLeaves) as! NSDictionary
                
                if json.count > 0 {
                    let response = json["response"] as! NSDictionary
                    let groups = response["groups"] as! NSArray
                    let items = groups[0]["items"] as! NSArray

                    for item in items {
                        
                        let venue = item["venue"] as! NSDictionary
                        let location = venue["location"] as! NSDictionary
                        let contact = venue["contact"] as! NSDictionary
                        
                        //let phone = contact["phone"] as! String
                        //let website = venue["url"] as! String)
                        //let address = location["address"] as! String

                        bars.addObject(SuggestedBar(latitude: location["lat"] as! Double,
                                                    longitude: location["lng"] as! Double,
                                                    name: venue["name"] as! String,
                                                    rating: venue["rating"] as! NSNumber,
                                                    phone: "",
                                                    address: "",
                                                    website: ""))
                    }
                }
                
                //print(bars)
                
                //self.delegate?.didRecieveVenues(venues)
                
            } catch {
                // Handle error here
            }
        })
        
        task.resume()
    }
    
    func getBarsRating(venueID: String) {

        let urlPath = "https://api.foursquare.com/v2/venues/\(venueID)&client_id=\(clientId)&client_secret=\(clientSecret)&v=\(version)"
        
        let url = NSURL(string: urlPath)
        let request = NSURLRequest(URL: url!)
        
        let session: NSURLSession = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableLeaves) as! NSDictionary
                print(json)
                if json.count > 0 {
                    let response = json["response"] as! NSDictionary
                    print(response)
//                    let groups = response["groups"] as! NSArray
//                    let items = groups[0]["items"] as! NSArray
//                    
//                    for item in items {
//                        
//                        let venue = item["venue"] as! NSDictionary
//                        let location = venue["location"] as! NSDictionary
//                        let contact = venue["contact"] as! NSDictionary
//                        
//                    }
                }
                
                //self.delegate?.didRecieveVenues(venues)
                
            } catch {
                // Handle error here
            }
        })
        
        task.resume()
    }
}

