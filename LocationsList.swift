//
//  LocationsList.swift
//  MapTest
//
//  Created by Lee Robinson on 12/3/15.
//  Copyright © 2015 Lee Robinson. All rights reserved.
//

import UIKit

protocol LocationDelegate {
    func updateLocation(location: String, lat: Double, long: Double)
}

class LocationsList: UITableViewController {
    
    var initialLocation = ""
    var locations = NSMutableArray()
    var sortedLocations = NSArray()
    var analytics = Analytics()
    var delegate: LocationDelegate? = nil
    var settingsPage = UITableViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sortedLocations = locations.sort{ ($0 as! Location).city < ($1 as! Location).city }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sortedLocations.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("LocationCell", forIndexPath: indexPath) as! LocationCell
        let location = sortedLocations.objectAtIndex(indexPath.row) as! Location
        cell.cityName.text = "\(location.city), \(location.state)"
        
        if location.city == initialLocation {
            cell.setChecked(true)
        } else {
            cell.setChecked(false)
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Locations"
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        let location = sortedLocations[indexPath.row] as! Location
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! LocationCell
        
        uncheck()
        cell.setChecked(true)
        analytics.clicked(location.city)
        self.delegate?.updateLocation(location.city, lat: location.lat, long: location.long)
        
        // Update installation object with new location
        let installObj = PFInstallation.currentInstallation()
        installObj.setValue(location.city, forKey: "location")
        installObj.saveInBackground()
        
        // Also update the settings page variable
        let set = settingsPage as! Settings
        set.initialLocation = location.city

        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func uncheck() {
        for cell in tableView.visibleCells as! [LocationCell] {
            cell.setChecked(false)
        }
    }
}