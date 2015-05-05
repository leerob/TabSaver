//
//  DailyDeals.swift
//  TabSaver
//
//  Created by Lee Robinson on 12/7/14.
//  Copyright (c) 2014 Lee Robinson. All rights reserved.
//

import UIKit
import CoreLocation

class DailyDeals: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var segControl: UISegmentedControl!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var barButtonItem: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
    var locMan = CLLocationManager()
    var detailName = ""
    var detailTown = ""
    var amesArr = [] as NSArray
    var icArr = [] as NSArray
    var cfArr = [] as NSArray
    var refreshControl = UIRefreshControl()

    // Bar Arrays
    var amesBars = [] as NSMutableArray
    var cedarFallsBars = [] as NSMutableArray
    var iowaCityBars = [] as NSMutableArray
    var amesCellHeights = [] as NSMutableArray
    var cfCellHeights = [] as NSMutableArray
    var icCellHeights = [] as NSMutableArray
    var amesDeals: [(deal:String, bar:String, amount:Float)] = []
    var cedarFallsDeals: [(deal:String, bar:String, amount:Float)] = []
    var iowaCityDeals: [(deal:String, bar:String, amount:Float)] = []
    var barView = true
    
    var primary = UIColor()
    var secondary = UIColor()
    var colors = Colors()
    var theme = 0;
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Read JSON data
        amesBars = createBarArray("amesBars", arr: amesArr)
        cedarFallsBars = createBarArray("cedarFallsBars", arr: cfArr)
        iowaCityBars = createBarArray("iowaCityBars", arr: icArr)

        // Calculate distance from user location
        setDistances(amesBars)
        setDistances(cedarFallsBars)
        setDistances(iowaCityBars)
        
        // Sort the bars
        sortBars(amesBars)
        sortBars(cedarFallsBars)
        sortBars(iowaCityBars)
        sortDeals()
        
        // Configure the nav bar
        navigationController?.navigationBar.translucent = false
        var blue = UIColor(red: 57.0/255.0, green: 105.0/255.0, blue: 247.0/255.0, alpha: 1.0)
        toolBar.backgroundColor = blue
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

        // Buffer the cell heights to prevent jumping
        setCellHeightArray()
        tableView.delegate = self
        
        // Add refresh control to table
        refreshControl.backgroundColor = blue
        refreshControl.tintColor = UIColor.whiteColor()
        refreshControl.addTarget(self, action: Selector("refreshDistances"), forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refreshControl)
        
        // Testing changing themes
        switch(theme){
            case 0: // Default
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
                break;
        }
        
    }

    func refreshDistances() {
        
        setDistances(amesBars)
        setDistances(cedarFallsBars)
        setDistances(iowaCityBars)
    
        refreshControl.endRefreshing()
        tableView.reloadData()
    }
    
    func changeTheme(){

        tableView.backgroundColor = primary
        toolBar.backgroundColor = primary
        segControl.backgroundColor = primary
        segControl.tintColor = secondary
        refreshControl.backgroundColor = primary
        refreshControl.tintColor = secondary
    
    }
    
    @IBAction func indexChanged(sender: UISegmentedControl) {
        
        switch segControl.selectedSegmentIndex
        {
            case 0:
                barView = true;
                tableView.setContentOffset(CGPointZero, animated: false)
            case 1:
                barView = false;
                tableView.setContentOffset(CGPointZero, animated: false)
            default:
                barView = true;
        }
        tableView.reloadData()
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
            
            var dealsStr = arr[i][dayOfWeekString] as! NSString
            var dealsArr = dealsStr.componentsSeparatedByString(",")
            var deal = ""
            
            for (var i = 0; i < dealsArr.count; i++){
                var curDeal = dealsArr[i] as! String
                var dealAmountArr = curDeal.componentsSeparatedByString(" ")
                var formatter = NSNumberFormatter()
                formatter.numberStyle = NSNumberFormatterStyle.CurrencyStyle
                
                var amt = formatter.numberFromString(dealAmountArr[0]) as NSNumber!

                
                if(townName == "amesBars"){
                    if(curDeal.rangeOfString("$") != nil && amt != nil){
                        amesDeals.append(deal: dealsArr[i] as! String, bar: name as String, amount: amt as Float)
                    }
                }
                else if(townName == "cedarFallsBars"){
                    if(curDeal.rangeOfString("$") != nil && amt != nil){
                        cedarFallsDeals.append(deal: dealsArr[i] as! String, bar: name as String, amount: amt as Float)
                    }
                }
                else{
                    if(curDeal.rangeOfString("$") != nil && amt != nil){
                        iowaCityDeals.append(deal: dealsArr[i] as! String, bar: name as String, amount: amt as Float)
                    }
                }
                
                
                deal += "\n"
                deal += dealsArr[i] as! String
            }
            
            var lat = arr[i]["lat"] as! NSString
            var long = arr[i]["long"] as! NSString
            
            var negLong = -long.doubleValue
            
            var newBar = BarAnnotation(latitude: lat.doubleValue, longitude: negLong, name: name, deal: deal)
            newBar.cellHeight = 50.0 + (20.0 * CGFloat(dealsArr.count))
            
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
//            if(deal == "\nNo Deals"){
//                print(deal)
//            }
//            else if(deal == "\nClosed"){
//                print(deal)
//            }
//            else{
                bars.addObject(newBar)
//            }
        }
        
        return bars
    }
    
    func setDistances(barArray: NSMutableArray){
        for bar in barArray {
            
            let currentBar = bar as! BarAnnotation
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
            var one = $0 as! BarAnnotation
            var two = $1 as! BarAnnotation
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
    
    func sortDeals(){

        amesDeals.sort{ $0.amount < $1.amount }
        cedarFallsDeals.sort{ $0.amount < $1.amount }
        iowaCityDeals.sort{ $0.amount < $1.amount }

    }

    func orderOfTowns() -> NSArray{
        var ames = amesBars[0] as! BarAnnotation
        ames.town = "Ames"
        var cf = cedarFallsBars[0] as! BarAnnotation
        cf.town = "Cedar Falls"
        var ic = iowaCityBars[0] as! BarAnnotation
        ic.town = "Iowa City"
        
        var bars = [ames, cf, ic] as NSMutableArray
        sortBars(bars)
        
        var townNames = ["", "", ""]

        for index in 0...2 {
            var curBar = bars[index] as! BarAnnotation
            townNames[index] = curBar.town
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
    
    func setCellHeightArray(){
        var currentBar = BarAnnotation(latitude: 0, longitude: 0, name: "", deal: "")
        var townArr = orderOfTowns()
        
        for town in townArr{
            var arr = returnArray(town as! NSString)
            for bar in arr{
                currentBar = bar as! BarAnnotation
                var height = currentBar.cellHeight
                if(town as! NSString == "Ames"){
                    amesCellHeights.addObject(height)
                }
                else if(town as! NSString == "Cedar Falls"){
                    cfCellHeights.addObject(height)
                }
                else {
                    icCellHeights.addObject(height)
                }
            }
        }
    }
 
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = DealCell()
        
        if(barView){
            cell = tableView.dequeueReusableCellWithIdentifier("Deal Cell", forIndexPath: indexPath) as! DealCell
            
            var currentBar = BarAnnotation(latitude: 0, longitude: 0, name: "", deal: "")
            var townArr = orderOfTowns()
            
            var town = townArr[indexPath.section] as! NSString
            var arr = returnArray(town)
            currentBar = arr[indexPath.row] as! BarAnnotation
            
            cell.barName.text = currentBar.name
            cell.deal.text = currentBar.deal
            cell.distanceToBar.text = String(format: "%.3f mi", currentBar.distance)
            

            // Change colors based on theme
            switch(theme){
                case 0: // Default
                    break;
                case 1: // Ames
                    cell.barName.textColor = primary
                    cell.deal.textColor = primary
                    cell.distanceToBar.textColor = secondary
                    cell.backgroundColor = colors.white
                    break;
                case 2: // Iowa City
                    cell.barName.textColor = secondary
                    cell.deal.textColor = secondary
                    cell.distanceToBar.textColor = secondary
                    cell.backgroundColor = primary
                    break;
                case 3: // Cedar Falls
                    cell.barName.textColor = primary
                    cell.deal.textColor = primary
                    cell.distanceToBar.textColor = secondary
                    break;
                default:
                    break;
            }
            
            
            var len = CGFloat(cell.deal.text!.componentsSeparatedByCharactersInSet(NSCharacterSet.newlineCharacterSet()).count - 1)
            
            return cell
        }
        else{
            var cell2 = tableView.dequeueReusableCellWithIdentifier("Deal Cell 2", forIndexPath: indexPath) as! DealCell
            
            var townArr = orderOfTowns()
            var town = townArr[indexPath.section] as! NSString
            
            
            if (town == "Ames"){
                cell2.barName.text = amesDeals[indexPath.row].deal
                cell2.deal.text = amesDeals[indexPath.row].bar
            }
            else if (town == "Cedar Falls"){
                cell2.barName.text = cedarFallsDeals[indexPath.row].deal
                cell2.deal.text = cedarFallsDeals[indexPath.row].bar
            }
            else {
                cell2.barName.text = iowaCityDeals[indexPath.row].deal
                cell2.deal.text = iowaCityDeals[indexPath.row].bar
            }
            
            cell2.distanceToBar.text = ""
            
            // Change colors based on theme
            switch(theme){
                case 0: // Default
                    break;
                case 1: // Ames
                    cell2.barName.textColor = primary
                    cell2.deal.textColor = primary
                    cell2.backgroundColor = colors.white
                    break;
                case 2: // Iowa City
                    cell2.barName.textColor = secondary
                    cell2.deal.textColor = secondary
                    cell2.backgroundColor = primary
                    break;
                case 3: // Cedar Falls
                    cell2.barName.textColor = primary
                    cell2.deal.textColor = primary
                    break;
                default:
                    break;
            }
            
            return cell2;
        }
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if(barView){
            
            var townArr = orderOfTowns()
            var town = townArr[indexPath.section] as! NSString
            
            if (town == "Ames"){
                return amesCellHeights[indexPath.row] as! CGFloat
            }
            else if (town == "Cedar Falls"){
                return cfCellHeights[indexPath.row] as! CGFloat
            }
            else {
                return icCellHeights[indexPath.row] as! CGFloat
            }

        }
        else{
            return 50.0
        }
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if(barView){
            
            var townArr = orderOfTowns()
            var town = townArr[indexPath.section] as! NSString
            
            if (town == "Ames"){
                return amesCellHeights[indexPath.row] as! CGFloat
            }
            else if (town == "Cedar Falls"){
                return cfCellHeights[indexPath.row] as! CGFloat
            }
            else {
                return icCellHeights[indexPath.row] as! CGFloat
            }
        }
        else{
            return 50.0
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var townArr = orderOfTowns()
        var town = townArr[section] as! NSString
        
        if(barView){
            var arr = returnArray(town)
            return arr.count
        }
        else{
            if (town == "Ames"){
                return amesDeals.count
            }
            else if (town == "Cedar Falls"){
                return cedarFallsDeals.count
            }
            else {
                return iowaCityDeals.count
            }
        }
    }

    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        var sectionHeaderView = UIView(frame: CGRectMake(0, 0, tableView.frame.size.width, 25.0))
        var headerLabel = UILabel(frame: CGRectMake(16, 0, sectionHeaderView.frame.size.width, 25.0))
        headerLabel.backgroundColor = UIColor.clearColor()
        
        // Change colors based on theme
        if(theme == 2){
            sectionHeaderView.backgroundColor = colors.darkGray
            headerLabel.textColor = colors.yellow2
        }
        else{
            sectionHeaderView.backgroundColor = colors.lightGray
            headerLabel.textColor = colors.darkGray
        }

        var townArr = orderOfTowns()
        var townString = townArr[section] as! NSString
        headerLabel.text = townString.uppercaseString
        
        headerLabel.textAlignment = NSTextAlignment.Left
        headerLabel.font = UIFont.systemFontOfSize(15.0)
    
        sectionHeaderView.addSubview(headerLabel)
        return sectionHeaderView
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if(barView){
            var cell = tableView.cellForRowAtIndexPath(indexPath) as! DealCell
            var name = cell.barName.text!
            detailName = name
        }
        else{
            var cell = tableView.cellForRowAtIndexPath(indexPath) as! DealCell
            var name = cell.deal.text!
            detailName = name
        }


        var arr = orderOfTowns()
        detailTown = arr[indexPath.section] as! String
        performSegueWithIdentifier("DetailFromList", sender: self)

    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "DetailFromList" {
            var BD = segue.destinationViewController as! BarDetail
            BD.detailName = detailName
            BD.detailTown = detailTown
            BD.amesArr = amesArr
            BD.icArr = icArr
            BD.cfArr = cfArr
            BD.theme = theme
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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

extension UIToolbar {
    
    func hideHairline() {
        let navigationBarImageView = hairlineImageViewInToolbar(self)
        navigationBarImageView!.hidden = true
    }
    
    func showHairline() {
        let navigationBarImageView = hairlineImageViewInToolbar(self)
        navigationBarImageView!.hidden = false
    }
    
    private func hairlineImageViewInToolbar(view: UIView) -> UIImageView? {
        if view.isKindOfClass(UIImageView) && view.bounds.height <= 1.0 {
            return (view as! UIImageView)
        }
        
        let subviews = (view.subviews as! [UIView])
        for subview: UIView in subviews {
            if let imageView: UIImageView = hairlineImageViewInToolbar(subview) {
                return imageView
            }
        }
        
        return nil
    }
    
}
