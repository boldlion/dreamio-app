//
//  UINavigationController+Extension.swift
//  Dreamio
//
//  Created by Bold Lion on 28.02.19.
//  Copyright © 2019 Bold Lion. All rights reserved.
//

import UIKit

extension UINavigationController {
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return topViewController?.preferredStatusBarStyle ?? .default
    }
}
