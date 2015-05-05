//
//  Settings.swift
//  TabSaver
//
//  Created by Lee Robinson on 4/14/15.
//  Copyright (c) 2015 Lee Robinson. All rights reserved.
//

import UIKit
import Armchair

class Settings: UITableViewController {

    @IBOutlet var table: UITableView!
    @IBOutlet weak var defaultCheck: UIImageView!
    @IBOutlet weak var cyclonesCheck: UIImageView!
    @IBOutlet weak var hawkeyesCheck: UIImageView!
    @IBOutlet weak var panthersCheck: UIImageView!
    @IBOutlet weak var barSwitch: UISwitch!
    var theme = 0
    var coreDataHelper = CoreDataHelper()
    
    
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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func closeSettings(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch(indexPath.section){
            case 0:
                // THEMES //
                switch(indexPath.row){
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
            case 1:
                switch(indexPath.row){
                    case 0: // Show Closed Bars
                        if(barSwitch.on){
                            barSwitch.setOn(false, animated: true)
                        }
                        else{
                            barSwitch.setOn(true, animated: true)
                        }
                        break;
                    case 1: // Show Bars With No Deals
                        if(barSwitch.on){
                            barSwitch.setOn(false, animated: true)
                        }
                        else{
                            barSwitch.setOn(true, animated: true)
                        }
                        break;
                    case 2: // Show Favorite Bars
                        if(barSwitch.on){
                            barSwitch.setOn(false, animated: true)
                        }
                        else{
                            barSwitch.setOn(true, animated: true)
                        }
                        break;
                    case 3: // Manage Favorite Bars
                        // Go to tableview
                        break;
                    case 4: // Toggle Location Services
                        // i0S 8 Check
                        switch UIDevice.currentDevice().systemVersion.compare("8.0.0", options: NSStringCompareOptions.NumericSearch) {
                            case .OrderedSame, .OrderedDescending:
                                var settingsApp = NSURL(string: UIApplicationOpenSettingsURLString)
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
            case 2:
                switch(indexPath.row){
                    case 1: // Contact Us
                        var url:NSURL = NSURL(string: "http://www.tabsaverapp.com")!
                        UIApplication.sharedApplication().openURL(url)
                        break;
                    case 2: // Rate TabSaver
                        Armchair.userDidSignificantEvent(true)
                        break;
                    default:
                        break;
                }
                break;
            default:
                break;
        }

        table.deselectRowAtIndexPath(indexPath, animated: true)
    }

    func toggleChecks(pressedCheck: String){
        
        if(pressedCheck == "Default"){
            defaultCheck.hidden = false
            cyclonesCheck.hidden = true
            hawkeyesCheck.hidden = true
            panthersCheck.hidden = true
        }
        else if(pressedCheck == "Cyclones"){
            defaultCheck.hidden = true
            cyclonesCheck.hidden = false
            hawkeyesCheck.hidden = true
            panthersCheck.hidden = true
        }
        else if(pressedCheck == "Hawkeyes"){
            defaultCheck.hidden = true
            cyclonesCheck.hidden = true
            hawkeyesCheck.hidden = false
            panthersCheck.hidden = true
        }
        else{
            defaultCheck.hidden = true
            cyclonesCheck.hidden = true
            hawkeyesCheck.hidden = true
            panthersCheck.hidden = false
            
        }
    }

}
