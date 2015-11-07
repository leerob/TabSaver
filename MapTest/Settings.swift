//
//  Settings.swift
//  TabSaver
//
//  Created by Lee Robinson on 4/14/15.
//  Copyright (c) 2015 Lee Robinson. All rights reserved.
//

import UIKit
import MessageUI
import Parse


protocol SettingsDelegate {
    func selectLocation(lat: Double, long: Double)
    func updateLocation(location: String)
}

class Settings: UITableViewController, MFMailComposeViewControllerDelegate {

    @IBOutlet var table: UITableView!
    @IBOutlet weak var amesCheck: UIImageView!
    @IBOutlet weak var icCheck: UIImageView!
    @IBOutlet weak var cfCheck: UIImageView!
    @IBOutlet weak var dsmCheck: UIImageView!
    @IBOutlet weak var moCheck: UIImageView!
    @IBOutlet weak var tmCheck: UIImageView!
    @IBOutlet weak var defaultCheck: UIImageView!
    @IBOutlet weak var cyclonesCheck: UIImageView!
    @IBOutlet weak var hawkeyesCheck: UIImageView!
    @IBOutlet weak var panthersCheck: UIImageView!
    @IBOutlet weak var barSwitch: UISwitch!
    @IBOutlet weak var noDealsSwitch: UISwitch!
    @IBOutlet weak var favsSwitch: UISwitch!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    var theme = 0
    var coreDataHelper = CoreDataHelper()
    var analytics = Analytics()
    var delegate: SettingsDelegate? = nil
    var cellExpanded = false
    var initialLocation = ""
    var taxiNumber = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getTaxiService()
        toggleLoactionChecks(initialLocation)
        theme = coreDataHelper.getInt("Theme", key: "themeNumber")
        switch(theme){
            case 0:
                toggleChecks("Default")
                break;
            case 1:
                toggleChecks("Cyclones")
                break;
            case 2:
                toggleChecks("Hawkeyes")
                break;
            case 3:
                toggleChecks("Panthers")
                break;
            default:
                toggleChecks("Default")
                break;
        }
        
        if(coreDataHelper.getInt("ShowClosed", key: "show") == 1) {
            barSwitch.setOn(false, animated: false)
        }
        
        if(coreDataHelper.getInt("ShowNo", key: "show") == 1) {
            noDealsSwitch.setOn(false, animated: false)
        }
        
        if(coreDataHelper.getInt("ShowFav", key: "show") == 1) {
            favsSwitch.setOn(false, animated: false)
        }
        
        // Create switch handlers
        barSwitch.addTarget(self, action: Selector("showClosedBars:"), forControlEvents: UIControlEvents.ValueChanged)
        noDealsSwitch.addTarget(self, action: Selector("showNoDealsBars:"), forControlEvents: UIControlEvents.ValueChanged)
        favsSwitch.addTarget(self, action: Selector("showFavoriteBars:"), forControlEvents: UIControlEvents.ValueChanged)
        
        navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "San Francisco Display", size: 16)!]
        doneButton.setTitleTextAttributes([ NSFontAttributeName: UIFont(name: "San Francisco Display", size: 16)!], forState: UIControlState.Normal)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: self, action: nil)
    }
    
    func showClosedBars(switchState: UISwitch) {
        
        if switchState.on {
            coreDataHelper.saveInt("ShowClosed", value: 0, key: "show")
        } else {
            coreDataHelper.saveInt("ShowClosed", value: 1, key: "show")
        }
    }
    
    func showNoDealsBars(switchState: UISwitch) {
        
        if switchState.on {
            coreDataHelper.saveInt("ShowNo", value: 0, key: "show")
        } else {
            coreDataHelper.saveInt("ShowNo", value: 1, key: "show")
        }
    }
    
    func showFavoriteBars(switchState: UISwitch) {
        
        if switchState.on {
            coreDataHelper.saveInt("ShowFav", value: 0, key: "show")
        } else {
            coreDataHelper.saveInt("ShowFav", value: 1, key: "show")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func closeSettings(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.section {
            case 0:
                
                // LOCATIONS //
                switch indexPath.row {
                    case 0: // Ames
                        toggleLoactionChecks("Ames")
                        self.delegate?.updateLocation("Ames")
                        self.delegate?.selectLocation(42.035021, long: -93.645)
                        analytics.clicked("Ames")
                        break;
                    case 1: // Iowa City
                        toggleLoactionChecks("Iowa City")
                        self.delegate?.updateLocation("Iowa City")
                        self.delegate?.selectLocation(41.656497, long: -91.535339)
                        analytics.clicked("Iowa City")
                        break;
                    case 2: // Cedar Falls
                        toggleLoactionChecks("Cedar Falls")
                        self.delegate?.updateLocation("Cedar Falls")
                        self.delegate?.selectLocation(42.520700, long: -92.438965)
                        analytics.clicked("Cedar Falls")
                        break;
                    case 3: // Des Moines
                        toggleLoactionChecks("Des Moines")
                        self.delegate?.updateLocation("Des Moines")
                        self.delegate?.selectLocation(41.589883, long: -93.624183)
                        analytics.clicked("Des Moines")
                        break;
                    case 4: // Moline
                        toggleLoactionChecks("Moline")
                        self.delegate?.updateLocation("Moline")
                        self.delegate?.selectLocation(41.506582, long: -90.515497)
                        analytics.clicked("Moline")
                        break;
                    case 5: // Tempe
                        toggleLoactionChecks("Tempe")
                        self.delegate?.updateLocation("Tempe")
                        self.delegate?.selectLocation(33.424881, long: -111.939431)
                        analytics.clicked("Tempe")
                        break;
                    default:
                        self.delegate?.selectLocation(42.035021, long: -93.645)
                        break;
                }
                break;
            case 1:
                // THEMES //
                switch indexPath.row {
                    case 0: // Default Theme
                        toggleChecks("Default")
                        coreDataHelper.saveInt("Theme", value: 0, key: "themeNumber")
                        analytics.clicked("Default")
                        break;
                    case 1: // Cyclones Theme
                        toggleChecks("Cyclones")
                        coreDataHelper.saveInt("Theme", value: 1, key: "themeNumber")
                        analytics.clicked("Cyclones")
                        break;
                    case 2: // Hawkeyes Theme
                        toggleChecks("Hawkeyes")
                        coreDataHelper.saveInt("Theme", value: 2, key: "themeNumber")
                        analytics.clicked("Hawkeyes")
                        break;
                    case 3: // Panthers Theme
                        toggleChecks("Panthers")
                        coreDataHelper.saveInt("Theme", value: 3, key: "themeNumber")
                        analytics.clicked("Panthers")
                        break;
                    default:
                        break;
                }
                break;
            // GENERAL //
            case 2:
                switch indexPath.row {
                    case 0: // Show Closed Bars
                        if barSwitch.on {
                            barSwitch.setOn(false, animated: true)
                            coreDataHelper.saveInt("ShowClosed", value: 1, key: "show")
                        }
                        else {
                            barSwitch.setOn(true, animated: true)
                            coreDataHelper.saveInt("ShowClosed", value: 0, key: "show")
                        }
                        analytics.clicked("Show Closed Bars")
                        break;
                    case 1: // Show Bars With No Deals
                        if noDealsSwitch.on {
                            noDealsSwitch.setOn(false, animated: true)
                            coreDataHelper.saveInt("ShowNo", value: 1, key: "show")
                        }
                        else {
                            noDealsSwitch.setOn(true, animated: true)
                            coreDataHelper.saveInt("ShowNo", value: 0, key: "show")
                        }
                        analytics.clicked("Show Bars With No Deals")
                        break;
                    case 2: // Show Favorite Bars
                        if favsSwitch.on {
                            favsSwitch.setOn(false, animated: true)
                            coreDataHelper.saveInt("ShowFav", value: 1, key: "show")
                        }
                        else{
                            favsSwitch.setOn(true, animated: true)
                            coreDataHelper.saveInt("ShowFav", value: 0, key: "show")
                        }
                        analytics.clicked("Show Favorites As Stars")
                        break;
                    case 3: // Manage Favorite Bars
                        analytics.clicked("Manage Favorite Bars")
                        break;
                    case 4: // Manage Permissions
                        let settingsApp = NSURL(string: UIApplicationOpenSettingsURLString)
                        UIApplication.sharedApplication().openURL(settingsApp!)
                        analytics.clicked("Manage Permissions")
                        break;
                    default:
                        break;
                }
                break;
            // SUPPORT //
            case 3:
                switch indexPath.row {
                    case 0: // Call Taxi
                        analytics.clicked("Call Taxi")
                        let url = NSURL(string: "tel://\(taxiNumber)")!
                        UIApplication.sharedApplication().openURL(url)
                        break
                    case 1: // Contact Us
                        // Create an email
                        let mailComposeViewController = configuredMailComposeViewController()
                        if MFMailComposeViewController.canSendMail() {
                            self.presentViewController(mailComposeViewController, animated: true, completion: nil)
                        } else {
                            self.showSendMailErrorAlert()
                        }
                        break
                    case 2: // Client Login
                        analytics.clicked("Client Login")
                        break
//                    case 3: // Rate TabSaver
//                        Armchair.userDidSignificantEvent(true)
//                        Armchair.showPrompt()
//                        break;
                    default:
                        break
                }
                break;
            default:
                break;
        }

        table.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func getTaxiService() {
        let query = PFQuery(className: "Locations")
        query.whereKey("cityName", equalTo: initialLocation)
        findAsync(query).continueWithSuccessBlock {
            (task: BFTask!) -> AnyObject! in

            let arr = task.result as! NSArray
            let city = arr[0] as! PFObject
            self.taxiNumber = city.valueForKey("taxiNumber") as! String
            
            return nil
        }
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
 
    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel!.textColor = UIColor.lightGrayColor()
        header.textLabel!.font = UIFont(name: ".HelveticaNeueDeskInterface-Regular", size: 14.0)
        
//        San Francisco Display
//        .HelveticaNeueDeskInterface-MediumP4
//        .HelveticaNeueDeskInterface-UltraLightP2
//        .HelveticaNeueDeskInterface-Regular
//        .HelveticaNeueDeskInterface-Thin
    }
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        mailComposerVC.setToRecipients(["leerob@iastate.edu"])
        mailComposerVC.setSubject("TabSaver")
   
        return mailComposerVC
    }
    
    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertView(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", delegate: self, cancelButtonTitle: "OK")
        sendMailErrorAlert.show()
    }
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }

    func toggleChecks(pressedCheck: String){
        
        if pressedCheck == "Default" {
            defaultCheck.hidden = false
            cyclonesCheck.hidden = true
            hawkeyesCheck.hidden = true
            panthersCheck.hidden = true
        }
        else if pressedCheck == "Cyclones" {
            defaultCheck.hidden = true
            cyclonesCheck.hidden = false
            hawkeyesCheck.hidden = true
            panthersCheck.hidden = true
        }
        else if pressedCheck == "Hawkeyes" {
            defaultCheck.hidden = true
            cyclonesCheck.hidden = true
            hawkeyesCheck.hidden = false
            panthersCheck.hidden = true
        }
        else {
            defaultCheck.hidden = true
            cyclonesCheck.hidden = true
            hawkeyesCheck.hidden = true
            panthersCheck.hidden = false
            
        }
    }
    
    func toggleLoactionChecks(pressedCheck: String){
        
        let installObj = PFInstallation.currentInstallation()
        installObj.setValue(pressedCheck, forKey: "location")
        installObj.saveInBackground()
        
        if pressedCheck == "Ames" {
            amesCheck.hidden = false
            icCheck.hidden = true
            cfCheck.hidden = true
            dsmCheck.hidden = true
            moCheck.hidden = true
            tmCheck.hidden = true
        }
        else if pressedCheck == "Iowa City" {
            amesCheck.hidden = true
            icCheck.hidden = false
            cfCheck.hidden = true
            dsmCheck.hidden = true
            moCheck.hidden = true
            tmCheck.hidden = true
        }
        else if pressedCheck == "Cedar Falls" {
            amesCheck.hidden = true
            icCheck.hidden = true
            cfCheck.hidden = false
            dsmCheck.hidden = true
            moCheck.hidden = true
            tmCheck.hidden = true
        }
        else if pressedCheck == "Moline" {
            amesCheck.hidden = true
            icCheck.hidden = true
            cfCheck.hidden = true
            dsmCheck.hidden = true
            moCheck.hidden = false
            tmCheck.hidden = true
        }
        else if pressedCheck == "Tempe" {
            amesCheck.hidden = true
            icCheck.hidden = true
            cfCheck.hidden = true
            dsmCheck.hidden = true
            moCheck.hidden = true
            tmCheck.hidden = false
        }
        else { // Des Moines
            amesCheck.hidden = true
            icCheck.hidden = true
            cfCheck.hidden = true
            dsmCheck.hidden = false
            moCheck.hidden = true
            tmCheck.hidden = true
        }
    }
}