//
//  ClientLogin.swift
//  TabSaver
//
//  Created by Lee Robinson on 4/28/15.
//  Copyright (c) 2015 Lee Robinson. All rights reserved.
//

import UIKit
import CoreData

class ClientLogin: UIViewController {

    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var rememberMeSwitch: UISwitch!
    @IBOutlet weak var loginButton: UIButton!
    var coreDataHelper = CoreDataHelper()
    var currentBar = ""
    var currentCity = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set up login button
        loginButton.backgroundColor = UIColor.clearColor()
        loginButton.layer.cornerRadius = 5
        loginButton.layer.borderWidth = 1
        loginButton.layer.borderColor = UIColor.blueColor().CGColor

        
        // Get user and pass if needed
        let arr = coreDataHelper.getUserPass() as NSMutableArray
        if(arr.count != 0){
            let toggle = arr.objectAtIndex(0) as! Bool
            rememberMeSwitch.setOn(toggle, animated: false)
            
            if(toggle){
                username.text = arr.objectAtIndex(1) as? String
                password.text = arr.objectAtIndex(2) as? String
            }
        }
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: self, action: nil)
    }
    
    @IBAction func loginPressed(sender: AnyObject) {
        
        if(username.text!.isEmpty || password.text!.isEmpty){
            
            let alert = UIAlertView()
            alert.title = "Please enter a username and password"
            alert.delegate = self
            alert.addButtonWithTitle("OK")
            alert.show()
            
        }
        else{
            
            // Attempt to login
            self.postLogin(username.text!, pass: password.text!, url: "http://tabsaver.info/login.php") { (succeeded: Bool) -> () in
         
                // Move to the UI thread
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                    if(succeeded){
                        self.coreDataHelper.saveUserPass(self.username.text!, pass: self.password.text!, rememberMe: self.rememberMeSwitch.on)
                        self.performSegueWithIdentifier("Login", sender: self)
                    }
                    else{
                        // Show the alert
                        let alert = UIAlertView()
                        alert.title = "Login Failed"
                        alert.message = "Invalid username/password"
                        alert.delegate = self
                        alert.addButtonWithTitle("Retry")
                        alert.show()
                    }
                })
            }
        }
    }
    
    func postLogin(user: String, pass: String, url : String, postCompleted : (succeeded: Bool) -> ()) {
        
//        var request = NSMutableURLRequest(URL: NSURL(string: url)!)
//        request.HTTPMethod = "POST"
//        let postString = "user=\(user)&pass=\(pass)"
//        var success = 0
//        
//        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
//        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
//            data, response, error in
//            
//            if error != nil {
//                let alert = UIAlertView()
//                alert.title = "Login Failed!"
//                alert.message = "Error: \(error)"
//                alert.delegate = self
//                alert.addButtonWithTitle("OK")
//                alert.show()
//                return
//            }
//            
//            let jsonData = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers , error: nil) as! NSDictionary
//            success = jsonData["Success"] as! Int
//            
//            if(success == 1){
//                self.currentBar = jsonData["Bar"] as! String
//                self.currentCity = jsonData["City"] as! String
//                postCompleted(succeeded: true)
//            }
//            else{
//                postCompleted(succeeded: false)
//            }
//            
//        }
//        
//        task.resume()
        
        postCompleted(succeeded: false)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "Login" {
            let CU = segue.destinationViewController as! ClientUpdate
            CU.currentBar = currentBar
            CU.currentCity = currentCity
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
