//
//  BarDetail.swift
//  TabSaver
//
//  Created by Lee Robinson on 12/7/14.
//  Copyright (c) 2014 Lee Robinson. All rights reserved.
//

import UIKit
import CoreData

class BarDetail: UIViewController, UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate {

    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var barName: UILabel!
    @IBOutlet weak var barAddress: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segControl: UISegmentedControl!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var button2: UIButton!
    @IBOutlet weak var button3: UIButton!
    @IBOutlet weak var button4: UIButton!
    
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
    var amesArr = [] as NSArray
    var icArr = [] as NSArray
    var cfArr = [] as NSArray
    var deals = []
    var selected = false
    
    var primary = UIColor()
    var secondary = UIColor()
    var colors = Colors()
    var coreDataHelper = CoreDataHelper()
    var theme = 0


    override func viewDidLoad() {
        super.viewDidLoad()

        var arr = getBarArray()

        for(var i = 0; i < arr.count; i++){
            
            var barName = arr[i]["name"] as! String
            
            if barName == detailName {
                var sun = arr[i]["Sunday"] as! NSString
                sundayDeals = sun.componentsSeparatedByString(",")
                var mon = arr[i]["Monday"] as! NSString
                mondayDeals = mon.componentsSeparatedByString(",")
                var tue = arr[i]["Tuesday"] as! NSString
                tuesdayDeals = tue.componentsSeparatedByString(",")
                var wed = arr[i]["Wednesday"] as! NSString
                wednesdayDeals = wed.componentsSeparatedByString(",")
                var thur = arr[i]["Thursday"] as! NSString
                thursdayDeals = thur.componentsSeparatedByString(",")
                var fri = arr[i]["Friday"] as! NSString
                fridayDeals = fri.componentsSeparatedByString(",")
                var sat = arr[i]["Saturday"] as! NSString
                saturdayDeals = sat.componentsSeparatedByString(",")
                address = arr[i]["address"] as! String
                number = arr[i]["number"] as! String
                website = arr[i]["website"] as! String
                name = barName
            }
        }
        
        // Get day of the week
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "EEEE"
        var currDate = NSDate()
        var twoHours = 2 * 60 * 60 as NSTimeInterval
        var newDate = currDate.dateByAddingTimeInterval(-twoHours)
        let dayOfWeekString = dateFormatter.stringFromDate(newDate)
        setSeg(dayOfWeekString)
        
        barName.text = name
        barAddress.text = address
        var blue = UIColor(red: 57.0/255.0, green: 105.0/255.0, blue: 247.0/255.0, alpha: 1.0)
        segControl.tintColor = blue
        
        var phone = UIImage(named: "phone1-50.png")
        var img = scaleImage(phone!, newSize: CGSize(width: 25.0, height: 25.0))
        button.setImage(img, forState: UIControlState.Normal)
        
        var globe = UIImage(named: "globe-50.png")
        var img2 = scaleImage(globe!, newSize: CGSize(width: 25.0, height: 25.0))
        button2.setImage(img2, forState: UIControlState.Normal)
        
        var star = UIImage(named: "star-50.png")
        var img3 = scaleImage(star!, newSize: CGSize(width: 25.0, height: 25.0))
        button3.setImage(img3, forState: UIControlState.Normal)
        
        var loc = UIImage(named: "location-50.png")
        var img4 = scaleImage(loc!, newSize: CGSize(width: 25.0, height: 25.0))
        button4.setImage(img4, forState: UIControlState.Normal)
        
        // Change colors based on theme
        switch(theme){
            case 0: // Default
                break;
            case 1: // Ames
                primary = colors.red
                secondary = colors.yellow3
                changeTheme()
                break;
            case 2: // Iowa City
                primary = colors.yellow2
                secondary = colors.black
                self.view.backgroundColor = secondary
                changeTheme()
                break;
            case 3: // Cedar Falls
                primary = colors.purple
                secondary = colors.yellow
                changeTheme()
                break;
            default:
                break;
        }

        if(coreDataHelper.isFavorite("Favorites", key: "list", barName: name)){
            toggleFavorite(true, save: false)
            selected = true
        }

    }
    
    func changeTheme(){
        
        segControl.tintColor = primary
        button.tintColor = primary
        button2.tintColor = primary
        button3.tintColor = primary
        button4.tintColor = primary
        barName.textColor = primary
        barAddress.textColor = primary
        
    }

