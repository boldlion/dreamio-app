//
//  UIViewController+Extension.swift
//  Dreamio
//
//  Created by Bold Lion on 26.03.19.
//  Copyright © 2019 Bold Lion. All rights reserved.
//

import UIKit

extension UIViewController {
    open override func awakeFromNib() {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
}
