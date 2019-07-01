//
//  LabelTVCellTableViewCell.swift
//  Dreamio
//
//  Created by Bold Lion on 25.04.19.
//  Copyright © 2019 Bold Lion. All rights reserved.
//

import UIKit

class LabelTVC: UITableViewCell {

    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var postNumber: UILabel!

    override func prepareForReuse() {
        super.prepareForReuse()
        numberLabel.text = ""
        label.text = ""
        postNumber.text = ""
    }

}

