//
//  BarDetail.swift
//  TabSaver
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

    override func viewDidLoad() {
        super.viewDidLoad()

        var arr = getBarArray()

        for(var i = 0; i < arr.count; i++){
            
            var barName = arr[i]["name"] as NSString
            
            if barName == detailName {
                var sun = arr[i]["Sunday"] as NSString
                sundayDeals = sun.componentsSeparatedByString(",")
                var mon = arr[i]["Monday"] as NSString
                mondayDeals = mon.componentsSeparatedByString(",")
                var tue = arr[i]["Tuesday"] as NSString
                tuesdayDeals = tue.componentsSeparatedByString(",")
                var wed = arr[i]["Wednesday"] as NSString
                wednesdayDeals = wed.componentsSeparatedByString(",")
                var thur = arr[i]["Thursday"] as NSString
                thursdayDeals = thur.componentsSeparatedByString(",")
                var fri = arr[i]["Friday"] as NSString
                fridayDeals = fri.componentsSeparatedByString(",")
                var sat = arr[i]["Saturday"] as NSString
                saturdayDeals = sat.componentsSeparatedByString(",")
                address = arr[i]["address"] as NSString
                number = arr[i]["number"] as NSString
                website = arr[i]["website"] as NSString
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
        
        var alertController = UIAlertController()
        
        if(self.number == "No Number"){
            alertController = UIAlertController(title: "We're sorry!", message: "This bar doesn't have a phone.", preferredStyle: .Alert)
            
            var cancelAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel) {
                UIAlertAction in
                
            }
            alertController.addAction(cancelAction)
        }
            
        else{
            alertController = UIAlertController(title: "Are you sure you want to call \(self.number)?", message: "", preferredStyle: .Alert)
            
            var okAction = UIAlertAction(title: "Call", style: UIAlertActionStyle.Default) {
                UIAlertAction in
                var url:NSURL = NSURL(string: "tel://\(self.number)")!
                UIApplication.sharedApplication().openURL(url)
            }
            
            var cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) {
                UIAlertAction in
                
            }
            
            alertController.addAction(okAction)
            alertController.addAction(cancelAction)
        }

        self.presentViewController(alertController, animated: true, completion: nil)
    }

    @IBAction func createFavorite(sender: AnyObject) {
        var alertController = UIAlertController(title: "We're sorry!", message: "Favorite bars will be coming in the next update.", preferredStyle: .Alert)
        var cancelAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel) {
            UIAlertAction in
        }
        alertController.addAction(cancelAction)
        self.presentViewController(alertController, animated: true, completion: nil)
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
