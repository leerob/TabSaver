//
//  BarMap.swift
//  Mug Night
//
//  Created by Lee Robinson on 12/5/14.
//  Copyright (c) 2014 Lee Robinson. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Foundation

@objc
protocol BarMapDelegate {
    optional func toggleLeftPanel()
    optional func collapseSidePanels()
}

class BarMap: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UISearchBarDelegate, SidePanelViewControllerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var searchButton: UIBarButtonItem!
    @IBOutlet weak var listButton: UIBarButtonItem!
    
    let locationManager = CLLocationManager()
    var delegate: BarMapDelegate?
   
    // Contains bar annotations
    var bars = [] as NSMutableArray
    var detailName = ""
    var detailDict = [:]
    var detailTown = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        // For use in foreground
        locationManager.requestWhenInUseAuthorization()

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
        var inputData = getJSON("http://drinkdeals.weebly.com/uploads/2/4/9/9/24992148/test.json")
        var dict = parseJSON(inputData)
        detailDict = parseJSON(inputData)

        // Read JSON data
        var amesBars = createBarArray("amesBars", dict: detailDict)
        var cedarFallsBars = createBarArray("cedarFallsBars", dict: detailDict)
        var iowaCityBars = createBarArray("iowaCityBars", dict: detailDict)
        
        // Add all the bars to one array
        bars.addObjectsFromArray(amesBars)
        bars.addObjectsFromArray(cedarFallsBars)
        bars.addObjectsFromArray(iowaCityBars)
        
        // Add bars to map
        for bar in bars {
            mapView.addAnnotation(bar.annotation)
        }
    }
    
    func createBarArray(townName: String, dict: NSDictionary) -> NSMutableArray{
        
        var barArray = dict[townName] as NSArray
        var bars = [] as NSMutableArray
        
        // Get day of the week
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "EEEE"
        let dayOfWeekString = dateFormatter.stringFromDate(NSDate())
        
        for bar in barArray{
            var name = bar["name"] as NSString
            var dealsArr = bar[dayOfWeekString] as NSArray
            var deal = dealsArr[0] as NSString
            var lat = bar["lat"] as Double
            var long = bar["long"] as Double
            var negLong = -long
            
            var newBar = BarAnnotation(latitude: lat, longitude: negLong, name: name, deal: deal)
            
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

            bars.addObject(newBar)
        }
        
        return bars
    }

    func menuSelected(index: Int) {
        
        delegate?.collapseSidePanels?()
        
        var span = MKCoordinateSpanMake(0.075, 0.075)
        var amesLocation = CLLocation(latitude: 42.035021, longitude: -93.645)
        var cfLocation = CLLocation(latitude: 42.520700, longitude: -92.438965)
        var icLocation = CLLocation(latitude: 41.656497, longitude: -91.535339)
        
        switch(index){
        case 0:
            // Ames Location
            var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 42.035021, longitude: -93.645), span: span)
            mapView.setRegion(region, animated: true)
        case 1:
            // Iowa City Location
            var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 41.656497, longitude: -91.535339), span: span)
            mapView.setRegion(region, animated: true)
        case 2:
            // Cedar Falls Location
            var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 42.520700, longitude: -92.438965), span: span)
            mapView.setRegion(region, animated: true)
        case 3:
            // Current Location
            if(locationManager.location == nil){
                let alert = UIAlertView()
                alert.title = "Location Disabled"
                alert.message = "Location must be enabled to view your current location."
                alert.addButtonWithTitle("OK")
                alert.show()
            }
            else{
                var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: locationManager.location.coordinate.latitude, longitude: locationManager.location.coordinate.longitude), span: span)
                mapView.setRegion(region, animated: true)
            }
        default:
            // Ames Location
            var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 42.035021, longitude: -93.645), span: span)
            mapView.setRegion(region, animated: true)
        }
    }
    
    func toggleGPS(){

        if (UIApplicationOpenSettingsURLString != nil){
            var settingsApp = NSURL(string: UIApplicationOpenSettingsURLString)
            UIApplication.sharedApplication().openURL(settingsApp!)
        }
        delegate?.collapseSidePanels?()
    }
    
    func contactUs(){
        var url:NSURL = NSURL(string: "http://www.drinkdeals.weebly.com")!
        UIApplication.sharedApplication().openURL(url)
        delegate?.collapseSidePanels?()
    }

    func showFavorites(){
        let alert = UIAlertView()
        alert.title = "Sorry!"
        alert.message = "Adding your favorite bars will be here soon. Look for an update soon."
        alert.addButtonWithTitle("OK")
        alert.show()
        delegate?.collapseSidePanels?()
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
        }
            
        else if((locationManager.location.distanceFromLocation(cfLocation) / 1609.344) < 30){
            
            // Cedar Falls Location
            var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 42.520700, longitude: -92.438965), span: span)
            mapView.setRegion(region, animated: true)
        }
            
        else if((locationManager.location.distanceFromLocation(icLocation) / 1609.344) < 30){
            
            // Iowa City Location
            var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 41.656497, longitude: -91.535339), span: span)
            mapView.setRegion(region, animated: true)
        }
            
        else{
            
            // Default to Ames location
            var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 42.035021, longitude: -93.645), span: span)
            mapView.setRegion(region, animated: true)
        }
    }
    
    func getJSON(urlToRequest: String) -> NSData{
        return NSData(contentsOfURL: NSURL(string: urlToRequest)!)!
    }
    
    func parseJSON(inputData: NSData) -> NSDictionary{
        var error: NSError?
        var dict: NSDictionary = NSJSONSerialization.JSONObjectWithData(inputData, options: NSJSONReadingOptions.MutableContainers, error: &error) as NSDictionary
        
        return dict
    }
    
    override func viewWillAppear(animated: Bool) {
        
        // Configure Nav Bar
        super.viewWillAppear(animated)
        var nav = self.navigationController?.navigationBar
        nav?.barStyle = UIBarStyle.Black
        nav?.tintColor = UIColor.whiteColor()
        nav?.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        // If you wanted to add an image
//        let logo = UIImage(named: "title.png")
//        let imageView = UIImageView(image:logo)
//        self.navigationItem.titleView = imageView
    }


    func searchBarSearchButtonClicked( searchBar: UISearchBar!)
    {
        var found = false
        for bar in bars {
            var barName = bar.name.stringByReplacingOccurrencesOfString("\'", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
            var searchString = searchBar.text.stringByReplacingOccurrencesOfString("\'", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
            
            var test = bar as BarAnnotation
            if barName.rangeOfString(searchString) != nil || barName.lowercaseString.rangeOfString(searchString.lowercaseString) != nil {
                found = true
                searchBar.resignFirstResponder()
                delegate?.collapseSidePanels?()
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
    
    @IBAction func searchMap(sender: AnyObject) {
        delegate?.toggleLeftPanel?()
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
            var calloutButton = UIButton.buttonWithType(.DetailDisclosure) as UIButton
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
                    detailTown = bar.town
                }
            }
            performSegueWithIdentifier("Detail", sender: self)
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "Detail" {
            var BD = segue.destinationViewController as BarDetail
            BD.detailName = detailName
            BD.detailDict = detailDict
            BD.detailTown = detailTown

        }
        
        if segue.identifier == "List" {
            var DD = segue.destinationViewController as DailyDeals
            DD.detailDict = detailDict
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}