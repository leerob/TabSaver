//
//  FavoritesList.swift
//  TabSaver
//
//  Created by Lee Robinson on 4/14/15.
//  Copyright (c) 2015 Lee Robinson. All rights reserved.
//

import UIKit
import CoreData

class FavoritesList: UITableViewController {

    var favorites = [] as NSMutableArray
    var coreDataHelper = CoreDataHelper()
   
    override func viewDidLoad() {
        super.viewDidLoad()
        favorites = coreDataHelper.getFavoritesList("Favorites", key: "list")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favorites.count
    }
   
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) 
        cell.textLabel?.text = favorites.objectAtIndex(indexPath.row) as? String
        return cell
    }

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ""
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        // Delete the row from the data source and core data
        if editingStyle == .Delete {
            coreDataHelper.deleteFavorite("Favorites", key: "list", barName: favorites.objectAtIndex(indexPath.row) as! String)
            favorites.removeObjectAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }
}