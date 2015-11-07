//
//  Analytics.swift
//  TabSaver
//
//  Created by Lee Robinson on 7/19/15.
//  Copyright (c) 2015 Lee Robinson. All rights reserved.
//

import Foundation
import Parse

class Analytics {
    
    func clicked(name: String) {
        log("Selected", secondary: name)
//        let query = PFQuery(className: "Analytics")
//        query.whereKey("name", equalTo: name)
//        findAsync(query).continueWithSuccessBlock {
//            (task: BFTask!) -> AnyObject! in
//            
//            let arr = task.result as! NSArray
//
//            let obj = arr[0] as! PFObject
//            obj.incrementKey("clicks")
//            obj.saveInBackgroundWithBlock {
//                (success: Bool, error: NSError?) -> Void in
//                if (success) {
//                    // The object has been saved.
//                } else {
//                    // There was a problem, check error.description
//                }
//            }
//            return nil
//            
//        }
    }
    
    func barClicked(name: String, key: String) {
        log(name, secondary: key)
//        let query = PFQuery(className: "BarAnalytics")
//        query.whereKey("name", equalTo: name)
//        findAsync(query).continueWithSuccessBlock {
//            (task: BFTask!) -> AnyObject! in
//            
//            let arr = task.result as! NSArray
//            
//            let obj = arr[0] as! PFObject
//            obj.incrementKey(key)
//            obj.saveInBackgroundWithBlock {
//                (success: Bool, error: NSError?) -> Void in
//                if (success) {
//                    // The object has been saved.
//                } else {
//                    // There was a problem, check error.description
//                }
//            }
//            return nil
//            
//        }
    }
    
    func log(action: String, secondary: String) {

        let log = PFObject(className: "LogsDev")
        log["action"] = action
        log["secondaryAction"] = secondary
        log["deviceType"] = "iPhone"
        log.saveInBackgroundWithBlock {
            (success: Bool, error: NSError?) -> Void in
            if (success) {
                // The object has been saved.
            } else {
                // There was a problem, check error.description
            }
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
    
}