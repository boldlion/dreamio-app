//
//  EntryTVCell.swift
//  Dreamio
//
//  Created by Bold Lion on 1.03.19.
//  Copyright © 2019 Bold Lion. All rights reserved.
//

import UIKit

protocol EntryTVCellDelegate: AnyObject {
    func settingsFor(entry: Entry)
}

class EntryTVCell: UITableViewCell {

    @IBOutlet weak var entryTitleLabel: UILabel!
    @IBOutlet weak var entryContentLabel: UILabel!
    @IBOutlet weak var monthAndDateLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var settingsImageView: UIImageView!
    
    weak var delegate: EntryTVCellDelegate?
    
     var entry: Entry? {
        didSet {
            updateView()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setTapGesturesForSettings()
    }
    
    func updateView() {
        if let title = entry?.title {
            entryTitleLabel.text = title
        }
        
        if let content = entry?.content {
            entryContentLabel.text = content
        }
        
        if let time = entry?.creationDate {
            monthAndDateLabel.text = convertIntToMonthAndDay(number: time)
            yearLabel.text = convertIntToYear(number: time)
        }
    }
    
    func convertIntToMonthAndDay(number: Int) -> String {
        let timeInterval = Double(number)
        let date = Date(timeIntervalSince1970: timeInterval)
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd"
        return formatter.string(from: date)
    }
    
    func convertIntToYear(number: Int) -> String {
        let timeInterval = Double(number)
        let date = Date(timeIntervalSince1970: timeInterval)
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY"
        return formatter.string(from: date)
    }
    
    func setTapGesturesForSettings() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(settingsTapped))
        settingsImageView.isUserInteractionEnabled = true
        settingsImageView.tintColor = .lightGray
        settingsImageView.addGestureRecognizer(gesture)
    }
    
    @objc func settingsTapped() {
        if let entry = entry  {
            delegate?.settingsFor(entry: entry)
        }
    }
    
    deinit {
        print("EntryTVCell deinitialised")
    }
}
