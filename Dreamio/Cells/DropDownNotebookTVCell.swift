//
//  DropDownNotebookTVCell.swift
//  Dreamio
//
//  Created by Bold Lion on 1.03.19.
//  Copyright © 2019 Bold Lion. All rights reserved.
//

import UIKit

class DropDownNotebookTVCell: UITableViewCell {
    
    @IBOutlet weak var notebookTitle: UILabel!
    
     var notebook: Notebook? {
        didSet {
            updateView()
        }
    }
    
    func updateView() {
        if let title = notebook?.title {
            notebookTitle.text = title
        }
    }
    
    deinit {
        print("DropDownNotebookTVCell deinitialised")
    }
}