    func getBarArray() -> NSArray {
        switch(detailTown){
            case "Ames":
                return amesArr
            case "Cedar Falls":
                return cfArr
            case "Iowa City":
                return icArr
            default:
                return amesArr
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
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UITableViewCell
        cell.textLabel?.text = deals[indexPath.row] as? String
        
        // Change colors based on theme
        switch(theme){
            case 0: // Default
                break;
            case 1: // Ames
                cell.textLabel?.textColor = primary
                break;
            case 2: // Iowa City
                cell.textLabel?.textColor = primary
                tableView.backgroundColor = secondary
                cell.backgroundColor = secondary
                break;
            case 3: // Cedar Falls
                cell.textLabel?.textColor = primary
                break;
            default:
                break;
        }
        
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

    @IBAction func callBar(sender: AnyObject) {
        
        var alertView = UIAlertView()
        
        if(self.number == "No Number"){
            alertView = UIAlertView(
                title: "We're sorry!",
                message: "This bar doesn't have a phone.",
                delegate: self,
                cancelButtonTitle: "Cancel")
        }
            
        else{
            alertView = UIAlertView(
                title: "Are you sure you want to call \(self.name)?",
                message: self.number,
                delegate: self,
                cancelButtonTitle: "Cancel",
                otherButtonTitles: "Call")
        }
        
        alertView.alertViewStyle = .Default
        alertView.show()

    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        switch buttonIndex {
            case 0:
                if(alertView.buttonTitleAtIndex(0) == "Cancel"){
                    break;
                }
                else{
                    var url:NSURL = NSURL(string: "tel://\(self.number)")!
                    UIApplication.sharedApplication().openURL(url)
                }
                break;
            case 1:
                break;
            default:
                break;
        }
    }

    @IBAction func createFavorite(sender: AnyObject) {

        if(selected){
            toggleFavorite(false, save: false)
        }
        else{
            toggleFavorite(true, save: true)
        }
    }
    
    func toggleFavorite(isFavorite: Bool, save: Bool){
        
        if(isFavorite){
            var selectedStar = UIImage(named: "star.png")
            var newImg = scaleImage(selectedStar!, newSize: CGSize(width: 25.0, height: 25.0))
            button3.setImage(newImg, forState: UIControlState.Normal)
        }
        else{
            var selectedStar = UIImage(named: "star-50.png")
            var newImg = scaleImage(selectedStar!, newSize: CGSize(width: 25.0, height: 25.0))
            button3.setImage(newImg, forState: UIControlState.Normal)
            coreDataHelper.deleteFavorite("Favorites", key: "list", barName: name)
        }
        if(save){
            coreDataHelper.saveString("Favorites", value: name, key: "list")
        }
        
    }
    
    
    @IBAction func goToMaps(sender: AnyObject) {
        var formattedAddress = self.address.stringByReplacingOccurrencesOfString(" ", withString: "+", options: NSStringCompareOptions.LiteralSearch, range: nil)
        var loc = "http://maps.apple.com/?q=" + self.address + ",+" + detailTown + ",+IA"
        var formattedLoc = loc.stringByReplacingOccurrencesOfString(" ", withString: "+", options: NSStringCompareOptions.LiteralSearch, range: nil)

        var url:NSURL = NSURL(string: formattedLoc)!
        UIApplication.sharedApplication().openURL(url)
    }
    
    func scaleImage(image: UIImage, newSize: CGSize) -> UIImage {
        
        var scaledSize = newSize
        var scaleFactor: CGFloat = 1.0
        
        if image.size.width > image.size.height {
            scaleFactor = image.size.width / image.size.height
            scaledSize.width = newSize.width
            scaledSize.height = newSize.width / scaleFactor
        } else {
            scaleFactor = image.size.height / image.size.width
            scaledSize.height = newSize.height
            scaledSize.width = newSize.width / scaleFactor
        }
        
        UIGraphicsBeginImageContextWithOptions(scaledSize, false, 0.0)
        let scaledImageRect = CGRectMake(0.0, 0.0, scaledSize.width, scaledSize.height)
        [image .drawInRect(scaledImageRect)]
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "goToWebsite" {
            var WS = segue.destinationViewController as! Website
            WS.website = self.website
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
