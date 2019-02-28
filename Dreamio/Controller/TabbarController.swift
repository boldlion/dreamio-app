//
//  TabbarController.swift
//  Dreamio
//
//  Created by Bold Lion on 19.02.19.
//  Copyright © 2019 Bold Lion. All rights reserved.
//

import UIKit

class TabbarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
    }
    
    func setUI() {
        tabBar.barTintColor = .white
        tabBar.tintColor = Colors.purpleDarker
        tabBar.unselectedItemTintColor = .lightGray
    }
}
