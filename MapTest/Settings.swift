//
//  Settings.swift
//  TabSaver
//
//  Created by Lee Robinson on 4/14/15.
//  Copyright (c) 2015 Lee Robinson. All rights reserved.
//

import UIKit
import Armchair
import MessageUI


protocol SettingsDelegate {
    func selectLocation(lat: Double, long: Double)
}

class Settings: UITableViewController, MFMailComposeViewControllerDelegate {

    @IBOutlet var table: UITableView!
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
    var delegate: SettingsDelegate? = nil
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
                        self.delegate?.selectLocation(42.035021, long: -93.645) 
                        break;
                    case 1: // Iowa City
                        self.delegate?.selectLocation(41.656497, long: -91.535339)
                        break;
                    case 2: // Cedar Falls
                        self.delegate?.selectLocation(42.520700, long: -92.438965)
                        break;
                    case 3: // Cedar Rapids
                        self.delegate?.selectLocation(41.976115, long: -91.672977)
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
                        break;
                    case 1: // Cyclones Theme
                        toggleChecks("Cyclones")
                        coreDataHelper.saveInt("Theme", value: 1, key: "themeNumber")
                        break;
                    case 2: // Hawkeyes Theme
                        toggleChecks("Hawkeyes")
                        coreDataHelper.saveInt("Theme", value: 2, key: "themeNumber")
                        break;
                    case 3: // Panthers Theme
                        toggleChecks("Panthers")
                        coreDataHelper.saveInt("Theme", value: 3, key: "themeNumber")
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
                        break;
                    case 3: // Manage Favorite Bars
                        // Go to tableview
                        break;
                    case 4: // Manage Permissions
                        // i0S 8 Check
                        switch UIDevice.currentDevice().systemVersion.compare("8.0.0", options: NSStringCompareOptions.NumericSearch) {
                            case .OrderedSame, .OrderedDescending:
                                let settingsApp = NSURL(string: UIApplicationOpenSettingsURLString)
                                UIApplication.sharedApplication().openURL(settingsApp!)
                                break;
                            case .OrderedAscending:
                                let alert = UIAlertView()
                                alert.title = "Navigate To"
                                alert.message = "Settings/Privacy/Location/TabSaver"
                                alert.addButtonWithTitle("OK")
                                alert.show()
                                break;
                            default:
                                break;
                        }
                        break;
                    default:
                        break;
                }
                break;
            // SUPPORT //
            case 3:
                switch indexPath.row {
                    case 1: // Contact Us
                        // Create an email
                        let mailComposeViewController = configuredMailComposeViewController()
                        if MFMailComposeViewController.canSendMail() {
                            self.presentViewController(mailComposeViewController, animated: true, completion: nil)
                        } else {
                            self.showSendMailErrorAlert()
                        }
                        break;
//                    case 2: // Call Taxi
//                        
//                        // Determine closest company
//                        var num = 5154518769 // Fitz in Ames
//                        var num2 = 3192422011 // Dollys in CF
//                        var num3 = 3193378294 // Marcos in IC
//                        
//                        // Make the call
//                        var url:NSURL = NSURL(string: "tel://\(num)")!
//                        UIApplication.sharedApplication().openURL(url)
//                        break;
//                    case 3: // Rate TabSaver
//                        Armchair.userDidSignificantEvent(true)
//                        Armchair.showPrompt()
//                        break;
                    default:
                        break;
                }
                break;
            default:
                break;
        }

        table.deselectRowAtIndexPath(indexPath, animated: true)
    }
 
    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel.textColor = UIColor.lightGrayColor()
        header.textLabel.font = UIFont(name: ".HelveticaNeueDeskInterface-Regular", size: 14.0)
        
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
    
    func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
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
}