//
//  BarMap.swift
//  TabSaver
//
//  Created by Lee Robinson on 12/5/14.
//  Copyright (c) 2014 Lee Robinson. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Foundation
import Armchair

class BarMap: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UISearchBarDelegate, UIActionSheetDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var searchButton: UIBarButtonItem!
    @IBOutlet weak var listButton: UIBarButtonItem!
    @IBOutlet weak var segControl: UISegmentedControl!
    @IBOutlet weak var barButtonItem: UIBarButtonItem!
    @IBOutlet weak var toolBar: UIToolbar!
    
    let locationManager = CLLocationManager()
    var searchBar = UISearchBar()
   
    // Contains bar annotations
    var bars = [] as NSMutableArray
    var detailName = ""
    var amesArr = [] as NSArray
    var icArr = [] as NSArray
    var cfArr = [] as NSArray
    var detailTown = ""
    
    // Colors and Theme
    var primary = UIColor()
    var secondary = UIColor()
    var colors = Colors()
    var coreDataHelper = CoreDataHelper()
    var theme = 0;
    
    var tapRecognizer = UITapGestureRecognizer()

    override func viewDidLoad() {
        super.viewDidLoad()

        // i0S 8 Check
        switch UIDevice.currentDevice().systemVersion.compare("8.0.0", options: NSStringCompareOptions.NumericSearch) {
            case .OrderedSame, .OrderedDescending:
                locationManager.requestWhenInUseAuthorization()
                break;
            default:
                break;
        }

        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
        

        // Set the span and region for the map
        if(locationManager.location == nil){
            // Default to Ames location
            var span = MKCoordinateSpanMake(0.075, 0.075)
            var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 42.035021, longitude: -93.645), span: span)
            mapView.setRegion(region, animated: true)
        }
        else{
            setLocation()
        }
        
        // Get JSON data from URL
        amesArr = parseJSON(getJSON("http://tabsaver.info/connectAmes.php")) as NSArray
        cfArr = parseJSON(getJSON("http://tabsaver.info/connectCF.php")) as NSArray
        icArr = parseJSON(getJSON("http://tabsaver.info/connectIC.php")) as NSArray

        // Read JSON data
        var amesBars = createBarArray("amesBars", arr: amesArr)
        var cedarFallsBars = createBarArray("cedarFallsBars", arr: cfArr)
        var iowaCityBars = createBarArray("iowaCityBars", arr: icArr)
        
        // Add all the bars to one array
        bars.addObjectsFromArray(amesBars as [AnyObject])
        bars.addObjectsFromArray(cedarFallsBars as [AnyObject])
        bars.addObjectsFromArray(iowaCityBars as [AnyObject])
        
        // Add bars to map
        for bar in bars {
            mapView.addAnnotation(bar.annotation)
        }
        
        
        // Configure search bar
        searchBar.delegate = self
        searchBar.tintColor = UIColor.lightGrayColor()
        searchBar.placeholder = "Search Bars"
        self.navigationItem.titleView = searchBar

        
        // Add buttons
        var bigimg = UIImage(named: "generic_sorting2-50.png")
        var img = scaleImage(bigimg!, newSize: CGSize(width: 25.0, height: 25.0))
        var button = UIBarButtonItem(image: img, style: UIBarButtonItemStyle.Plain, target: self, action: "goToList")
        self.navigationItem.rightBarButtonItem = button
        
        var bigimg2 = UIImage(named: "settings-50.png")
        var img2 = scaleImage(bigimg2!, newSize: CGSize(width: 20.0, height: 20.0))
        var button2 = UIBarButtonItem(image: img2, style: UIBarButtonItemStyle.Plain, target: self, action: "goToSettings")
        self.navigationItem.leftBarButtonItem = button2
        
        navigationController?.navigationBar.hideBottomHairline()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: self, action: nil)
        var width = navigationController?.navigationBar.frame.width as CGFloat!
        
        switch(width){
            case 320.0:
                barButtonItem.width = width - 35.0
                break
            case 375.0:
                barButtonItem.width = width - 32.0
                break
            case 414.0:
                barButtonItem.width = width - 42.0
                break
            default:
                barButtonItem.width = width - 35.0
        }
        
        // Change colors based on theme
        theme = coreDataHelper.getInt("Theme", key: "themeNumber")

        switch(theme){
            case 0: // Default
                primary = colors.blue
                secondary = colors.white
                changeTheme()
                break;
            case 1: // Ames
                primary = colors.red
                secondary = colors.yellow3
                changeTheme()
                break;
            case 2: // Iowa City
                primary = colors.black
                secondary = colors.yellow2
                changeTheme()
                break;
            case 3: // Cedar Falls
                primary = colors.purple
                secondary = colors.yellow
                changeTheme()
                break;
            default:
                primary = colors.blue
                secondary = colors.white
                changeTheme()
                break;
        }
        
    }
    
    override func viewDidAppear(animated: Bool) {
        
        // Change colors based on theme
        theme = coreDataHelper.getInt("Theme", key: "themeNumber")
        
        switch(theme){
            case 0: // Default
                primary = colors.blue
                secondary = colors.white
                changeTheme()
                break;
            case 1: // Ames
                primary = colors.red
                secondary = colors.yellow3
                changeTheme()
                break;
            case 2: // Iowa City
                primary = colors.black
                secondary = colors.yellow2
                changeTheme()
                break;
            case 3: // Cedar Falls
                primary = colors.purple
                secondary = colors.yellow
                changeTheme()
                break;
            default:
                primary = colors.blue
                secondary = colors.white
                changeTheme()
                break;
        }
    }


    func changeTheme(){
        
        var navItem = navigationController?.navigationBar;
        navItem?.barTintColor = primary
        navItem?.tintColor = secondary
        navItem?.backgroundColor = secondary
        navItem?.titleTextAttributes = [NSForegroundColorAttributeName: secondary]
        toolBar.backgroundColor = primary
        segControl.backgroundColor = primary
        segControl.tintColor = secondary
        searchBar.backgroundImage = getImageWithColor(primary, size: CGSize(width: 100, height: 50))
        navItem?.barStyle = UIBarStyle.Black
        navItem?.translucent = false
        
    }
    
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        tapRecognizer = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
        tapRecognizer.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(tapRecognizer)
    }
    
    
    func handleSingleTap(recognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
        searchBar.resignFirstResponder()
        self.view.removeGestureRecognizer(tapRecognizer)
    }
    
    func getImageWithColor(color: UIColor, size: CGSize) -> UIImage {
        var rect = CGRectMake(0, 0, size.width, size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(rect)
        var image: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    func goToList(){
        performSegueWithIdentifier("List", sender: self)
    }
    
    func goToSettings(){
        performSegueWithIdentifier("Settings", sender: self)
    }
    
    @IBAction func goToCurrentLoc(sender: AnyObject) {
        
        if(self.locationManager.location == nil){
            let alert = UIAlertView()
            alert.title = "Location Disabled"
            alert.message = "Location must be enabled to view your current location."
            alert.addButtonWithTitle("OK")
            alert.show()
        }
        else{
            self.selectLocation(self.locationManager.location.coordinate.latitude, long: self.locationManager.location.coordinate.longitude)
        }
    }
    
    @IBAction func segClicked(sender: AnyObject) {
        
        switch segControl.selectedSegmentIndex
        {
            case 0:
                self.selectLocation(42.035021, long: -93.645)  
                break;
            case 1:
                self.selectLocation(41.656497, long: -91.535339)
                break;
            default:
                self.selectLocation(42.520700, long: -92.438965)
                break;
        }
    }
    
    func selectLocation(lat: Double, long: Double){
        var span = MKCoordinateSpanMake(0.075, 0.075)
        var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: lat, longitude: long), span: span)
        mapView.setRegion(region, animated: true)
    }
    
    func createBarArray(townName: String, arr: NSArray) -> NSMutableArray{
        
        var bars = [] as NSMutableArray
        
        // Get day of the week
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "EEEE"
        var currDate = NSDate()
        var twoHours = 2 * 60 * 60 as NSTimeInterval
        var newDate = currDate.dateByAddingTimeInterval(-twoHours)
        
        let dayOfWeekString = dateFormatter.stringFromDate(newDate)
        
        // Loop through bars
        for(var i = 0; i < arr.count; i++){
            
            var name = arr[i]["name"] as! String

            var dealsStr = arr[i][dayOfWeekString] as! String
            var dealsArr = dealsStr.componentsSeparatedByString(",")

            var deal = dealsArr[0] as String
            var lat = arr[i]["lat"] as! NSString
            var long = arr[i]["long"] as! NSString
            
            var negLong = -long.doubleValue
            
            var newBar = BarAnnotation(latitude: lat.doubleValue, longitude: negLong, name: name, deal: deal)
            
            switch(townName){
                case "amesBars":
                    newBar.town = "Ames"
                case "cedarFallsBars":
                    newBar.town = "Cedar Falls"
                case "iowaCityBars":
                    newBar.town = "Iowa City"
                default:
                    newBar.town = ""
            }
            
            
            // Support for settings
//            if(deal == "No Deals" || deal == "Closed"){
//                print(deal)
//            }
//            else{
                bars.addObject(newBar)
//            }
        }

        return bars
    }
    
    func setLocation(){
        
        var span = MKCoordinateSpanMake(0.075, 0.075)
        var amesLocation = CLLocation(latitude: 42.035021, longitude: -93.645)
        var cfLocation = CLLocation(latitude: 42.520700, longitude: -92.438965)
        var icLocation = CLLocation(latitude: 41.656497, longitude: -91.535339)

        if((locationManager.location.distanceFromLocation(amesLocation) / 1609.344) < 30){
            
            // Ames Location
            var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 42.035021, longitude: -93.645), span: span)
            mapView.setRegion(region, animated: true)
            segControl.selectedSegmentIndex = 0
        }
            
        else if((locationManager.location.distanceFromLocation(cfLocation) / 1609.344) < 30){
            
            // Cedar Falls Location
            var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 42.520700, longitude: -92.438965), span: span)
            mapView.setRegion(region, animated: true)
            segControl.selectedSegmentIndex = 2
        }
            
        else if((locationManager.location.distanceFromLocation(icLocation) / 1609.344) < 30){
            
            // Iowa City Location
            var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 41.656497, longitude: -91.535339), span: span)
            mapView.setRegion(region, animated: true)
            segControl.selectedSegmentIndex = 1
        }
            
        else{
            
            // Default to Ames location
            var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 42.035021, longitude: -93.645), span: span)
            mapView.setRegion(region, animated: true)
            segControl.selectedSegmentIndex = 0
        }
    }
    
    func getJSON(urlToRequest: String) -> NSData{
        return NSData(contentsOfURL: NSURL(string: urlToRequest)!)!
    }

    func parseJSON(inputData: NSData) -> Array<NSDictionary>{
        var error: NSError?
        var arr = NSJSONSerialization.JSONObjectWithData(inputData, options: NSJSONReadingOptions.MutableContainers, error: &error) as! Array<NSDictionary>
        
        return arr
    }

    func searchBarSearchButtonClicked( searchBar: UISearchBar)
    {
        self.view.removeGestureRecognizer(tapRecognizer)
        var found = false
        for bar in bars {
            var barName = bar.name.stringByReplacingOccurrencesOfString("\'", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
            var searchString = searchBar.text.stringByReplacingOccurrencesOfString("\'", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
            
            var test = bar as! BarAnnotation
            if barName.rangeOfString(searchString) != nil || barName.lowercaseString.rangeOfString(searchString.lowercaseString) != nil {
                found = true
                searchBar.resignFirstResponder()
                if(test.town == "Ames"){
                    segControl.selectedSegmentIndex = 0
                }
                else if(test.town == "Iowa City"){
                    segControl.selectedSegmentIndex = 1
                }
                else{
                    segControl.selectedSegmentIndex = 2
                }
                var span = MKCoordinateSpanMake(0.005, 0.005)
                var region = MKCoordinateRegion(center: test.location, span: span)
                mapView.setRegion(region, animated: true)
                mapView.selectAnnotation(bar.annotation, animated: true)
            }
        }

        if !found {
            let alert = UIAlertView()
            alert.title = "Bar Not Found"
            alert.message = "The bar you entered was not found. Please try your search again."
            alert.addButtonWithTitle("OK")
            alert.show()
            searchBar.resignFirstResponder()
        }
        
        searchBar.text = ""
    }
    
    
    func goToList(sender: UIBarButtonItem!){
        performSegueWithIdentifier("List", sender: self)
    }

    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        
        if annotation is MKUserLocation {
            // Returns nil so MapView draws "blue dot" for standard user location
            return nil
        }
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier("pin")

        if pinView == nil {
            pinView = MKAnnotationView(annotation: annotation, reuseIdentifier: "pin")
            pinView!.canShowCallout = true
            pinView!.image = scaleImage(UIImage(named: "transparent.png")!, newSize: CGSizeMake(35, 35))
            
            // Add image to left callout
            var mugIconView = UIImageView(image: scaleImage(UIImage(named: "transparent.png")!, newSize: CGSizeMake(45, 45)))
            pinView!.leftCalloutAccessoryView = mugIconView
            
            // Add detail button to right callout
            var calloutButton = UIButton.buttonWithType(.DetailDisclosure) as! UIButton
            calloutButton.tintColor = UIColor.blackColor()
            pinView!.rightCalloutAccessoryView = calloutButton
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
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
    

    func mapView(mapView: MKMapView!, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if control == annotationView.rightCalloutAccessoryView {
            detailName = annotationView.annotation.title!
            for bar in bars{
                if bar.name == detailName{
                    var curBar = bar as! BarAnnotation
                    detailTown = curBar.town
                }
            }
            performSegueWithIdentifier("Detail", sender: self)
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "Detail" {
            var BD = segue.destinationViewController as! BarDetail
            BD.detailName = detailName
            BD.amesArr = amesArr
            BD.cfArr = cfArr
            BD.icArr = icArr
            BD.detailTown = detailTown
            BD.theme = theme

        }
        
        if segue.identifier == "List" {
            var DD = segue.destinationViewController as! DailyDeals
            DD.amesArr = amesArr
            DD.cfArr = cfArr
            DD.icArr = icArr
            DD.theme = theme
        }
        self.view.removeGestureRecognizer(tapRecognizer)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}