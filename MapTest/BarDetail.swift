//
//  BarDetail.swift
//  Mug Night
//
//  Created by Lee Robinson on 12/7/14.
//  Copyright (c) 2014 Lee Robinson. All rights reserved.
//

import UIKit

class BarDetail: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var barName: UILabel!
    @IBOutlet weak var barAddress: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segControl: UISegmentedControl!

    var name = ""
    var address = ""
    var number = ""
    var website = ""
    var sundayDeals = []
    var mondayDeals = []
    var tuesdayDeals = []
    var wednesdayDeals = []
    var thursdayDeals = []
    var fridayDeals = []
    var saturdayDeals = []
    
    var detailName = ""
    var detailTown = ""
    var detailDict = [:]
    var deals = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        var arrayName = getArrayName()
        var barArray = detailDict[arrayName] as NSArray

        for bar in barArray{
            var barName = bar["name"] as NSString
            if barName == detailName {
                sundayDeals = bar["Sunday"] as NSArray
                mondayDeals = bar["Monday"] as NSArray
                tuesdayDeals = bar["Tuesday"] as NSArray
                wednesdayDeals = bar["Wednesday"] as NSArray
                thursdayDeals = bar["Thursday"] as NSArray
                fridayDeals = bar["Friday"] as NSArray
                saturdayDeals = bar["Saturday"] as NSArray
                address = bar["address"] as NSString
                number = bar["number"] as NSString
                website = bar["website"] as NSString
                name = barName
            }
        }
        
        // Get day of the week
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "EEEE"
        let dayOfWeekString = dateFormatter.stringFromDate(NSDate())
        setSeg(dayOfWeekString)
        
        barName.text = name
        barAddress.text = address
        
        tableView.backgroundColor = UIColor.darkGrayColor()
    }
    
    func getArrayName() -> NSString {
        switch(detailTown){
            case "Ames":
                return "amesBars"
            case "Cedar Falls":
                return "cedarFallsBars"
            case "Iowa City":
                return "iowaCityBars"
            default:
                return "amesBars"
        }
    }
    
    func setSeg(dayOfWeek: String) {
        
        switch dayOfWeek
        {
            case "Sunday":
                segControl.selectedSegmentIndex = 0
                deals = sundayDeals
            case "Monday":
                segControl.selectedSegmentIndex = 1
                deals = mondayDeals
            case "Tuesday":
                segControl.selectedSegmentIndex = 2
                deals = tuesdayDeals
            case "Wednesday":
                segControl.selectedSegmentIndex = 3
                deals = wednesdayDeals
            case "Thursday":
                segControl.selectedSegmentIndex = 4
                deals = thursdayDeals
            case "Friday":
                segControl.selectedSegmentIndex = 5
                deals = fridayDeals
            case "Saturday":
                segControl.selectedSegmentIndex = 6
                deals = saturdayDeals
            default:
                break;
        }
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
        cell.textLabel?.text = deals[indexPath.row] as? String
        return cell
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return deals.count
    }

    @IBAction func indexChanged(sender: UISegmentedControl) {
        
        switch segControl.selectedSegmentIndex
        {
            case 0:
                deals = sundayDeals
            case 1:
                deals = mondayDeals
            case 2:
                deals = tuesdayDeals
            case 3:
                deals = wednesdayDeals
            case 4:
                deals = thursdayDeals
            case 5:
                deals = fridayDeals
            case 6:
                deals = saturdayDeals
            default:
                break;
        }
        tableView.reloadData()
    }

    @IBAction func goToWebsite(sender: AnyObject) {
        var url:NSURL = NSURL(string: self.website)!
        UIApplication.sharedApplication().openURL(url)
    }
    
    @IBAction func callBar(sender: AnyObject) {

        // Create the alert controller
        var alertController = UIAlertController(title: "Are you sure you want to call \(self.number)?", message: "", preferredStyle: .Alert)
        
        // Create the actions
        var okAction = UIAlertAction(title: "Call", style: UIAlertActionStyle.Default) {
            UIAlertAction in
            var url:NSURL = NSURL(string: "tel://\(self.number)")!
            UIApplication.sharedApplication().openURL(url)
        }

        var cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) {
            UIAlertAction in
 
        }
        
        // Add the actions
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        alertController.view.tintColor = UIColor.blackColor()
        
        // Present the controller
        self.presentViewController(alertController, animated: true, completion: nil)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
