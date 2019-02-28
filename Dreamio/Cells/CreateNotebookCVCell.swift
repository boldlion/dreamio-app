//
//  CreateNotebookCVCell.swift
//  Dreamio
//
//  Created by Bold Lion on 25.02.19.
//  Copyright © 2019 Bold Lion. All rights reserved.
//

import UIKit

class CreateNotebookCVCell: UICollectionViewCell {
    
    @IBOutlet weak var coverImageView: UIImageView!
    
    @IBOutlet weak var dimView: UIView!
    @IBOutlet weak var checkmarkIcon: UIImageView!
 
    override func awakeFromNib() {
        super.awakeFromNib()
        setUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
      //  hideDimViewAndCheckmark()
        coverImageView.image = nil
    }
    
    func hideDimViewAndCheckmark() {
        UIView.animate(withDuration: 0.1, animations: { [unowned self] in
            self.dimView.isHidden = true
            self.checkmarkIcon.isHidden = true
        })
    }
    
    func showDimViewAndCheckmark() {
        UIView.animate(withDuration: 0.1, animations: { [unowned self] in
            self.dimView.isHidden = false
            self.checkmarkIcon.isHidden = false
            self.dimView.layer.cornerRadius = 10
            self.dimView.clipsToBounds = true
            self.dimView.layer.borderWidth = 2
            self.dimView.layer.borderColor = Colors.purpleDarker.cgColor
            self.dimView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        })

    }
    
    func setUI() {
        coverImageView.clipsToBounds = true
        
        layer.shadowColor = UIColor.lightGray.cgColor
        layer.shadowOffset = CGSize(width:1, height: 1)
        layer.shadowRadius = 2.0
        layer.shadowOpacity = 1.0
        layer.masksToBounds = false
        
        contentView.clipsToBounds = true
        contentView.layer.cornerRadius = 10
        contentView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
    }
}
