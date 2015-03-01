//
//  SegControl.swift
//  TabSaver
//
//  Created by Lee Robinson on 1/30/15.
//  Copyright (c) 2015 Lee Robinson. All rights reserved.
//

import UIKit

class SegControl: UISegmentedControl {

    var current = 0
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        current = self.selectedSegmentIndex
        super.touchesBegan(touches, withEvent: event)
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        super.touchesEnded(touches, withEvent: event)
        
        if (current == self.selectedSegmentIndex){
            self.sendActionsForControlEvents(UIControlEvents.ValueChanged)
        }
    }

}