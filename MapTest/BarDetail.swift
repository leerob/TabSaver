//
//  BarDetail.swift
//  TabSaver
//
//  Created by Lee Robinson on 12/7/14.
//  Copyright (c) 2014 Lee Robinson. All rights reserved.
//

import UIKit
import CoreData
import Parse
import MapKit
import MessageUI


class BarDetail: UITableViewController, UIAlertViewDelegate, MKMapViewDelegate, UIScrollViewDelegate, MFMailComposeViewControllerDelegate {

    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var barName: UILabel!
    @IBOutlet weak var barAddress: UILabel!
    @IBOutlet weak var distanceToBar: UILabel!
    @IBOutlet weak var dailyDeals: UILabel!
    @IBOutlet weak var number: UILabel!
    @IBOutlet weak var website: UILabel!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var hoursOpen: UILabel!
    @IBOutlet weak var mapView: MKMapView!
 
    // Static labels
    @IBOutlet weak var dailyDealsLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var websiteLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var yelpLabel: UILabel!
    @IBOutlet weak var foursquareLabel: UILabel!
    @IBOutlet weak var problemLabel: UILabel!
    
    var name = ""
    var rawNumber: NSString = ""
    var sun = ""
    var mon = ""
    var tue = ""
    var wed = ""
    var thu = ""
    var fri = ""
    var sat = ""
    
    var detailTown = ""
    var detailName = ""
    var distance = ""
    var foursquareID = ""
    var barsArr = [] as NSArray
    var deals = []
    var selected = false
    
    var primary = UIColor()
    var secondary = UIColor()
    var colors = Colors()
    var coreDataHelper = CoreDataHelper()
    var analytics = Analytics()
    var theme = 0
    var ImagesDict = Dictionary<String, NSData>()
    var HoursDict = Dictionary<String, String>()
    var DealsDict = Dictionary<String, [String]>()
    var previousY = -100.0 as CGFloat
    
    let tableHeaderHeight: CGFloat = 100.0
    var headerView: UIView!
    var gradient: CAGradientLayer = CAGradientLayer()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Loop through bars
        for bar in barsArr {
            
            let barName = bar["name"] as! String
            if barName == detailName {
                
                // Retrieve selected bars information
                let dealsArr = DealsDict[barName]!
   
                sun = dealsArr[0]
                mon = dealsArr[1]
                tue = dealsArr[2]
                wed = dealsArr[3]
                thu = dealsArr[4]
                fri = dealsArr[5]
                sat = dealsArr[6]
                address.text = bar["address"] as? String
                address.text = address.text! + "\n" + detailTown + ", IA"
                website.text = bar["website"] as? String
                foursquareID = bar["foursquare"] as! String
                name = barName
                rawNumber = bar["number"] as! NSString
                
                if rawNumber == "No Number" {
                    number.text = rawNumber as? String
                }
                else{
                    number.text = formatPhoneNumber(rawNumber) as? String
                }
                
                let span = MKCoordinateSpanMake(0.005, 0.005)
                let lat = bar["lat"] as! NSNumber
                let long = bar["long"] as! NSNumber
                let loc = CLLocationCoordinate2D(latitude: lat.doubleValue, longitude: long.doubleValue)
                let region = MKCoordinateRegion(center: loc, span: span)
                mapView.setRegion(region, animated: false)
                mapView.addAnnotation(BarAnnotation(latitude: lat.doubleValue, longitude: long.doubleValue, name: name, deal: "").annotation)
            }
        }
        
        // Set image from dictionary
        if (ImagesDict[name] != nil) {
          image.image = UIImage(data: ImagesDict[name]!)
        }
        
        // Set hours from dictionary
        hoursOpen.text = HoursDict[name]
        
        // Get day of the week + 2 hours
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "EEEE"
        let currDate = NSDate()
        let twoHours = 2 * 60 * 60 as NSTimeInterval
        let newDate = currDate.dateByAddingTimeInterval(-twoHours)
        let dayOfWeekString = dateFormatter.stringFromDate(newDate)
        
