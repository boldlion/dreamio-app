//
//  EntriesVC.swift
//  Dreamio
//
//  Created by Bold Lion on 19.02.19.
//  Copyright © 2019 Bold Lion. All rights reserved.
//

import UIKit

class EntriesVC: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NavBar.setGradientNavigationBar(for: navigationController)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setNeedsStatusBarAppearanceUpdate()

    }
    
}
