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
import SystemConfiguration

class DailyDeals: UIViewController, UITableViewDelegate, UIAlertViewDelegate, UITableViewDataSource, MKMapViewDelegate, CLLocationManagerDelegate, UISearchBarDelegate, LocationDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segControl: UISegmentedControl!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var listSearchBar: UISearchBar!
    @IBOutlet weak var curLocBtn: UIButton!
    @IBOutlet weak var autoCompleteTable: UITableView!
    
    var bars = [] as NSMutableArray
    var barsArr = [] as NSArray
    var removedBars = [] as NSMutableArray
    var mapBars = [] as NSMutableArray
    var autoCompleteBars = [] as NSMutableArray
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
    var HoursDict = Dictionary<String, String>()
    var DealsDict = Dictionary<String, [String]>()
    var tapRecognizer = UITapGestureRecognizer()
    var refreshControl = UIRefreshControl()
    
    let api = FoursquareAPI()
    var colors = Colors()
    var coreDataHelper = CoreDataHelper()
    var parseHelper = ParseHelper()
    var analytics = Analytics()
    var primary = UIColor()
    var secondary = UIColor()
    
    var activityIndicatorView = NVActivityIndicatorView(frame: CGRectZero, type: NVActivityIndicatorType.BallSpinFadeLoader)
    var blurView = UIVisualEffectView()
    var barCount = 0
    var initialLocation = ""
    var shortcutItem = ""
    var taxiNumber = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if !isConnectedToNetwork() {
            let alert = UIAlertView()
            alert.title = "Internet Disabled"
            alert.message = "An internet connection is required to use this app. Please reconnect and try again."
            alert.delegate = self
            alert.addButtonWithTitle("OK")
            alert.show()
            analytics.log("Error: Internet Disabled", secondary: "")
        }
        else {
            
            // Initally hide the map and start async retriving images
            createLoadingScreen()
            mapView.hidden = true
            curLocBtn.hidden = true
            
            // Handle user location
            locationManager.requestWhenInUseAuthorization()
            
            if CLLocationManager.locationServicesEnabled() {
                locationManager.delegate = self
                locationManager.desiredAccuracy = kCLLocationAccuracyBest
                locationManager.startUpdatingLocation()
            }
            
            // Set the span and region for the map
            if(locationManager.location == nil) {
                
                // Test with Ames location
                //api.searchForBarsAtLocation(CLLocation(latitude: 42.035021, longitude: -93.645))
                //api.getBarsRating("4d5ade2cc88da1cd34a94968")
                
                let installObj = PFInstallation.currentInstallation()
                let location = installObj.valueForKey("location")
                
                if location == nil {
                    setMapToCity("Ames")
                    initialLocation = "Ames"
                    analytics.log("Location Disabled", secondary: "On Load")
                    installObj.setValue("Ames", forKey: "location")
                    installObj.saveInBackground()
                } else {
                    let city = location as! String
                    setMapToCity(city)
                    initialLocation = city
                    analytics.log("App Open", secondary: city)
                }
                
                // Load all the data
                retrieveBars(initialLocation)
                retrieveImages(initialLocation)
                retrieveHours(initialLocation)
            }
            else{
                setLocation()
            }
            
            // Support for settings
            showDeals = coreDataHelper.getInt("ShowNo", key: "show")
            showClosed = coreDataHelper.getInt("ShowClosed", key: "show")

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
            
            // Add the taxi button to the right bar button
            let img2 = scaleImage(UIImage(named: "taxi.png")!, newSize: CGSize(width: 23.0, height: 23.0))
            let taxiBtn = UIBarButtonItem(image: img2, style: UIBarButtonItemStyle.Plain, target: self, action: "callTaxi")
            self.navigationItem.rightBarButtonItem = taxiBtn
            
            // Change the font of the search bar
            for subView in listSearchBar.subviews  {
                for subsubView in subView.subviews  {
                    if let textField = subsubView as? UITextField {
                        textField.font = UIFont(name: ".HelveticaNeueDeskInterface-Regular", size: 14.0)
                    }
                }
            }
        }
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
        
        
        // Possibly reload bars here so that No Deals and Closed changes update
        
        // Add bars to map
        mapView.removeAnnotations(mapView.annotations)
        for bar in mapBars {
            mapView.addAnnotation(bar.annotation!!)
        }
    }
    
    func createLoadingScreen() {
        
        // Blur the screen dark so we can see loading animation
        blurView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.Dark))
        let blurFrame = CGRect(x: 0, y: listSearchBar.frame.height, width: self.view.frame.width, height: self.view.frame.height)
        blurView.frame = blurFrame
        self.view.addSubview(blurView)
        
        // Start the loading animation and continue until all bars are loaded
        let frame = CGRect(x: self.view.frame.width/2 - 25, y: self.view.frame.height/2 + listSearchBar.frame.height - 75, width: 50, height: 50)
        activityIndicatorView = NVActivityIndicatorView(frame: frame, type: NVActivityIndicatorType.BallSpinFadeLoader)
        self.view.addSubview(activityIndicatorView)
        activityIndicatorView.bringSubviewToFront(self.view)
        activityIndicatorView.startAnimation()
    }
    
    func retrieveBars(location: String) {
        
        let query = PFQuery(className:"Bars")
        query.whereKey("city", equalTo: location)
        findAsync(query).continueWithSuccessBlock {
            (task: BFTask!) -> AnyObject! in

            let barsArr = [] as NSMutableArray
            self.barsArr = task.result as! NSArray
      
            let bars = task.result as! NSArray
            for bar in bars {
                
                self.barCount = bars.count
                let name = bar["name"] as! String
                let lat = bar["lat"] as! NSNumber
                let long = bar["long"] as! NSNumber
                
                // Query this bar's deals
                var deal = ""
                let query = PFQuery(className:"Deals")
                query.whereKey("name", equalTo: name)
                self.findAsync(query).continueWithSuccessBlock {
                    (task: BFTask!) -> AnyObject! in
                    
                    let bars = task.result as! NSArray
                    let dealArr = bars[0][self.getDayOfWeek()] as! [String]
                    deal = dealArr.joinWithSeparator(", ")
                    
                    // Create deals array to pass to detail page
                    let sun = bars[0]["Sunday"] as! [String]
                    let mon = bars[0]["Monday"] as! [String]
                    let tue = bars[0]["Tuesday"] as! [String]
                    let wed = bars[0]["Wednesday"] as! [String]
                    let thu = bars[0]["Thursday"] as! [String]
                    let fri = bars[0]["Friday"] as! [String]
                    let sat = bars[0]["Saturday"] as! [String]
                    self.DealsDict[name] = [sun.joinWithSeparator(", "),
                                            mon.joinWithSeparator(", "),
                                            tue.joinWithSeparator(", "),
                                            wed.joinWithSeparator(", "),
                                            thu.joinWithSeparator(", "),
                                            fri.joinWithSeparator(", "),
                                            sat.joinWithSeparator(", ")]
                    
                    return nil
                    
                    }.continueWithSuccessBlock {
                        (task: BFTask!) -> AnyObject! in
                        
                        let newBar = BarAnnotation(latitude: lat.doubleValue, longitude: long.doubleValue, name: name, deal: deal.replace(",", withString: ", "))
                        newBar.town = bar["city"] as! String
                        
                        if(deal == "No Deals" && self.showDeals == 1) {
                            self.barCount--
                        }
                        else if(deal == "Closed" && self.showClosed == 1) {
                            self.barCount--
                        }
                        else {
                            barsArr.addObject(newBar)
                            self.bars = barsArr
                            self.tableView.reloadData()
                            self.mapView.addAnnotation(newBar.annotation)
                            self.mapBars = barsArr
                            self.autoCompleteBars = NSMutableArray(array: barsArr.copy() as! [BarAnnotation])
                            self.autoCompleteTable.reloadData()
                            
                            self.setDistances()
                            self.sortBars()
                        }
                        
                        return nil
                }
            }
            return nil
        }
    }

    func retrieveImages(location: String) {
        
        let query = PFQuery(className: "BarPhotos")
        query.whereKey("city", equalTo: location)
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
                                                    view!.leftCalloutAccessoryView = scaledImage
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
                self.analytics.log("Error: Retrieving Images", secondary: error!.localizedDescription)
            }
        }
    }
    
    func retrieveHours(location: String) {
        
        let query = PFQuery(className:"BarHours")
        query.whereKey("city", equalTo: location)
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]?, error: NSError?) -> Void in
            
            if error == nil {
                // Succesfully found the hours
                if let objects = objects as? [PFObject] {
                    for object in objects {
                        
                        // Get day of the week + 2 hours
                        let dateFormatter = NSDateFormatter()
                        dateFormatter.dateFormat = "EEEE"
                        let currDate = NSDate()
                        let twoHours = 2 * 60 * 60 as NSTimeInterval
                        let newDate = currDate.dateByAddingTimeInterval(-twoHours)
                        let dayOfWeekString = dateFormatter.stringFromDate(newDate)
                        
                        let barName = object["name"] as! String
                        var barHours = object[dayOfWeekString.lowercaseString] as! String
                        if barHours == "Closed" || barHours == "Hours Unknown" {
                            // For some reason != wasn't working...
                        }
                        else {
                            barHours = "Open \(barHours)"
                        }
                        
                        self.HoursDict[barName] = barHours
                    }
                }
            } else {
                // Log details of the failure
                self.analytics.log("Error: Retrieving Hours", secondary: error!.localizedDescription)
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
        
        if barView {
            tapRecognizer = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
            tapRecognizer.numberOfTapsRequired = 1
            self.view.addGestureRecognizer(tapRecognizer)
        }
        else {
            autoCompleteTable.setContentOffset(CGPointZero, animated: false)
            autoCompleteTable.hidden = false
        }
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
    
    func goToList() {
        segControl.selectedSegmentIndex = 1
        mapView.hidden = false
        curLocBtn.hidden = false
        barView = false
        listSearchBar.placeholder = "Search Bars"
        tableView.reloadData()
    }

    @IBAction func indexChanged(sender: UISegmentedControl) {
        
        switch segControl.selectedSegmentIndex
        {
            case 0:
                // Reset autocomplete search
                autoCompleteBars = NSMutableArray(array: bars.copy() as! [BarAnnotation])
                autoCompleteTable.hidden = true
                autoCompleteTable.reloadData()
                listSearchBar.resignFirstResponder()
                
                mapView.hidden = true
                curLocBtn.hidden = true
                barView = true
                tableView.setContentOffset(CGPointZero, animated: false)
                listSearchBar.placeholder = "Search Bars & Drinks"
                analytics.log("Selected", secondary: "List")
            case 1:
                mapView.hidden = false
                curLocBtn.hidden = false
                barView = false
                listSearchBar.placeholder = "Search Bars"
                analytics.log("Selected", secondary: "Map")
            default:
                // Reset autocomplete search
                autoCompleteBars = NSMutableArray(array: bars.copy() as! [BarAnnotation])
                autoCompleteTable.hidden = true
                autoCompleteTable.reloadData()
                listSearchBar.resignFirstResponder()
                
                mapView.hidden = true
                curLocBtn.hidden = true
                barView = true
                listSearchBar.placeholder = "Search Bars & Drinks"

        }
        
        tableView.reloadData()
    }
    
    @IBAction func goToCurrentLoc(sender: AnyObject) {
        
        if locationManager.location == nil {
            let alert = UIAlertView()
            alert.title = "Location Disabled"
            alert.message = "Location must be enabled to view your current location."
            alert.delegate = self
            alert.addButtonWithTitle("OK")
            alert.show()
            analytics.log("Location Disabled", secondary: "Current Location")
        }
        else {
            selectLocation(locationManager.location!.coordinate.latitude, long: locationManager.location!.coordinate.longitude)
            analytics.log("Selected", secondary: "Current Location")
        }
    }
    
    func selectLocation(lat: Double, long: Double) {
        let span = MKCoordinateSpanMake(0.03, 0.03)
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: lat, longitude: long), span: span)
        mapView.setRegion(region, animated: true)
    }
    
    func setLocation() {
        
        let query = PFQuery(className:"Locations")
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]?, error: NSError?) -> Void in
            
            if error == nil {
                if let objects = objects as? [PFObject] {
                    var closestDistance = 100.0
                    var closestCity = "Ames"
                    
                    for object in objects {
                        let location = Location(city: object["cityName"] as! String,
                                                state: object["state"] as! String,
                                                taxiService: object["taxiService"] as! String,
                                                taxiNumber: object["taxiNumber"] as! String,
                                                lat: object["lat"] as! Double,
                                                long: object["long"] as! Double)
                        
                        let gps = CLLocation(latitude: location.lat, longitude: location.long)
                        let distance = self.locationManager.location!.distanceFromLocation(gps) / 1609.344
                        
                        if distance < closestDistance {
                            closestDistance = distance
                            closestCity = location.city
                        }
                    }
                    
                    self.setMapToCity(closestCity)
                    self.initialLocation = closestCity
                    
                    if closestDistance == 100.0 {
                        let lat = self.locationManager.location!.coordinate.latitude
                        let long = self.locationManager.location!.coordinate.longitude
                        self.analytics.log("App Open", secondary: "Lat: \(lat), Long: \(long)")
                    } else {
                        self.analytics.log("App Open", secondary: closestCity)
                    }
                    
                    
                    let installObj = PFInstallation.currentInstallation()
                    installObj.setValue(self.initialLocation, forKey: "location")
                    installObj.saveInBackground()
                    
                    // At this point we have the location, so we are able to query the taxi call
                    self.handleShortcutItem()
                    
                    // Load all the data
                    self.retrieveBars(self.initialLocation)
                    self.retrieveImages(self.initialLocation)
                    self.retrieveHours(self.initialLocation)
                }
            } else {
                self.analytics.log("Error: Retrieving Locations", secondary: error!.localizedDescription)
            }
        }
    }
    
    func setMapToCity(city: String) {
        
        let span = MKCoordinateSpanMake(0.075, 0.075)
        var region = MKCoordinateRegion()
        
        let query = PFQuery(className:"Locations")
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]?, error: NSError?) -> Void in
            
            if error == nil {
                if let objects = objects as? [PFObject] {
                    for object in objects {
                        if object["cityName"] as! String == city {
                            let lat = object["lat"] as! Double
                            let long = object["long"] as! Double
                            region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: lat, longitude: long), span: span)
                            break
                        }
                    }
                    self.mapView.setRegion(region, animated: false)
                }
            } else {
                self.analytics.log("Error: Retrieving Locations", secondary: error!.localizedDescription)
            }
        }
    }

    func setDistances() {
        for bar in bars {
            let currentBar = bar as! BarAnnotation
            if locationManager.location == nil {
                currentBar.distance = 0
            }
            else {
                let dist = locationManager.location!.distanceFromLocation(currentBar.loc) / 1609.344
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

    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        self.view.removeGestureRecognizer(tapRecognizer)
        
        if !barView {
            
            if autoCompleteBars.count == 1 {
                
                let selectedBar = autoCompleteBars[0] as! BarAnnotation
                
                for bar in bars {
                    
                    let barAnn = bar as! BarAnnotation
                    if barAnn.name.rangeOfString(selectedBar.name) != nil  {
                        
                        let span = MKCoordinateSpanMake(0.005, 0.005)
                        let region = MKCoordinateRegion(center: barAnn.location, span: span)
                        self.mapView.setRegion(region, animated: true)
                        self.mapView.selectAnnotation(bar.annotation!!, animated: true)
                        analytics.barClicked(bar.name, key: "searchQueries")
                        break
                        
                    }
                }
                
                listSearchBar.text = ""
                autoCompleteBars = NSMutableArray(array: bars.copy() as! [BarAnnotation])
                autoCompleteTable.hidden = true
                autoCompleteTable.reloadData()
                listSearchBar.resignFirstResponder()
            }
        }
        else {
            
            if bars.count == 1 {
                let bar = bars.objectAtIndex(0) as! BarAnnotation
                detailTown = bar.town
                distance = "\(bar.distance)"
                detailName = bar.name
                performSegueWithIdentifier("DetailFromList", sender: self)
                analytics.barClicked(detailName, key: "searchQueries")
            }
            
            searchBar.resignFirstResponder()
        }
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        let matchedBars = [] as NSMutableArray
        
        if barView {
            
            let size = searchText.characters.count
            if  size != 0 && size > prevSearchStrLen {
                
                for bar in bars {
                    let b = bar as! BarAnnotation
                    
                    if b.name.lowercaseString.rangeOfString(searchText.lowercaseString) == nil &&
                        b.deal.lowercaseString.rangeOfString(searchText.lowercaseString) == nil {
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
                    let b = bar as! BarAnnotation
                    if !bars.containsObject(bar) && (b.name.lowercaseString.rangeOfString(searchText.lowercaseString) != nil ||
                        b.deal.lowercaseString.rangeOfString(searchText.lowercaseString) != nil ){
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
        else {
            self.view.removeGestureRecognizer(tapRecognizer)
            
            if searchText.characters.count == 0 {
                for bar in removedBars {
                    if !bars.containsObject(bar) {
                        bars.addObject(bar)
                    }
                }
                
                removedBars.removeAllObjects()
                sortBars()
                tableView.reloadData()
                autoCompleteBars = NSMutableArray(array: bars.copy() as! [BarAnnotation])
                autoCompleteTable.reloadData()
            }
            else {
                searchAutoCompleteEntriesWithSubstring(searchText)
            }
        }
    }
    
    func searchAutoCompleteEntriesWithSubstring(substring: String) {
        
        let filteredResults = NSMutableArray(array: autoCompleteBars.copy() as! [BarAnnotation])
        autoCompleteBars.removeAllObjects()
        
        for annotation in filteredResults {
            let bar = annotation as! BarAnnotation
   
            if bar.name.lowercaseString.rangeOfString(substring.lowercaseString) != nil {
                autoCompleteBars.addObject(bar)
            }

        }
        
        autoCompleteTable.reloadData()
    }

    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation { // Draw blue dot for user location
            return nil
        }
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier("pin")
        
        if pinView == nil {
            pinView = MKAnnotationView(annotation: annotation, reuseIdentifier: "pin")
            pinView!.canShowCallout = true
            
            // Add detail button to right callout
            let calloutButton = UIButton(type: .DetailDisclosure)
            calloutButton.tintColor = UIColor.blackColor()
            pinView!.rightCalloutAccessoryView = calloutButton
        }
        else {
            pinView!.annotation = annotation
        }
        
        // If the bar is a favorite, make the pin image a star
        if(coreDataHelper.isFavorite("Favorites", key: "list", barName: pinView!.annotation!.title!!) && coreDataHelper.getInt("ShowFav", key: "show") == 0){
            pinView!.image = scaleImage(UIImage(named: "star2.png")!, newSize: CGSizeMake(30, 30))
        }
        else{
            pinView!.image = scaleImage(UIImage(named: "transparent.png")!, newSize: CGSizeMake(35, 35))
        }
        
        // Load the image from the array retrieved from Parse
        if(!ImagesDict.isEmpty && ImagesDict[annotation.title!!] != nil){
            let scaledImage = UIImageView(image: scaleImage(UIImage(data: ImagesDict[annotation.title!!]!)!, newSize: CGSizeMake(45, 45)))
            pinView!.leftCalloutAccessoryView = scaledImage
        }
        
        return pinView
    }
 
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if tableView != autoCompleteTable {
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
                    break
                case 1: // Ames
                    cell.barName.textColor = primary
                    cell.distanceToBar.textColor = secondary
                    break
                case 2: // Iowa City
                    cell.barName.textColor = colors.black
                    break
                case 3: // Cedar Falls
                    cell.barName.textColor = primary
                    cell.distanceToBar.textColor = secondary
                    break
                default:
                    break
            }
            
            if bars.count == barCount {
                self.activityIndicatorView.stopAnimation()
                self.blurView.removeFromSuperview()
            }

            return cell
        }
        else {
            let autoCell = autoCompleteTable.dequeueReusableCellWithIdentifier("AutoCompleteCell") as UITableViewCell!
            let bar = autoCompleteBars[indexPath.row] as! BarAnnotation
            autoCell.textLabel?.text = bar.name
            autoCell.detailTextLabel?.text = "\(bar.distance) mi"
            autoCell.detailTextLabel?.font = UIFont(name: ".HelveticaNeueDeskInterface-Regular", size: 12.0)
            return autoCell
        }
    }
    
    func handleShortcutItem() {

        if shortcutItem == "Call Taxi" {
            callTaxi()
        } else if shortcutItem == "Current Location" {
            goToList()
            goToCurrentLoc(self)
        } else if shortcutItem == "Closest Bar" {
//            
//            let row = NSIndexPath(forRow: 0, inSection: 0)
//            self.tableView.selectRowAtIndexPath(row, animated: false, scrollPosition: UITableViewScrollPosition.None)
//            self.tableView(self.tableView, didSelectRowAtIndexPath: row)
//            
        }
    }
    
    func callTaxi() {
        analytics.clicked("Call Taxi")
        let query = PFQuery(className: "Locations")
        query.whereKey("cityName", equalTo: initialLocation)
        findAsync(query).continueWithSuccessBlock {
            (task: BFTask!) -> AnyObject! in
            
            let arr = task.result as! NSArray
            let city = arr[0] as! PFObject
            self.taxiNumber = city.valueForKey("taxiNumber") as! String
            let taxiName = city.valueForKey("taxiService") as! String
            
            let alert = UIAlertView()
            alert.title = "Call Taxi"
            alert.message = "Are you sure you want to call \(taxiName) of \(self.initialLocation)?"
            alert.delegate = self
            alert.addButtonWithTitle("Call")
            alert.addButtonWithTitle("Cancel")
            alert.cancelButtonIndex = 1
            alert.show()
            
            return nil
        }
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        switch buttonIndex {
            case 0:
                if(alertView.buttonTitleAtIndex(0)! == "Call") {
                    let url = NSURL(string: "tel://\(taxiNumber)")!
                    UIApplication.sharedApplication().openURL(url)
                    break;
                }
                break;
            default:
                break;
        }
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if tableView != autoCompleteTable {
            return 80.0
        }
        else {
            return 44.0
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView != autoCompleteTable {
            return bars.count
        }
        else {
            return autoCompleteBars.count
        }
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if barView {
            let cell = tableView.cellForRowAtIndexPath(indexPath) as! DealCell
            let selectedBar = bars[indexPath.row] as! BarAnnotation
            
            detailTown = selectedBar.town
            distance = "\(selectedBar.distance)"
            detailName = cell.barName.text!
            performSegueWithIdentifier("DetailFromList", sender: self)
        }
        else {
            let selectedBar = autoCompleteBars[indexPath.row] as! BarAnnotation

            for bar in bars {
                
                let barAnn = bar as! BarAnnotation
                if barAnn.name.rangeOfString(selectedBar.name) != nil  {

                    let span = MKCoordinateSpanMake(0.005, 0.005)
                    let region = MKCoordinateRegion(center: barAnn.location, span: span)
                    self.mapView.setRegion(region, animated: true)
                    self.mapView.selectAnnotation(bar.annotation!!, animated: true)
                    analytics.barClicked(bar.name, key: "searchQueries")
                    break
                    
                }
            }
            
            listSearchBar.text = ""
            autoCompleteBars = NSMutableArray(array: bars.copy() as! [BarAnnotation])
            autoCompleteTable.hidden = true
            autoCompleteTable.reloadData()
            listSearchBar.resignFirstResponder()
        }
    }
    
    func mapView(mapView: MKMapView, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if control == annotationView.rightCalloutAccessoryView {
            detailName = annotationView.annotation!.title!!
            for bar in bars {
                if bar.name == detailName {
                    let curBar = bar as! BarAnnotation
                    detailTown = curBar.town
                    
                    if locationManager.location == nil {
                        distance = "0.0"
                    }
                    else {
                        let dist = locationManager.location!.distanceFromLocation(curBar.loc) / 1609.344
                        distance = "\(Double(round(10*dist)/10))"
                    }
                }
            }
            performSegueWithIdentifier("DetailFromList", sender: self)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "DetailFromList" {
            let BD = segue.destinationViewController as! BarDetail
            BD.barsArr = barsArr
            BD.detailName = detailName
            BD.detailTown = detailTown
            BD.theme = theme
            BD.ImagesDict = ImagesDict
            BD.HoursDict = HoursDict
            BD.DealsDict = DealsDict
            BD.distance = distance
            BD.primary = primary
            BD.secondary = secondary
            analytics.barClicked(detailName, key: "pageClicks")
        }
        
        if segue.identifier == "Settings" {
            let NC = segue.destinationViewController as! UINavigationController
            let SS = NC.topViewController as! Settings
            SS.initialLocation = initialLocation
            SS.delegate = self
            analytics.clicked("Settings Menu")
        }
        
        self.view.removeGestureRecognizer(tapRecognizer)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func goToSettings() {
        performSegueWithIdentifier("Settings", sender: self)
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
        let rect = CGRectMake(0, 0, size.width, size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    func updateLocation(location: String, lat: Double, long: Double) {
        initialLocation = location
        retrieveBars(initialLocation)
        retrieveImages(initialLocation)
        retrieveHours(initialLocation)
        let span = MKCoordinateSpanMake(0.075, 0.075)
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: lat, longitude: long), span: span)
        mapView.setRegion(region, animated: false)
    }
    
    func isConnectedToNetwork() -> Bool {
        
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(&zeroAddress, {
            SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0))
        }) else {
            return false
        }
        
        var flags : SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        
        let isReachable = flags.contains(.Reachable)
        let needsConnection = flags.contains(.ConnectionRequired)
        return (isReachable && !needsConnection)
    }
    
    func findAsync(query:PFQuery) -> BFTask {
        let task = BFTaskCompletionSource()
        query.findObjectsInBackgroundWithBlock {
            (objects, error) -> Void in
            if error == nil {
                task.setResult(objects)
            } else {
                task.setError(error)
            }
        }
        return task.task
    }
    
    func getDayOfWeek() -> String {
        
        // Get day of the week + 2 hours
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "EEEE"
        let currDate = NSDate()
        let twoHours = 2 * 60 * 60 as NSTimeInterval
        let newDate = currDate.dateByAddingTimeInterval(-twoHours)
        let dayOfWeekString = dateFormatter.stringFromDate(newDate)
        return dayOfWeekString
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
        
        let subviews = (view.subviews )
        for subview: UIView in subviews {
            if let imageView: UIImageView = hairlineImageViewInNavigationBar(subview) {
                return imageView
            }
        }
        
        return nil
    }
}
