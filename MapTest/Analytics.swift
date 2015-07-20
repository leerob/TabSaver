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
     
        var query = PFQuery(className: "Analytics")
        query.whereKey("name", equalTo: name)
        findAsync(query).continueWithSuccessBlock {
            (task: BFTask!) -> AnyObject! in
            
            let arr = task.result as! NSArray

            let obj = arr[0] as! PFObject
            obj.incrementKey("clicks")
            obj.saveInBackgroundWithBlock {
                (success: Bool, error: NSError?) -> Void in
                if (success) {
                    // The object has been saved.
                } else {
                    // There was a problem, check error.description
                }
            }
            return nil
            
        }
    }
    
    func barClicked(name: String, key: String) {
        
        var query = PFQuery(className: "BarAnalytics")
        query.whereKey("name", equalTo: name)
        findAsync(query).continueWithSuccessBlock {
            (task: BFTask!) -> AnyObject! in
            
            let arr = task.result as! NSArray
            
            let obj = arr[0] as! PFObject
            obj.incrementKey(key)
            obj.saveInBackgroundWithBlock {
                (success: Bool, error: NSError?) -> Void in
                if (success) {
                    // The object has been saved.
                } else {
                    // There was a problem, check error.description
                }
            }
            return nil
            
        }
    }

    func findAsync(query:PFQuery) -> BFTask {
        var task = BFTaskCompletionSource()
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