//
//  CreditTVCell.swift
//  Dreamio
//
//  Created by Bold Lion on 21.04.19.
//  Copyright © 2019 Bold Lion. All rights reserved.
//

import UIKit

class CreditTVCell: UITableViewCell {

    @IBOutlet weak var libraryName: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        libraryName.text = ""
    }
}
