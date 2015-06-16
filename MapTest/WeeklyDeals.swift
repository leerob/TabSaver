//
//  WeeklyDeals.swift
//  TabSaver
//
//  Created by Lee Robinson on 5/30/15.
//  Copyright (c) 2015 Lee Robinson. All rights reserved.
//

import UIKit

class WeeklyDeals: UITableViewController {

    // Static labels
    @IBOutlet weak var mondayLabel: UILabel!
    @IBOutlet weak var tuesdayLabel: UILabel!
    @IBOutlet weak var wednesdayLabel: UILabel!
    @IBOutlet weak var thursdayLabel: UILabel!
    @IBOutlet weak var fridayLabel: UILabel!
    @IBOutlet weak var saturdayLabel: UILabel!
    @IBOutlet weak var sundayLabel: UILabel!
    
    @IBOutlet weak var mondayDeals: UILabel!
    @IBOutlet weak var tuesdayDeals: UILabel!
    @IBOutlet weak var wednesdayDeals: UILabel!
    @IBOutlet weak var thursdayDeals: UILabel!
    @IBOutlet weak var fridayDeals: UILabel!
    @IBOutlet weak var saturdayDeals: UILabel!
    @IBOutlet weak var sundayDeals: UILabel!
    
    var sun = ""
    var mon = ""
    var tue = ""
    var wed = ""
    var thu = ""
    var fri = ""
    var sat = ""
    var primary = UIColor()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: self, action: nil)
        navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "San Francisco Display", size: 16)!]
        
        mondayDeals.text = mon
        tuesdayDeals.text = tue
        wednesdayDeals.text = wed
        thursdayDeals.text = thu
        fridayDeals.text = fri
        saturdayDeals.text = sat
        sundayDeals.text = sun
        
        mondayLabel.textColor = primary
        tuesdayLabel.textColor = primary
        wednesdayLabel.textColor = primary
        thursdayLabel.textColor = primary
        fridayLabel.textColor = primary
        saturdayLabel.textColor = primary
        sundayLabel.textColor = primary
        
        tableView.tableFooterView = UIView(frame:CGRectZero)
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
