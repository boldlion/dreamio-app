//
//  UIButto+Extension.swift
//  Dreamio
//
//  Created by Bold Lion on 14.02.19.
//  Copyright © 2019 Bold Lion. All rights reserved.
//

import UIKit

extension UIButton {
    
    func authButton() {
        layer.cornerRadius = 5
        clipsToBounds = true
        setTitleColor(.lightText, for: .disabled)
        setTitleColor(.white, for: .normal)
        setGradientBackground(colorOne: Colors.lightBlue2, colorTwo: Colors.lightBlue1)
    }
}
