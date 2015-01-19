//
//  DailyDeals.swift
//  Mug Night
//
//  Created by Lee Robinson on 12/7/14.
//  Copyright (c) 2014 Lee Robinson. All rights reserved.
//

import UIKit
import CoreLocation

class DailyDeals: UITableViewController {

    var locMan = CLLocationManager()
    var detailName = ""
    var detailTown = ""
    var detailDict = [:]
    
    // Bar Arrays
    var amesBars = [] as NSMutableArray
    var cedarFallsBars = [] as NSMutableArray
    var iowaCityBars = [] as NSMutableArray
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Read JSON data
        amesBars = createBarArray("amesBars", dict: detailDict)
        cedarFallsBars = createBarArray("cedarFallsBars", dict: detailDict)
        iowaCityBars = createBarArray("iowaCityBars", dict: detailDict)

        // Calculate distance from user location
        setDistances(amesBars)
        setDistances(cedarFallsBars)
        setDistances(iowaCityBars)
        
        // Sort the bars
        sortBars(amesBars)
        sortBars(cedarFallsBars)
        sortBars(iowaCityBars)
        
    }
    
    func createBarArray(name: String, dict: NSDictionary) -> NSMutableArray{
        
        var barArray = dict[name] as NSArray
        var bars = [] as NSMutableArray
        
        // Get day of the week
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "EEEE"
        let dayOfWeekString = dateFormatter.stringFromDate(NSDate())
        
        for bar in barArray{
            var name = bar["name"] as NSString
            var dealsArr = bar[dayOfWeekString] as NSArray
            var deal = ""
            for (var i = 0; i < dealsArr.count; i++){
                deal += "\n"
                deal += dealsArr[i] as NSString
            }

            var lat = bar["lat"] as Double
            var long = bar["long"] as Double
            var negLong = -long
            
            var newBar = BarAnnotation(latitude: lat, longitude: negLong, name: name, deal: deal)
            
            bars.addObject(newBar)
        }
        
        return bars
    }
    
    func setDistances(barArray: NSMutableArray){
        for bar in barArray {
            
            let currentBar = bar as BarAnnotation
            if(locMan.location == nil){
                currentBar.distance = 0
            }
            else{
                currentBar.distance = locMan.location.distanceFromLocation(currentBar.loc) / 1609.344
            }
        }
    }
    
    func sortBars(unsortedBars: NSMutableArray){
        unsortedBars.sortUsingComparator {
            var one = $0 as BarAnnotation
            var two = $1 as BarAnnotation
            var first = one.distance as Double
            var second = two.distance as Double
            
            if ( first < second ) {
                return NSComparisonResult.OrderedAscending
            } else if ( first > second ) {
                return NSComparisonResult.OrderedDescending
            } else {
                return NSComparisonResult.OrderedSame
            }
        }
    }

    func orderOfTowns() -> NSArray{
        var ames = amesBars[0] as BarAnnotation
        ames.town = "Ames"
        var cf = cedarFallsBars[0] as BarAnnotation
        cf.town = "Cedar Falls"
        var ic = iowaCityBars[0] as BarAnnotation
        ic.town = "Iowa City"
        
        var bars = [ames, cf, ic] as NSMutableArray
        sortBars(bars)
        
        var townNames = ["", "", ""]

        for index in 0...2 {
            townNames[index] = bars[index].town
        }
        
        return townNames
    }
    
    func returnArray(town: NSString) -> NSMutableArray{
        if (town == "Ames"){
            return amesBars
        }
        else if (town == "Cedar Falls"){
            return cedarFallsBars
        }
        else {
            return iowaCityBars
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.tableView.reloadData()
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> DealCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Deal Cell", forIndexPath: indexPath) as DealCell
        
        var currentBar = BarAnnotation(latitude: 0, longitude: 0, name: "", deal: "")
        
        var townArr = orderOfTowns()
        
        var town = townArr[indexPath.section] as NSString
        var arr = returnArray(town)
        currentBar = arr[indexPath.row] as BarAnnotation

        cell.barName.text = currentBar.name
        cell.deal.text = currentBar.deal
        cell.distanceToBar.text = String(format: "%.3f mi", currentBar.distance)
        
        // Set the height of the table view cells
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        self.tableView.estimatedRowHeight = 44.0;

        return cell
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var townArr = orderOfTowns()
        var town = townArr[section] as NSString
        var arr = returnArray(town)
        return arr.count
    }

    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        var sectionHeaderView = UIView(frame: CGRectMake(0, 0, tableView.frame.size.width, 25.0))
        sectionHeaderView.backgroundColor = UIColor.grayColor()
        
        var headerLabel = UILabel(frame: CGRectMake(16, 0, sectionHeaderView.frame.size.width, 25.0))
        headerLabel.backgroundColor = UIColor.clearColor()
        headerLabel.textColor = UIColor.blackColor()
        
        var townArr = orderOfTowns()
        headerLabel.text = townArr[section] as NSString
        
        headerLabel.textAlignment = NSTextAlignment.Left
        headerLabel.font = UIFont.boldSystemFontOfSize(17.0)
        sectionHeaderView.addSubview(headerLabel)
        return sectionHeaderView
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var cell = tableView.cellForRowAtIndexPath(indexPath) as DealCell
        var name = cell.barName.text!
        detailName = name

        var arr = orderOfTowns()
        detailTown = arr[indexPath.section] as NSString
        performSegueWithIdentifier("DetailFromList", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "DetailFromList" {
            var BD = segue.destinationViewController as BarDetail
            BD.detailName = detailName
            BD.detailTown = detailTown
            BD.detailDict = detailDict
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
