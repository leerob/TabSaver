//
//  AppDelegate.swift
//  TabSaver
//
//  Created by Lee Robinson on 12/5/14.
//  Copyright (c) 2014 Lee Robinson. All rights reserved.
//

import UIKit
import CoreData
import Parse


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var analytics = Analytics()

    private var _shortcutItem: AnyObject?
    @available(iOS 9.0, *)
    var shortcutItem: UIApplicationShortcutItem? {
        get {
            return _shortcutItem as? UIApplicationShortcutItem
        }
        set {
            _shortcutItem = newValue
        }
    }

    override class func initialize(){
        //Armchair.appID("958415829")
        //Armchair.debugEnabled(true)
        //Armchair.significantEventsUntilPrompt(1)
    }

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        Parse.setApplicationId("mZ1wJCdlDowI28IzRpZ9ycIFkm0TXUYA33EoC3n8",
            clientKey: "4TaNynj1NN0UDlXMP3iQQb6WGAAE5Gp9IOBcVMkW")
        
        // Register for Push Notitications, if running iOS 8
        if application.respondsToSelector("registerUserNotificationSettings:") {
            
            let types:UIUserNotificationType = ([.Alert, .Badge, .Sound])
            let settings:UIUserNotificationSettings = UIUserNotificationSettings(forTypes: types, categories: nil)
            
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
            
        }

        // Set segmented control font
        let attr = NSDictionary(object: UIFont(name: "San Francisco Display", size: 12.0)!, forKey: NSFontAttributeName)
        UISegmentedControl.appearance().setTitleTextAttributes(attr as? [NSObject : AnyObject], forState: .Normal)
        
        
        print("Application did finish launching with options")

        var performShortcutDelegate = true

        if #available(iOS 9.0, *) {
            if let shortcutItem = launchOptions?[UIApplicationLaunchOptionsShortcutItemKey] as? UIApplicationShortcutItem {
    
                print("Application launched via shortcut")
                self.shortcutItem = shortcutItem
    
                performShortcutDelegate = false
            }
        } else {
            // Fallback on earlier versions
        }

        return performShortcutDelegate

    }

    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        print("didRegisterForRemoteNotificationsWithDeviceToken")
        
        let currentInstallation = PFInstallation.currentInstallation()
        
        currentInstallation.setDeviceTokenFromData(deviceToken)
        currentInstallation.saveInBackgroundWithBlock { (succeeded, e) -> Void in
            //code
        }
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        print("failed to register for remote notifications:  (error)")
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        print("didReceiveRemoteNotification")
        PFPush.handlePush(userInfo)
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        let currentInstallation = PFInstallation.currentInstallation()
        
        if currentInstallation.badge != 0 {
            currentInstallation.badge = 0
            currentInstallation.saveEventually({ (succeeded,e) -> Void in
                
                if succeeded {
                    print("Cleared badge")
                }
                if let error = e {
                    print("Error:  \(error.localizedDescription)")
                }
            })
        }
        
        print("Application did become active")
        
        if #available(iOS 9.0, *) {
            guard let shortcut = shortcutItem else { return }
            
            print("- Shortcut property has been set")
            
            handleShortcut(shortcut)
            
            self.shortcutItem = nil
            
        } else {
            // Fallback on earlier versions
        }
    }
    
    @available(iOS 9.0, *)
    func handleShortcut( shortcutItem:UIApplicationShortcutItem ) -> Bool {

        var succeeded = false
        let root  = self.window!.rootViewController! as! UINavigationController
        let dailyDealsController = root.topViewController as! DailyDeals

        if shortcutItem.type == "com.tabsaver.calltaxi" {
            analytics.clicked("Call Taxi Shortcut")
            dailyDealsController.shortcutItem = "Call Taxi"
            succeeded = true
        } else if shortcutItem.type == "com.tabsaver.location" {
            analytics.clicked("Current Location Shortcut")
            dailyDealsController.shortcutItem = "Current Location"
            succeeded = true
        } else if shortcutItem.type == "com.tabsaver.closestbar" {
            analytics.clicked("Closest Bar Shortcut")
            dailyDealsController.shortcutItem = "Closest Bar"
            succeeded = true
        }

        return succeeded
    }
    
    @available(iOS 9.0, *)
    func application(application: UIApplication, performActionForShortcutItem shortcutItem: UIApplicationShortcutItem, completionHandler: (Bool) -> Void) {
        
        analytics.log("Error: 3D Touch Shortcut", secondary: "Tried to use while app was open")
        completionHandler( handleShortcut(shortcutItem) )
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack
    
    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.xxxx.ProjectName" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1] 
        }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("dataModel", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
        }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("MapTest.sqlite")
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch var error1 as NSError {
            error = error1
            coordinator = nil
            // Report any error we got.
            let dict = NSMutableDictionary()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            dict[NSUnderlyingErrorKey] = error
            NSLog("Unresolved error \(dict)")
            abort()
        } catch {
            fatalError()
        }
        
        return coordinator
        }()
    
    lazy var managedObjectContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
        }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        if let moc = self.managedObjectContext {
            var error: NSError? = nil
            if moc.hasChanges {
                do {
                    try moc.save()
                } catch let error1 as NSError {
                    error = error1
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    NSLog("Unresolved error \(error), \(error!.userInfo)")
                    abort()
                }
            }
        }
    }

}

