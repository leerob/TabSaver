//
//  DealCell.swift
//  TabSaver
//
//  Created by Lee Robinson on 12/7/14.
//  Copyright (c) 2014 Lee Robinson. All rights reserved.
//

import UIKit

class DealCell: UITableViewCell {

    @IBOutlet weak var barName: UILabel!
    @IBOutlet weak var deal: UILabel!
    @IBOutlet weak var distanceToBar: UILabel!
    @IBOutlet weak var barImage: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
