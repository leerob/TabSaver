//
//  LocationCell.swift
//  MapTest
//
//  Created by Lee Robinson on 12/3/15.
//  Copyright © 2015 Lee Robinson. All rights reserved.
//

import UIKit

class LocationCell: UITableViewCell {
    
    @IBOutlet weak var cityName: UILabel!
    @IBOutlet weak var check: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setChecked(state: Bool) {
        check.hidden = !state
    }
}