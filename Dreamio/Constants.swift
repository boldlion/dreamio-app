//
//  Constants.swift
//  Dreamio
//
//  Created by Bold Lion on 14.02.19.
//  Copyright © 2019 Bold Lion. All rights reserved.
//

import UIKit
import LocalAuthentication

struct SecurityCheck {
    static func isFaceIDAvailable() -> Bool {
        if #available(iOS 11.0, *) {
            let context = LAContext()
            return (context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthentication, error: nil) && context.biometryType == .faceID)
        }
        return false
    }
    
    static func isTouchIdAvailable() -> Bool {
        if #available(iOS 11.0, *) {
            let context = LAContext()
            return (context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthentication, error: nil) && context.biometryType == .touchID)
        }
        return false
    }
    
    static func isPasscodeSet() -> Bool{
        return LAContext().canEvaluatePolicy(.deviceOwnerAuthentication, error: nil)
    }
}

struct Colors {
    static let bgGradientColor1 = UIColor.hex("#0F2027")
    static let bgGradientColor2 = UIColor.hex("#203A43")
    static let bgGradientColor3 = UIColor.hex("#2C5364")
    
    static let purpleLight = UIColor.hex("#CF74B8")
    static let purpleDarker = UIColor.hex("#8F6EC6")
}

struct DefaultsKeys {
    static let faceTouchIdState = "faceTouchIdState"
    static let passcodeState = "passcodeState"
}

struct Segues {
    static let ProfileToChangeEmail = "Segue_ProfileToUpdateEmail"
    static let ProfileToChangeUsername = "Segue_ProfileToChangeUsername"
    static let ProfileToChangePassword = "Segue_ProfileToChangePassword"
    static let NotebooksToNotebookInfo = "Segue_NotebooksToNotebookInfo"
    static let NotebookVCToCreateNotebook = "Segue_NotebookVCToCreateNotebook"
    static let NotebooksToRenameNotebookVC = "Segue_NotebooksToRenameNotebookVC"
    static let NotebookVCToUpdateNotebookCoverVC = "Segue_NotebookVCToUpdateNotebookCoverVC"
    static let EntriesToCreateEntryVC = "Segue_EntriesToCreateEntryVC"
    static let NewEntryToSelectNotebookVC = "Segue_NewEntryToSelectNotebookVC"
    static let NewEntryToLabelsVC = "Segue_NewEntryToLabelsVC"
    static let ProfileToCredit = "Segue_ProfileToCredit"
    static let ProfileToRequestAFeature = "Segue_ProfileToRequestAFeature"
    static let SearchVCToSearchEntriesVC = "Segue_SearchVCToSearchEntriesVC"
    static let PasscodeVCToTabbar = "Segue_PasscodeVCToTabbar"
}

struct Storyboards {
    static let auth = "Auth"
    static let entries = "Entries"
    static let notebook = "Notebooks"
    static let profile = "Profile"
}

struct Cell_Id {
    static let notebook = "NotebookCell"
    static let createNotebook = "CreateNotebookCVCell"
    static let entryTVCell = "EntryTVCell"
    static let dropDownNotebookCell = "DropDownNotebookTVCell"
    static let selectNotebookTVCell = "SelectNotebookTVCell"
    static let addLabelsTVCell = "AddLabelsTVCell"
    static let creditTVCell = "CreditTVCell"
    static let labelTVC = "LabelTVC"
}

struct NotebookCoversString {
    static let covers =  ["cover1", "cover2", "cover3", "cover4", "cover5", "cover6", "cover7", "cover8", "cover9", "cover10"]
}

struct NotificationKey {
    static let notebookRenamed = "notebookRenamed"
    static let notebookDeleted = "notebookDeleted"
    static let notebookAdded   = "notebookAdded"
    static let notebookDefaultChanged = "notebookDefaultChanged"
    static let notebookIdTapped = "notebookIdTapped"
}

struct NavBar {
    static func setGradientNavigationBar(for navController: UINavigationController?) {
        
        if let navBar = navController?.navigationBar {
            let gradientLayer = CAGradientLayer()
            var updatedFrame = navBar.bounds
            updatedFrame.size.height += navBar.frame.origin.y
            gradientLayer.frame = updatedFrame
            gradientLayer.colors = [Colors.purpleLight.cgColor, Colors.purpleDarker.cgColor]
            gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0) // vertical gradient start
            gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0) // vertical gradient end
            
            UIGraphicsBeginImageContext(gradientLayer.bounds.size)
            gradientLayer.render(in: UIGraphicsGetCurrentContext()!)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            navBar.setBackgroundImage(image, for: UIBarMetrics.default)
        }
    }
}
