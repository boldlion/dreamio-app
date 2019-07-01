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
        userLoggedState()
        setNavBarBackImage()
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.disabledToolbarClasses.append(NewEntryVC.self)
        localAuthenticationOfUser() 
        return true
    }
    
    func applicationDidReceiveMemoryWarning(_ application: UIApplication) {
        print("Memory warning!")
    }
    
    
    fileprivate func localAuthenticationOfUser() {
        // Check if Touch/FaceID/Passcode is ON on the phone/ipad
        if SecurityCheck.isFaceIDAvailable() || SecurityCheck.isTouchIdAvailable() || SecurityCheck.isPasscodeSet() {
            let faceTouchIdState = UserDefaults.standard.bool(forKey: DefaultsKeys.faceTouchIdState)
            if faceTouchIdState {
                let storyboard = UIStoryboard(name: "Tabbar", bundle: nil)
                let controller = storyboard.instantiateViewController(withIdentifier: "AuthtenticateVC") as! AuthtenticateVC
                self.window?.rootViewController = controller
                self.window?.makeKeyAndVisible()
            }
            else {
                let storyboard = UIStoryboard(name: "Tabbar", bundle: nil)
                let controller = storyboard.instantiateViewController(withIdentifier: "Tabbar") as! TabbarController
                self.window?.rootViewController = controller
                self.window?.makeKeyAndVisible()
            }
        }
        else {
            let storyboard = UIStoryboard(name: "Tabbar", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "Tabbar") as! TabbarController
            self.window?.rootViewController = controller
            self.window?.makeKeyAndVisible()
        }
    }
    
    fileprivate func userLoggedState() {
        _ = Auth.auth().addStateDidChangeListener { [unowned self] auth, user in
            
            if user != nil {
                self.localAuthenticationOfUser()
            }
            else {
                let storyboard = UIStoryboard(name: "Auth", bundle: nil)
                let controller = storyboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                self.window?.rootViewController = controller
                self.window?.makeKeyAndVisible()
            }
        }
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        localAuthenticationOfUser()
    }
    
    func setNavBarBackImage() {
        let backImage = UIImage(named: "icon_back")?.withRenderingMode(.alwaysTemplate)
        UINavigationBar.appearance().backIndicatorImage = backImage
        UINavigationBar.appearance().tintColor = .white
        UINavigationBar.appearance().backIndicatorTransitionMaskImage = backImage
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
    }

}

