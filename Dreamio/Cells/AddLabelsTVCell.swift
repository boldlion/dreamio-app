//
//  AddLabelsTVCell.swift
//  Dreamio
//
//  Created by Bold Lion on 13.03.19.
//  Copyright © 2019 Bold Lion. All rights reserved.
//

import UIKit
import WSTagsField

protocol AddLabelsTVCellDelegate: AnyObject {
    func onDidAddTag(label: String)
    func onDidRemoveTag(label: String)
    func onDidChangeHeightTo()
}

class AddLabelsTVCell: UITableViewCell {
    
    let labelsField = WSTagsField()
    
    weak var delegate: AddLabelsTVCellDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        labelsField.placeholder = "Add label"
        labelsField.placeholderAlwaysVisible = true
        labelsField.font = UIFont.init(name: "HelveticaNeue-Regular", size: 13)

        labelsField.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        labelsField.layoutMargins = UIEdgeInsets(top: 2, left: 6, bottom: 2, right: 6)
        
        labelsField.tintColor = Colors.purpleDarker
        labelsField.textColor = .white
        labelsField.fieldTextColor = .black
        labelsField.selectedColor = .lightGray
        labelsField.selectedTextColor = .darkGray
        labelsField.placeholderColor = Colors.purpleDarker
        labelsField.placeholderAlwaysVisible = true
        labelsField.returnKeyType = .next
        labelsField.numberOfLines = 0
        
        // Events
        labelsField.onDidAddTag = { [unowned self] field, tag in
            self.delegate?.onDidAddTag(label: tag.text)
        }

        labelsField.onDidRemoveTag = { [unowned self] field, tag in
            self.delegate?.onDidRemoveTag(label: tag.text)
        }
        
        labelsField.onDidChangeHeightTo = { [unowned self] _, _ in
            self.delegate?.onDidChangeHeightTo()
        }
        
//        labelsField.onDidChangeText = { _, text in
//            print("DidChangeText")
//        }
        
//        labelsField.onDidChangeHeightTo = { sender, height in
//            print("HeightTo \(height)")
//        }
        
        labelsField.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(labelsField)

        NSLayoutConstraint.activate([
            labelsField.topAnchor.constraint(equalTo: contentView.topAnchor),
            labelsField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            labelsField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            contentView.bottomAnchor.constraint(equalTo: labelsField.bottomAnchor)
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    deinit {
        print("AddLabelsTVCell deinitialised")
    }
    
}
