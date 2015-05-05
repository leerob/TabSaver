//
//  CoreDataHelper.swift
//  TabSaver
//
//  Created by Lee Robinson on 5/4/15.
//  Copyright (c) 2015 Lee Robinson. All rights reserved.
//

import Foundation
import CoreData

let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
let managedContext = appDelegate.managedObjectContext!
var resultArr = [NSManagedObject]()
var error: NSError?

class CoreDataHelper{

    func saveInt(entityName: String, value: Int, key: String) {
        
        let entity =  NSEntityDescription.entityForName(entityName, inManagedObjectContext: managedContext)
        let object = NSManagedObject(entity: entity!, insertIntoManagedObjectContext:managedContext)
        
        object.setValue(value, forKey: key)
        
        var error: NSError?
        if !managedContext.save(&error)
        {
            println("Could not save \(error), \(error?.userInfo)")
        }
        
    }


    func saveString(entityName: String, value: String, key: String) {
        
        let entity =  NSEntityDescription.entityForName(entityName, inManagedObjectContext: managedContext)
        let object = NSManagedObject(entity: entity!, insertIntoManagedObjectContext:managedContext)
        
        object.setValue(value, forKey: key)
        
        var error: NSError?
        if !managedContext.save(&error)
        {
            println("Could not save \(error), \(error?.userInfo)")
        }
        
    }

    func getInt(entityName: String, key: String) -> Int {
        
        let fetchRequest = NSFetchRequest(entityName: entityName)
        let fetchedResults = managedContext.executeFetchRequest(fetchRequest, error: &error) as! [NSManagedObject]?
        
        if let results = fetchedResults
        {
            resultArr = results
        }
        else
        {
            println("Could not fetch \(error), \(error!.userInfo)")
        }
        
        if(resultArr.capacity  != 0){
            return resultArr[resultArr.count-1].valueForKey(key) as! Int
        }
        else{
            return 0
        }
    }

    func getString(entityName: String, key: String) -> String {

        let fetchRequest = NSFetchRequest(entityName: entityName)
        let fetchedResults = managedContext.executeFetchRequest(fetchRequest, error: &error) as! [NSManagedObject]?
        
        if let results = fetchedResults
        {
            resultArr = results
        }
        else
        {
            println("Could not fetch \(error), \(error!.userInfo)")
        }
        
        if(resultArr.capacity  != 0){
            return resultArr[resultArr.count-1].valueForKey(key) as! String
        }
        else{
            return ""
        }
    }
    
    func isFavorite(entityName: String, key: String, barName: String) -> Bool {

        let fetchRequest = NSFetchRequest(entityName: entityName)
        let fetchedResults = managedContext.executeFetchRequest(fetchRequest, error: &error) as! [NSManagedObject]?
        
        if let results = fetchedResults
        {
            resultArr = results
        }
        else
        {
            println("Could not fetch \(error), \(error!.userInfo)")
        }
        
        if(resultArr.capacity != 0){
            for val in resultArr{
                if (val.valueForKey(key) as! String == barName){
                    return true;
                }
            }
        }
        
        return false;
        
    }
    
    func deleteFavorite(entityName: String, key: String, barName: String) {

        let fetchRequest = NSFetchRequest(entityName: entityName)
        let fetchedResults = managedContext.executeFetchRequest(fetchRequest, error: &error) as! [NSManagedObject]?
        
        if let results = fetchedResults
        {
            resultArr = results
        }
        else
        {
            println("Could not fetch \(error), \(error!.userInfo)")
        }
        
        if(resultArr.capacity != 0){
            for val in resultArr{
                if (val.valueForKey(key) as! String == barName){
                    managedContext.deleteObject(val)
                }
            }
        }
        
    }
    
    func getFavoritesList(entityName: String, key: String) -> NSMutableArray {

        var favorites = [] as NSMutableArray
        let fetchRequest = NSFetchRequest(entityName: entityName)
        let fetchedResults = managedContext.executeFetchRequest(fetchRequest, error: &error) as! [NSManagedObject]?
        
        if let results = fetchedResults
        {
            resultArr = results
        }
        else
        {
            println("Could not fetch \(error), \(error!.userInfo)")
        }
        
        if(resultArr.capacity != 0){
            for(var i = 0; i < resultArr.count; i++){
                favorites.addObject(resultArr[i].valueForKey(key) as! String)
            }
        }
        else{
            favorites[0] = "No Favorites"
        }
        
        return favorites
        
    }
    
    func saveUserPass(name: String, pass: String, rememberMe: Bool) {
        
        let entity =  NSEntityDescription.entityForName("User", inManagedObjectContext: managedContext)
        let userObj = NSManagedObject(entity: entity!, insertIntoManagedObjectContext:managedContext)
        
        userObj.setValue(name, forKey: "username")
        userObj.setValue(pass, forKey: "password")
        userObj.setValue(rememberMe, forKey: "rememberMe")
        
        var error: NSError?
        if !managedContext.save(&error)
        {
            println("Could not save \(error), \(error?.userInfo)")
        }
        
    }
    
    func getUserPass() -> NSMutableArray {
        
        var retArr = [] as NSMutableArray
        let fetchRequest = NSFetchRequest(entityName:"User")
        let fetchedResults = managedContext.executeFetchRequest(fetchRequest, error: &error) as! [NSManagedObject]?
        
        if let results = fetchedResults
        {
            resultArr = results
        }
        else
        {
            println("Could not fetch \(error), \(error!.userInfo)")
        }
        
        if(resultArr.capacity  != 0){

            retArr.addObject(resultArr[resultArr.count-1].valueForKey("rememberMe") as! Bool)
            retArr.addObject(resultArr[resultArr.count-1].valueForKey("username") as! String)
            retArr.addObject(resultArr[resultArr.count-1].valueForKey("password") as! String)
        }
        
        return retArr
        
    }

}