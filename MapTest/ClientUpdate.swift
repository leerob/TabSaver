//
//  ClientUpdate.swift
//  TabSaver
//
//  Created by Lee Robinson on 4/28/15.
//  Copyright (c) 2015 Lee Robinson. All rights reserved.
//

import UIKit
import Parse

class ClientUpdate: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var firstDeal: UITextField!
    @IBOutlet weak var secondDeal: UITextField!
    @IBOutlet weak var thirdDeal: UITextField!
    @IBOutlet weak var fourthDeal: UITextField!
    @IBOutlet weak var fifthDeal: UITextField!
    @IBOutlet weak var pushDeal: UITextField!
    @IBOutlet weak var pushSwitch: UISwitch!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    

    let pickerData = ["Select Day", "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    var currentDay = ""
    var currentCity = ""
    var currentBar = ""
    var dealsArr = Array(count: 10, repeatedValue: "")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.delegate = self
        picker.dataSource = self
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: self, action: "doneEditing")
        doneButton.setTitleTextAttributes([ NSFontAttributeName: UIFont(name: "San Francisco Display", size: 16)!], forState: UIControlState.Normal)
        saveButton.setTitleTextAttributes([ NSFontAttributeName: UIFont(name: "San Francisco Display", size: 16)!], forState: UIControlState.Normal)
        self.navigationItem.leftBarButtonItem = doneButton
    }
    
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView {
        
        let pickerLabel = UILabel()
        let titleData = pickerData[row]
        let myTitle = NSAttributedString(string: titleData, attributes: [NSFontAttributeName:UIFont(name: "San Francisco Display", size: 18.0)!,NSForegroundColorAttributeName:UIColor.blackColor()])
        pickerLabel.attributedText = myTitle
        pickerLabel.textAlignment = .Center
        return pickerLabel
    }

    @IBAction func saveDeals(sender: AnyObject) {
        
        // No Deal Entered
        if(firstDeal.text!.isEmpty){
            let alert = UIAlertView()
            alert.title = "Deal Not Entered"
            alert.message = "Please enter at least one deal."
            alert.delegate = self
            alert.addButtonWithTitle("OK")
            alert.show()
        }
            
        // No Day Selected
        else if(pickerData[picker.selectedRowInComponent(0)] as String == "Select Day"){
            let alert = UIAlertView()
            alert.title = "Day Not Selected"
            alert.message = "Please select a day."
            alert.delegate = self
            alert.addButtonWithTitle("OK")
            alert.show()
        }
        
        else{
            
            // Update deals
            self.postUpdate("http://tabsaver.info/processChange.php") { (succeeded: Bool) -> () in
                
                // Move to the UI thread
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                    let alert = UIAlertView()
                    if(succeeded){
                        
                        if(self.pushSwitch.on){
                            self.sendPushNotification(self.pushDeal.text!)
                        }
                        
                        alert.title = "Update Successful!"
                        alert.delegate = self
                        alert.addButtonWithTitle("OK")
                        alert.show()
                    }
                    else{
                        alert.title = "Update Failed"
                        alert.message = "Please contact support"
                        alert.delegate = self
                        alert.addButtonWithTitle("OK")
                        alert.show()
                    }
                })
            }
        }
    }
    
    func postUpdate(url : String, postCompleted : (succeeded: Bool) -> ()) {
        
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        request.HTTPMethod = "POST"
        var success = 0
        
        var postString = "day=\(currentDay)&deal1=\(firstDeal.text)&city=\(currentCity)&bar=\(currentBar)"
        if(!secondDeal.text!.isEmpty){
            postString += "&deal2=\(secondDeal.text)"
        }
        if(!thirdDeal.text!.isEmpty){
            postString += "&deal3=\(thirdDeal.text)"
        }
        if(!fourthDeal.text!.isEmpty){
            postString += "&deal4=\(fourthDeal.text)"
        }
        if(!fifthDeal.text!.isEmpty){
            postString += "&deal5=\(fifthDeal.text)"
        }
        
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in
            
            if error != nil {
                let alert = UIAlertView()
                alert.title = "Update Failed!"
                alert.message = "Error: \(error)"
                alert.delegate = self
                alert.addButtonWithTitle("OK")
                alert.show()
                return
            }

            let jsonData = (try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers )) as! NSDictionary
            success = jsonData["Success"] as! Int
            
            if(success == 1){
                postCompleted(succeeded: true)
            }
            else{
                postCompleted(succeeded: false)
            }
            
        }        
        task.resume()
    }
    
    func getDealsForDay(day: String, url : String, postCompleted : (succeeded: Bool) -> ()) {
        
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        request.HTTPMethod = "POST"
        var success = 0
        
        let postString = "day=\(day)&city=\(currentCity)&bar=\(currentBar)"
        
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in
            
            if error != nil {
                let alert = UIAlertView()
                alert.title = "Update Failed!"
                alert.message = "Error: \(error)"
                alert.delegate = self
                alert.addButtonWithTitle("OK")
                alert.show()
                return
            }

            let jsonData = (try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers )) as! NSDictionary
            success = jsonData["Success"] as! Int
            
            if(success == 1){
                for index in 1...10 {
                    let deal = jsonData["\(index)"] as! String
                    self.dealsArr[index-1] = deal
                }

                postCompleted(succeeded: true)
            }
            else{
                postCompleted(succeeded: false)
            }
            
        }
        task.resume()
    }

    
    func sendPushNotification(pushStr: String){
        
        // Send push notification to bar's channel
        let push = PFPush()
        push.setChannel(formatBarName(currentBar))
        push.setData([
            "alert": pushStr,
            "badge" : "Increment"
            ])
        push.sendPushInBackgroundWithBlock({ (succeeded,e) -> Void in
            
            if let error = e {
                print("Error:  \(error.localizedDescription)")
            }
        })
    }
    
    
    func formatBarName(name: String) -> String {
        return name.replace(" ", withString: "").replace("'", withString: "").replace("!", withString: "").replace("&", withString: "")
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        currentDay = pickerData[row]
        
        // Load deals for the current day
        self.getDealsForDay(currentDay, url: "http://tabsaver.info/grabDealsForDay.php") { (succeeded: Bool) -> () in
            
            // Move to the UI thread
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                if(succeeded){
                    self.firstDeal.text = self.dealsArr[0] as String
                    self.secondDeal.text = self.dealsArr[1] as String
                    self.thirdDeal.text = self.dealsArr[2] as String
                    self.fourthDeal.text = self.dealsArr[3] as String
                    self.fifthDeal.text = self.dealsArr[4] as String
                }
                else{
                    let alert = UIAlertView()
                    alert.title = "Error"
                    alert.message = "Retrieving deals failed. There is an issue with your deal data. Contact support for more information."
                    alert.delegate = self
                    alert.addButtonWithTitle("OK")
                    alert.show()
                }
            })
        }
    }
    
    func doneEditing(){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
