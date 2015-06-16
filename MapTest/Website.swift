//
//  Website.swift
//  TabSaver
//
//  Created by Lee Robinson on 3/8/15.
//  Copyright (c) 2015 Lee Robinson. All rights reserved.
//

import UIKit

class Website: UIViewController, UIActionSheetDelegate {

    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var toolBar: UINavigationBar!
    @IBOutlet weak var navItem: UINavigationItem!
    var website = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Load website
        let url = NSURL (string: website);
        let requestObj = NSURLRequest(URL: url!);
        webView.loadRequest(requestObj);
        
        navItem.title = website
        toolBar.translucent = false
    }

    @IBAction func closeWebsite(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func showOptions(sender: AnyObject) {
        // Create action sheet
        let actionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: nil, destructiveButtonTitle: nil)
        actionSheet.addButtonWithTitle("Copy Link")
        actionSheet.addButtonWithTitle("Open in Safari")
        actionSheet.addButtonWithTitle("Cancel")
        actionSheet.cancelButtonIndex = 2
        actionSheet.showInView(self.view)
        
    }
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int)
    {
        switch buttonIndex{
            // Copy to clipboard
            case 0:
                UIPasteboard.generalPasteboard().string = self.website
                break;
            // Open in safari
            case 1:
                var url:NSURL = NSURL(string: self.website)!
                UIApplication.sharedApplication().openURL(url)
                break;
            default:
                break;
        }
    }
}