        dailyDeals.text = getDailyDealStr(dayOfWeekString)
        barName.text = name
        distanceToBar.text = distance + " miles"
        
        // Add button
        var bigimg = UIImage(named: "star-50.png")
        var img = scaleImage(bigimg!, newSize: CGSize(width: 25.0, height: 25.0))
        var button = UIBarButtonItem(image: img, style: UIBarButtonItemStyle.Plain, target: self, action: "createFavorite")
        self.navigationItem.rightBarButtonItem = button

        
        // Change colors based on theme
        if theme == 2 {
            primary = colors.darkGray
        }
        
        changeTheme()

        if(coreDataHelper.isFavorite("Favorites", key: "list", barName: name)){
            toggleFavorite(true, save: false)
            selected = true
        }
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: self, action: nil)
        navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "San Francisco Display", size: 16)!]
    
        // Create a black->transparent gradient over image
        gradient.frame = CGRectMake(0.0, 0.0, view.frame.width, view.frame.height)
        gradient.colors = [colors.transparentBlack.CGColor, colors.black.CGColor]
        gradient.locations = [0.0, 1.0]
        gradient.startPoint = CGPoint(x: 1.0, y: 0.0)
        gradient.endPoint = CGPoint(x: 0.0, y: 0.0)
        image!.layer.insertSublayer(gradient, atIndex:0)
        
        // Create a white->transparent gradient over map
        var mapGradient: CAGradientLayer = CAGradientLayer()
        mapGradient.frame = CGRectMake(0.0, 0.0, mapView.frame.width, mapView.frame.height+10)
        mapGradient.colors = [colors.transparentWhite.CGColor, colors.white.CGColor]
        mapGradient.locations = [0.0, 1.0]
        mapGradient.startPoint = CGPoint(x: 1.0, y: 0.0)
        mapGradient.endPoint = CGPoint(x: 0.5, y: 0.0)
        mapView.layer.insertSublayer(mapGradient, above: mapView.layer)

        // Set a tap recognizer for clicking the map
        var tapRecognizer = UITapGestureRecognizer()
        tapRecognizer = UITapGestureRecognizer(target: self, action: "goToMaps")
        tapRecognizer.numberOfTapsRequired = 1
        mapView.addGestureRecognizer(tapRecognizer)
        
        // Create the table image header
        headerView = tableView.tableHeaderView
        tableView.tableHeaderView = nil
        tableView.addSubview(headerView)
        tableView.contentInset = UIEdgeInsets(top: tableHeaderHeight, left: 0, bottom: 0, right: 0)
        tableView.contentOffset = CGPoint(x: 0, y: -tableHeaderHeight)
        tableView.tableFooterView = UIView(frame:CGRectZero)
    }
    
    func getDailyDealStr(dayOfWeek: String) -> String {
        
        switch dayOfWeek
        {
            case "Sunday":
                return sun
            case "Monday":
                return mon
            case "Tuesday":
                return tue
            case "Wednesday":
                return wed
            case "Thursday":
                return thu
            case "Friday":
                return fri
            case "Saturday":
                return sat
            default:
                return ""
        }
    }
    
    func updateHeaderView() {
        var gradientRect = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: tableHeaderHeight)
        var headerRect = CGRect(x: 0, y: -tableHeaderHeight, width: tableView.bounds.width, height: tableHeaderHeight)
        
        let currentY = tableView.contentOffset.y
        if currentY < previousY && currentY < -100 {
            decreaseOpacity(barName)
            decreaseOpacity(distanceToBar)
            decreaseOpacity(hoursOpen)
        }
        else {
            increaseOpacity(barName)
            increaseOpacity(distanceToBar)
            increaseOpacity(hoursOpen)
        }
        previousY = currentY
        
        if tableView.contentOffset.y < -tableHeaderHeight {
            headerRect.origin.y = tableView.contentOffset.y
            headerRect.size.height = -tableView.contentOffset.y
            gradientRect.origin.x = tableView.contentOffset.y
            gradientRect.size.height = -tableView.contentOffset.y+150
        }
       
        gradient.frame = gradientRect
        headerView.frame = headerRect
    }
    
    func decreaseOpacity(label: UILabel!) {
        label.alpha -= 0.04
        if label.alpha < 0.0 {
            label.alpha = 0
        }
    }
    
    func increaseOpacity(label: UILabel!) {
        label.alpha += 0.04
        if label.alpha > 1.0 {
            label.alpha = 1.0
        }
    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        updateHeaderView()
    }

    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {

        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier("pin")
        
        if pinView == nil {
            pinView = MKAnnotationView(annotation: annotation, reuseIdentifier: "pin")
            pinView!.canShowCallout = false
            
        }
        else {
            pinView!.annotation = annotation
        }

        pinView!.image = scaleImage(UIImage(named: "transparent.png")!, newSize: CGSizeMake(35, 35))
        pinView!.centerOffset = CGPointMake(tableView.frame.width/2 - 35, 0)
 
        return pinView
    }

    func changeTheme() {
        dailyDealsLabel.textColor = primary
        phoneLabel.textColor = primary
        websiteLabel.textColor = primary
        locationLabel.textColor = primary
        yelpLabel.textColor = primary
        foursquareLabel.textColor = primary
        problemLabel.textColor = primary
    }
   
    func formatPhoneNumber(number: NSString) -> NSString {
    
        var newStr = NSMutableString(string: number)
        newStr.insertString("(", atIndex: 0)
        newStr.insertString(")", atIndex: 4)
        newStr.insertString(" ", atIndex: 5)
        newStr.insertString("-", atIndex: 9)
        return newStr
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        switch indexPath.row {
            case 1:
                if rawNumber != "No Number" {
                    let url:NSURL = NSURL(string: "tel://\(rawNumber)")!
                    UIApplication.sharedApplication().openURL(url)
                }
                analytics.barClicked(name, key: "phoneCalls")
                break;
            case 2:
                performSegueWithIdentifier("goToWebsite", sender: self)
                analytics.barClicked(name, key: "siteVisits")
                break;
            case 4:
                let yelpStr = "search?terms=" + name.replace(" ", withString: "+") + "&location=" + detailTown.replace(" ", withString: "+") + ",IA"
                if isYelpInstalled() {
                    // Call into the Yelp app
                    UIApplication.sharedApplication().openURL(NSURL(string: "yelp5.3:///" + yelpStr)!)
                }
                else {
                    // Use the website
                    let urlStr = name.replace(" ", withString: "+") + "&find_loc=" + detailTown.replace(" ", withString: "+") + ",IA"
                    UIApplication.sharedApplication().openURL(NSURL(string: "http://www.yelp.com/search?find_desc=" + urlStr)!)
                }
                analytics.barClicked(name, key: "yelpClicks")
                break;
            case 5:
                if foursquareID == "None" {
                    let alert = UIAlertView()
                    alert.title = "We're Sorry!"
                    alert.message = "This bar does not have a Foursquare page."
                    alert.delegate = self
                    alert.addButtonWithTitle("OK")
                    alert.show()
                }
                else {
                    if isFoursquareInstalled() {
                        // Call into the Foursquare app
                        UIApplication.sharedApplication().openURL(NSURL(string: "foursquare://venues/" + foursquareID)!)
                    }
                    else {
                        // Use the website
                        UIApplication.sharedApplication().openURL(NSURL(string: "https://foursquare.com/v/" + foursquareID)!)
                    }
                }
                analytics.barClicked(name, key: "foursquareClicks")
                break;
            case 6:
                // Report a problem
                let mailComposeViewController = configuredMailComposeViewController()
                if MFMailComposeViewController.canSendMail() {
                    self.presentViewController(mailComposeViewController, animated: true, completion: nil)
                } else {
                    self.showSendMailErrorAlert()
                }
            default:
                break;
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
    }
    
    func isYelpInstalled() -> Bool {
        return UIApplication.sharedApplication().canOpenURL(NSURL(string: "yelp5.3:")!)
    }
    
    func isFoursquareInstalled() -> Bool {
        return UIApplication.sharedApplication().canOpenURL(NSURL(string: "foursquare:")!)
    }

    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        switch buttonIndex {
            case 0:
                if(alertView.buttonTitleAtIndex(0) == "Cancel" || alertView.buttonTitleAtIndex(0) == "OK") {
                    break;
                }
                break;
            default:
                break;
        }
    }
    
    func goToMaps() {
        let formattedAddress = address.text!.replace(" ", withString: "+").replace("\n", withString: ",+")
        let loc = "http://maps.apple.com/?q=" + formattedAddress
        let url:NSURL = NSURL(string: loc)!
        UIApplication.sharedApplication().openURL(url)
        analytics.barClicked(name, key: "directionsRequests")
    }

    func createFavorite() {

        if selected {
            toggleFavorite(false, save: false)
        }
        else{
            toggleFavorite(true, save: true)
        }
    }
    
    func toggleFavorite(isFavorite: Bool, save: Bool) {
        
        if isFavorite {
            let selectedStar = UIImage(named: "star.png")
            let newImg = scaleImage(selectedStar!, newSize: CGSize(width: 25.0, height: 25.0))
            self.navigationItem.rightBarButtonItem?.image = newImg
            selected = true
        }
        else{
            let star = UIImage(named: "star-50.png")
            let newImg = scaleImage(star!, newSize: CGSize(width: 25.0, height: 25.0))
            self.navigationItem.rightBarButtonItem?.image = newImg
            coreDataHelper.deleteFavorite("Favorites", key: "list", barName: name)
            managePushChannels(false)
            selected = false
        }
        if save {
            coreDataHelper.saveString("Favorites", value: name, key: "list")
            managePushChannels(true)

            // Alert about being subscribed to push notifications
            let alert = UIAlertView()
            alert.title = "Push Notifcations"
            alert.message = "You will now recieve notifications from this bar when they update their deals.\n\nTo unsubscribe, unfavorite this bar."
            alert.delegate = self
            alert.addButtonWithTitle("OK")
            alert.show()
        }
    }
    
    func managePushChannels(add: Bool) {
    
        let currentInstallation = PFInstallation.currentInstallation()
        if add {
            currentInstallation.addUniqueObject(formatBarName(name), forKey: "channels")
        }
        else {
            currentInstallation.removeObject(formatBarName(name), forKey: "channels")
        }
        currentInstallation.saveInBackgroundWithBlock({ (succeeded,e) -> Void in
            
            if let error = e {
                println("Error:  (error.localizedDescription)")
            }
        })
    }
    
    func formatBarName(name: String) -> String {
        return name.replace(" ", withString: "").replace("'", withString: "").replace("!", withString: "").replace("&", withString: "")
    }
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
            
        mailComposerVC.setToRecipients(["leerob@iastate.edu"])
        mailComposerVC.setSubject(name)
        mailComposerVC.setMessageBody("Hello,\n\nI've noticed a problem with " + name + " on TabSaver. The problem is...", isHTML: false)
   
        return mailComposerVC
    }
    
    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertView(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", delegate: self, cancelButtonTitle: "OK")
        sendMailErrorAlert.show()
    }
    
    func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
        controller.dismissViewControllerAnimated(true, completion: nil)
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
            WS.website = website.text!
        }
        
        if segue.identifier == "AllDeals" {
            var WD = segue.destinationViewController as! WeeklyDeals
            WD.mon = mon.replace(", ", withString: "\n")
            WD.tue = tue.replace(", ", withString: "\n")
            WD.wed = wed.replace(", ", withString: "\n")
            WD.thu = thu.replace(", ", withString: "\n")
            WD.fri = fri.replace(", ", withString: "\n")
            WD.sat = sat.replace(", ", withString: "\n")
            WD.sun = sun.replace(", ", withString: "\n")
            WD.primary = primary
            analytics.barClicked(name, key: "viewAllDeals")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension String
{
    func replace(target: String, withString: String) -> String
    {
        return self.stringByReplacingOccurrencesOfString(target, withString: withString, options: NSStringCompareOptions.LiteralSearch, range: nil)
    }
}
