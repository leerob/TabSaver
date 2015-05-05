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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loginButton.backgroundColor = UIColor.clearColor()
        loginButton.layer.cornerRadius = 5
        loginButton.layer.borderWidth = 1
        loginButton.layer.borderColor = UIColor.blueColor().CGColor

        
        // Get user and pass if needed
        var arr = coreDataHelper.getUserPass() as NSMutableArray
        var toggle = arr.objectAtIndex(0) as! Bool
        rememberMeSwitch.setOn(toggle, animated: false)
        
        if(toggle){
            username.text = arr.objectAtIndex(1) as! String
            password.text = arr.objectAtIndex(2) as! String
        }
    }
    
    @IBAction func loginPressed(sender: AnyObject) {
        
        if(username.text != "" || password.text != ""){
            
            let request = NSMutableURLRequest(URL: NSURL(string: "http://tabsaver.info/login.php")!)
            request.HTTPMethod = "POST"
            var postString = "user=\(username.text)&pass=\(password.text)"
            var success = 0
            
            request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
            let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
                data, response, error in
                
                if error != nil {
                    let alert = UIAlertView()
                    alert.title = "Login Failed!"
                    alert.message = "Error: \(error)"
                    alert.delegate = self
                    alert.addButtonWithTitle("OK")
                    alert.show()
                    return
                }
                
                println("response = \(response)")
                let responseString = NSString(data: data, encoding: NSUTF8StringEncoding) as! String
                println("responseString = \(responseString)")
                
                let jsonData = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers , error: nil) as! NSDictionary
                success = jsonData["Success"] as! Int
                
//                if(success == 1){
//                    self.login()
//                }
//                else{
//                    let alert = UIAlertView()
//                    alert.title = "Login Failed"
//                    alert.message = "Invalid username/password"
//                    alert.delegate = self
//                    alert.addButtonWithTitle("Retry")
//                    alert.show()
//                }
            
            }
            
            coreDataHelper.saveUserPass(username.text, pass: password.text, rememberMe: rememberMeSwitch.on)
            performSegueWithIdentifier("Login", sender: self)
            
            task.resume()
            
        }
        else{
            // Nothing entered
            let alert = UIAlertView()
            alert.title = "Please enter a username and password"
            alert.delegate = self
            alert.addButtonWithTitle("OK")
            alert.show()
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "Login" {
            var BD = segue.destinationViewController as! ClientUpdate
            //BD.detailName = detailName
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
