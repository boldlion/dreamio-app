//
//  AppDelegate.swift
//  Dreamio
//
//  Created by Bold Lion on 14.02.19.
//  Copyright © 2019 Bold Lion. All rights reserved.
//

import UIKit
import Firebase
import IQKeyboardManagerSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        setNavBarBackImage()
        IQKeyboardManager.shared.enable = true
        return true
    }
    
    func setNavBarBackImage() {
        let backImage = UIImage(named: "icon_back")?.withRenderingMode(.alwaysTemplate)
        UINavigationBar.appearance().backIndicatorImage = backImage
        UINavigationBar.appearance().tintColor = .white
        UINavigationBar.appearance().backIndicatorTransitionMaskImage = backImage
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        let BarButtonItemAppearance = UIBarButtonItem.appearance()
        BarButtonItemAppearance.setTitleTextAttributes([.foregroundColor: UIColor.clear], for: .normal)
    }

}

