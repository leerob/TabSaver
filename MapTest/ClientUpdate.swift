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
    

    let pickerData = ["Select Day", "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    var currentDay = ""
    var currentCity = "ames" // Need to get these from login
    var currentBar = "Tip Top Lounge" // Need to get these from login
    
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.delegate = self
        picker.dataSource = self
        
        var doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: self, action: "doneEditing")
        self.navigationItem.leftBarButtonItem = doneButton
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    

    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return pickerData[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        currentDay = pickerData[row]
    }

    @IBAction func saveDeals(sender: AnyObject) {
        
        // No Deal Entered
        if(firstDeal.text == ""){
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
        // Make POST request
        else{
            let request = NSMutableURLRequest(URL: NSURL(string: "http://tabsaver.info/processChange.php")!)
            request.HTTPMethod = "POST"
            var postString = "day=\(currentDay)&deal1=\(firstDeal.text)&city=\(currentCity)&bar=\(currentBar)"
            if(secondDeal.text != ""){
                postString += "&deal2=\(secondDeal.text)"
            }
            if(thirdDeal.text != ""){
                postString += "&deal3=\(thirdDeal.text)"
            }
            if(fourthDeal.text != ""){
                postString += "&deal4=\(fourthDeal.text)"
            }
            if(fifthDeal.text != ""){
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
                
                println("response = \(response)")
                let responseString = NSString(data: data, encoding: NSUTF8StringEncoding)
                println("responseString = \(responseString)")
                
                
            }
            
            task.resume()
            
            // Success
            let alert = UIAlertView()
            alert.title = "Update Successful!"
            alert.delegate = self
            alert.addButtonWithTitle("OK")
            alert.show()
        }
        
        if(pushSwitch.on){
            sendPushNotification(pushDeal.text)
        }

    }

    
    func sendPushNotification(pushStr: String){
        
        let pushQuery:PFQuery = PFInstallation.query()!
        pushQuery.whereKey("deviceType", equalTo:"ios")
        
        // Send push notification to query
        let pushNotification:PFPush = PFPush()
        pushNotification.setQuery(pushQuery)
        pushNotification.setData([
            "alert": pushStr,
            "badge" : "Increment"
            ])
        pushNotification.sendPushInBackgroundWithBlock({ (succeeded,e) -> Void in
            
            if succeeded {
                println("Push message to query in background succeeded")
            }
            if let error = e {
                println("Error:  (error.localizedDescription)")
            }
        })
    }
    
    func doneEditing(){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
