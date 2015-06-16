//
//  DailyDeals.swift
//  TabSaver
//
//  Created by Lee Robinson on 12/7/14.
//  Copyright (c) 2014 Lee Robinson. All rights reserved.
//

import UIKit
import CoreLocation
import Parse
import MapKit
import Foundation

class DailyDeals: UIViewController, UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate, CLLocationManagerDelegate, UISearchBarDelegate, SettingsDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segControl: UISegmentedControl!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var listSearchBar: UISearchBar!
    @IBOutlet weak var curLocBtn: UIButton!
 
    var bars = [] as NSMutableArray
    var barsArr = [] as NSArray
    var removedBars = [] as NSMutableArray
    var detailName = ""
    var detailTown = ""
    var distance = ""

    var theme = 0;
    var showDeals = 0
    var showClosed = 0
    var prevSearchStrLen = 0
    var barView = true

    let locationManager = CLLocationManager()
    var ImagesDict = Dictionary<String, NSData>()
    var tapRecognizer = UITapGestureRecognizer()
    var refreshControl = UIRefreshControl()
    
    var colors = Colors()
    var coreDataHelper = CoreDataHelper()
    var primary = UIColor()
    var secondary = UIColor()
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Initally hide the map and start async retriving images
        mapView.hidden = true
        curLocBtn.hidden = true
        retrieveImages()
        
        // Handle user location
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
        
        
        // Set the span and region for the map (Default to Ames)
        if(locationManager.location == nil) {
            let span = MKCoordinateSpanMake(0.075, 0.075)
            let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 42.035021, longitude: -93.645), span: span)
            mapView.setRegion(region, animated: true)
        }
        else{
            setLocation()
        }
        
        // Support for settings
        showDeals = coreDataHelper.getInt("ShowNo", key: "show")
        showClosed = coreDataHelper.getInt("ShowClosed", key: "show")

        // Get JSON data from URL, create bar array, and sort by distance
        barsArr = parseJSON(getJSON("http://tabsaver.info/retrieveBars.php")) as NSArray
        bars = createBarArray(barsArr)
        setDistances()
        sortBars()
        
        // Add refresh control to table
        tableView.delegate = self
        refreshControl.backgroundColor = colors.blue
        refreshControl.tintColor = UIColor.whiteColor()
        refreshControl.addTarget(self, action: Selector("refreshDistances"), forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refreshControl)
        
        // Add the settings button to the left bar button
        let img = scaleImage(UIImage(named: "settings-50.png")!, newSize: CGSize(width: 20.0, height: 20.0))
        let settingsBtn = UIBarButtonItem(image: img, style: UIBarButtonItemStyle.Plain, target: self, action: "goToSettings")
        self.navigationItem.leftBarButtonItem = settingsBtn
    }
    
    override func viewWillAppear(animated: Bool) {
        
        // Change colors based on theme
        theme = coreDataHelper.getInt("Theme", key: "themeNumber")
        
        switch theme {
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
        
        // Add bars to map
        mapView.removeAnnotations(mapView.annotations)
        for bar in bars {
            mapView.addAnnotation(bar.annotation)
        }
    }
    
    func retrieveImages() {
        
        var image: UIImage?
        let query = PFQuery(className: "BarPhotos")
        
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]?, error: NSError?) -> Void in
            
            if error == nil {
                if let objects = objects as? [PFObject] {
                    for object in objects {
                        let barName = object["barName"] as! String
                        let userImageFile = object["imageFile"] as! PFFile
                        userImageFile.getDataInBackgroundWithBlock {
                            (imageData: NSData?, error: NSError?) -> Void in
                            if error == nil {
                                if let imageData = imageData {
                                    
                                    self.ImagesDict[barName] = imageData
                                    self.mapView.reloadInputViews()
                                    self.tableView.reloadData()
                                    
                                    // Find the annotation corresponding to this bar and update the image
                                    let annotations = self.mapView.annotations
                                    for bar in annotations {
                                        if(!bar.isKindOfClass(MKUserLocation)){
                                            let barAnn = bar as! MKPointAnnotation
                                            let view = self.mapView.viewForAnnotation(barAnn)
                                            
                                            if barAnn.title! == barName {
                                                let scaledImage = UIImageView(image: self.scaleImage(UIImage(data: imageData)!, newSize: CGSizeMake(45, 45)))
                                                if(view != nil){
                                                    view.leftCalloutAccessoryView = scaledImage
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            } else {
                // Log details of the failure
                println("Error: \(error!) \(error!.userInfo!)")
            }
        }
    }

    func changeTheme() {
        
        let navItem = navigationController?.navigationBar;
        navItem?.barTintColor = primary
        navItem?.tintColor = secondary
        navItem?.backgroundColor = secondary
        navItem?.titleTextAttributes = [NSForegroundColorAttributeName: secondary]
        navItem?.barStyle = UIBarStyle.Black
        navItem?.translucent = false
        navItem?.hideBottomHairline()

        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: self, action: nil)
        
        listSearchBar.backgroundImage = getImageWithColor(primary, size: CGSize(width: 100, height: 50))
        listSearchBar.tintColor = colors.lightGray

        refreshControl.backgroundColor = primary
        refreshControl.tintColor = secondary
        
        tableView.reloadData()
    }
    
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        tapRecognizer = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
        tapRecognizer.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(tapRecognizer)
    }
    
    
    func handleSingleTap(recognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
        listSearchBar.resignFirstResponder()
        self.view.removeGestureRecognizer(tapRecognizer)
    }
    
    func refreshDistances() {      
        setDistances()
        sortBars()
        tableView.reloadData()
        refreshControl.endRefreshing()
    }

    @IBAction func indexChanged(sender: UISegmentedControl) {
        
        switch segControl.selectedSegmentIndex
        {
            case 0:
                mapView.hidden = true
                curLocBtn.hidden = true
                barView = true
                tableView.setContentOffset(CGPointZero, animated: false)
            case 1:
                mapView.hidden = false
                curLocBtn.hidden = false
                barView = false
            default:
                mapView.hidden = true
                curLocBtn.hidden = true
                barView = true
        }
        
        tableView.reloadData()
    }
    
    @IBAction func goToCurrentLoc(sender: AnyObject) {
        
        if locationManager.location == nil {
            let alert = UIAlertView()
            alert.title = "Location Disabled"
            alert.message = "Location must be enabled to view your current location."
            alert.addButtonWithTitle("OK")
            alert.show()
        }
        else {
            selectLocation(locationManager.location.coordinate.latitude, long: locationManager.location.coordinate.longitude)
        }
    }
    
    func selectLocation(lat: Double, long: Double) {
        let span = MKCoordinateSpanMake(0.075, 0.075)
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: lat, longitude: long), span: span)
        mapView.setRegion(region, animated: true)
    }
    
    func setLocation() {
        
        let span = MKCoordinateSpanMake(0.075, 0.075)
        let amesLocation = CLLocation(latitude: 42.035021, longitude: -93.645)
        let cfLocation = CLLocation(latitude: 42.520700, longitude: -92.438965)
        let icLocation = CLLocation(latitude: 41.656497, longitude: -91.535339)
        
        if((locationManager.location.distanceFromLocation(amesLocation) / 1609.344) < 30) {
            let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 42.035021, longitude: -93.645), span: span)
            mapView.setRegion(region, animated: true)
        }
            
        else if((locationManager.location.distanceFromLocation(cfLocation) / 1609.344) < 30) {
            let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 42.520700, longitude: -92.438965), span: span)
            mapView.setRegion(region, animated: true)
        }
            
        else if((locationManager.location.distanceFromLocation(icLocation) / 1609.344) < 30) {
            let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 41.656497, longitude: -91.535339), span: span)
            mapView.setRegion(region, animated: true)
        }
            
        else { // Default to Ames location
            let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 42.035021, longitude: -93.645), span: span)
            mapView.setRegion(region, animated: true)
        }
    }
    
    func createBarArray(arr: NSArray) -> NSMutableArray {
        
        var bars = [] as NSMutableArray
        
        // Get day of the week + 2 hours
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "EEEE"
        let currDate = NSDate()
        let twoHours = 2 * 60 * 60 as NSTimeInterval
        let newDate = currDate.dateByAddingTimeInterval(-twoHours)
        let dayOfWeekString = dateFormatter.stringFromDate(newDate)
        
        // Loop through bars
        for(var i = 0; i < arr.count; i++) {
            
            let name = arr[i]["name"] as! String
            let lat = arr[i]["lat"] as! NSString
            let long = arr[i]["long"] as! NSString
            let negLong = -long.doubleValue
            let deal = arr[i][dayOfWeekString] as! String

            let newBar = BarAnnotation(latitude: lat.doubleValue, longitude: negLong, name: name, deal: deal.replace(",", withString: ", "))
            newBar.town = arr[i]["town"] as! String
            
            if(deal == "No Deals" && showDeals == 1) {
                //println(deal)
            }
            else if(deal == "Closed" && showClosed == 1) {
                //println(deal)
            }
            else {
                bars.addObject(newBar)
            }
        }
        
        return bars
    }
    
    func setDistances() {
        for bar in bars {
            let currentBar = bar as! BarAnnotation
            if locationManager.location == nil {
                currentBar.distance = 0
            }
            else {
                let dist = locationManager.location.distanceFromLocation(currentBar.loc) / 1609.344
                currentBar.distance = Double(round(10*dist)/10)
            }
        }
    }
    
    func sortBars(){
        bars.sortUsingComparator {
            let one = $0 as! BarAnnotation
            let two = $1 as! BarAnnotation
            let first = one.distance as Double // Use one.name for A-Z
            let second = two.distance as Double // Use two.name for A-Z
      
            if first < second {
                return NSComparisonResult.OrderedAscending
            } else if first > second {
                return NSComparisonResult.OrderedDescending
            } else {
                return NSComparisonResult.OrderedSame
            }
        }
    }

    func searchBarSearchButtonClicked( searchBar: UISearchBar) {
        self.view.removeGestureRecognizer(tapRecognizer)
        
        if !barView {
            var found = false
            for bar in bars {

                let barName = bar.name.replace("\'", withString: "")
                let searchString = searchBar.text.replace("\'", withString: "")
                let barAnn = bar as! BarAnnotation
                
                if barName.rangeOfString(searchString) != nil || barName.lowercaseString.rangeOfString(searchString.lowercaseString) != nil {
                    found = true
                    searchBar.resignFirstResponder()
                    
                    let span = MKCoordinateSpanMake(0.005, 0.005)
                    let region = MKCoordinateRegion(center: barAnn.location, span: span)
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
        else {
            
            if bars.count == 1 {
                let bar = bars.objectAtIndex(0) as! BarAnnotation
                detailTown = bar.town
                distance = "\(bar.distance)"
                detailName = bar.name
                performSegueWithIdentifier("DetailFromList", sender: self)
            }
            
            searchBar.resignFirstResponder()
        }
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        var matchedBars = [] as NSMutableArray
        
        if barView {
            
            let size = count(searchText)
            if  size != 0 && size > prevSearchStrLen {
                
                for bar in bars {
                    var b = bar as! BarAnnotation

                    if b.name.lowercaseString.rangeOfString(searchText.lowercaseString) == nil {
                        if !removedBars.containsObject(bar) {
                            removedBars.addObject(bar)
                        }
                    }
                    else {
                        matchedBars.addObject(bar)
                    }
                }

                bars = matchedBars
            }
            else if size != 0 && size < prevSearchStrLen {
                
                for bar in removedBars {
                    var b = bar as! BarAnnotation
                    if !bars.containsObject(bar) && b.name.lowercaseString.rangeOfString(searchText.lowercaseString) != nil{
                        bars.addObject(bar)
                    }
                }
            }
            else {
                
                for bar in removedBars {
                    if !bars.containsObject(bar) {
                        bars.addObject(bar)
                    }
                }
                
                removedBars.removeAllObjects()
            }
            
            sortBars()
            tableView.reloadData()
            tableView.reloadInputViews()
            prevSearchStrLen = size
        }
    }

    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        
        if annotation is MKUserLocation { // Draw blue dot for user location
            return nil
        }
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier("pin")
        
        if pinView == nil {
            pinView = MKAnnotationView(annotation: annotation, reuseIdentifier: "pin")
            pinView!.canShowCallout = true
            
            // Add detail button to right callout
            var calloutButton = UIButton.buttonWithType(.DetailDisclosure) as! UIButton
            calloutButton.tintColor = UIColor.blackColor()
            pinView!.rightCalloutAccessoryView = calloutButton
        }
        else {
            pinView!.annotation = annotation
        }
        
        // If the bar is a favorite, make the pin image a star
        if(coreDataHelper.isFavorite("Favorites", key: "list", barName: pinView.annotation.title!) && coreDataHelper.getInt("ShowFav", key: "show") == 0){
            pinView!.image = scaleImage(UIImage(named: "star2.png")!, newSize: CGSizeMake(30, 30))
        }
        else{
            pinView!.image = scaleImage(UIImage(named: "transparent.png")!, newSize: CGSizeMake(35, 35))
        }
        
        // Load the image from the array retrieved from Parse
        if(!ImagesDict.isEmpty && ImagesDict[annotation.title!] != nil){
            let scaledImage = UIImageView(image: scaleImage(UIImage(data: ImagesDict[annotation.title!]!)!, newSize: CGSizeMake(45, 45)))
            pinView!.leftCalloutAccessoryView = scaledImage
        }
        
        return pinView
    }
 
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = DealCell()
        let currentBar = bars[indexPath.row] as! BarAnnotation

        if indexPath.row % 2 == 0 {
            cell = tableView.dequeueReusableCellWithIdentifier("Bar Cell Shaded", forIndexPath: indexPath) as! DealCell
            cell.backgroundColor = primary.colorWithAlphaComponent(0.07)
        }
        else{
            cell = tableView.dequeueReusableCellWithIdentifier("Bar Cell", forIndexPath: indexPath) as! DealCell
        }

        cell.barName.text = currentBar.name
        cell.deal.text = currentBar.deal
        cell.distanceToBar.text = String(format: "%.1f mi", currentBar.distance)
        
        if(!ImagesDict.isEmpty && ImagesDict[currentBar.name] != nil) {
            cell.barImage.image = UIImage(data: ImagesDict[currentBar.name]!)
        }
        
        // Change colors based on theme
        switch theme {
            case 0: // Default
                cell.barName.textColor = primary
                cell.distanceToBar.textColor = colors.gray
                break;
            case 1: // Ames
                cell.barName.textColor = primary
                cell.distanceToBar.textColor = secondary
                break;
            case 2: // Iowa City
                cell.barName.textColor = colors.black
                break;
            case 3: // Cedar Falls
                cell.barName.textColor = primary
                cell.distanceToBar.textColor = secondary
                break;
            default:
                break;
        }

        return cell
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80.0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bars.count
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! DealCell
        let selectedBar = bars[indexPath.row] as! BarAnnotation
        
        detailTown = selectedBar.town
        distance = "\(selectedBar.distance)"
        detailName = cell.barName.text!
        performSegueWithIdentifier("DetailFromList", sender: self)
    }
    
    func mapView(mapView: MKMapView!, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if control == annotationView.rightCalloutAccessoryView {
            detailName = annotationView.annotation.title!
            for bar in bars {
                if bar.name == detailName {
                    var curBar = bar as! BarAnnotation
                    detailTown = curBar.town
                    
                    if locationManager.location == nil {
                        distance = "0.0"
                    }
                    else {
                        let dist = locationManager.location.distanceFromLocation(curBar.loc) / 1609.344
                        distance = "\(Double(round(10*dist)/10))"
                    }
                }
            }
            performSegueWithIdentifier("DetailFromList", sender: self)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "DetailFromList" {
            var BD = segue.destinationViewController as! BarDetail
            BD.barsArr = barsArr
            BD.detailName = detailName
            BD.detailTown = detailTown
            BD.theme = theme
            BD.ImagesDict = ImagesDict
            BD.distance = distance
            BD.primary = primary
            BD.secondary = secondary
        }
        
        if segue.identifier == "Settings" {
            let NC = segue.destinationViewController as! UINavigationController
            let SS = NC.topViewController as! Settings
            SS.delegate = self
        }
        
        self.view.removeGestureRecognizer(tapRecognizer)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func goToSettings() {
        performSegueWithIdentifier("Settings", sender: self)
    }
    
    func getJSON(urlToRequest: String) -> NSData {
        return NSData(contentsOfURL: NSURL(string: urlToRequest)!)!
    }
    
    func parseJSON(inputData: NSData) -> Array<NSDictionary>{
        var error: NSError?
        var arr = NSJSONSerialization.JSONObjectWithData(inputData, options: NSJSONReadingOptions.MutableContainers, error: &error) as! Array<NSDictionary>
        
        return arr
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
    
    func getImageWithColor(color: UIColor, size: CGSize) -> UIImage {
        var rect = CGRectMake(0, 0, size.width, size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(rect)
        var image: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

extension UINavigationBar {
    
    func hideBottomHairline() {
        let navigationBarImageView = hairlineImageViewInNavigationBar(self)
        navigationBarImageView!.hidden = true
    }
    
    func showBottomHairline() {
        let navigationBarImageView = hairlineImageViewInNavigationBar(self)
        navigationBarImageView!.hidden = false
    }
    
    private func hairlineImageViewInNavigationBar(view: UIView) -> UIImageView? {
        if view.isKindOfClass(UIImageView) && view.bounds.height <= 1.0 {
            return (view as! UIImageView)
        }
        
        let subviews = (view.subviews as! [UIView])
        for subview: UIView in subviews {
            if let imageView: UIImageView = hairlineImageViewInNavigationBar(subview) {
                return imageView
            }
        }
        
        return nil
    }
}
