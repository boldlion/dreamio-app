//
//  SelectNotebookTVCell.swift
//  Dreamio
//
//  Created by Bold Lion on 5.03.19.
//  Copyright © 2019 Bold Lion. All rights reserved.
//

import UIKit

class SelectNotebookTVCell: UITableViewCell {

    @IBOutlet weak var notebookTitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        notebookTitleLabel.textColor = Colors.purpleDarker
    }
    
    var notebook: Notebook? {
        didSet {
            updateView()
        }
    }
    
    func updateView() {
        if let title = notebook?.title {
            notebookTitleLabel.text = title
        }
    }
    
    deinit {
        print("SelectNotebookTVCell deinitialised")
    }
}
