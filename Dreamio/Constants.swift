//
//  Constants.swift
//  Dreamio
//
//  Created by Bold Lion on 14.02.19.
//  Copyright © 2019 Bold Lion. All rights reserved.
//

import UIKit

struct Colors {
    static let bgGradientColor1 = UIColor.hex("#0F2027")
    static let bgGradientColor2 = UIColor.hex("#203A43")
    static let bgGradientColor3 = UIColor.hex("#2C5364")
    
    static let purpleLight = UIColor.hex("#CF74B8")
    static let purpleDarker = UIColor.hex("#8F6EC6")

    static let lightBlue1 = UIColor.hex("#33C8FA")
    static let lightBlue2 = UIColor.hex("#21809E")
}

struct Segues {
    static let LoginToTabbar = "Segue_LoginToTabbar"
    static let RegisterToTabbar = "Segue_RegisterToTabbar"
    static let ProfileToChangeEmail = "Segue_ProfileToUpdateEmail"
    static let ProfileToChangeUsername = "Segue_ProfileToChangeUsername"
    static let ProfileToChangePassword = "Segue_ProfileToChangePassword"
    static let NotebooksToNotebookInfo = "Segue_NotebooksToNotebookInfo"
    static let NotebookVCToCreateNotebook = "Segue_NotebookVCToCreateNotebook"
    static let NotebooksToRenameNotebookVC = "Segue_NotebooksToRenameNotebookVC"
    static let NotebookVCToUpdateNotebookCoverVC = "Segue_NotebookVCToUpdateNotebookCoverVC"
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
}

struct NotebookCoversString {
    static let covers =  ["cover1", "cover2", "cover3", "cover4", "cover5", "cover6", "cover7", "cover8", "cover9", "cover10"]
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
