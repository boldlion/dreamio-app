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
        layer.borderWidth = 1
        clipsToBounds = true
        if state ==  .normal {
            layer.borderColor = UIColor.white.cgColor
            backgroundColor = UIColor.white
            setTitleColor(Colors.purpleDarker, for: .normal)
        }
        else if state == .disabled {
            layer.borderColor = UIColor.lightText.cgColor
            backgroundColor = UIColor.clear
            setTitleColor(.lightText, for: .disabled)
        }
    }
    
//    func authButton() {
//        layer.cornerRadius = 5
//        clipsToBounds = true
//        setTitleColor(.lightText, for: .disabled)
//        setTitleColor(.white, for: .normal)
//        setGradientBackground(colorOne: Colors.lightBlue2, colorTwo: Colors.lightBlue1)
//    }
}
