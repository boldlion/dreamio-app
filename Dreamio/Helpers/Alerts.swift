//
//  Alerts.swift
//  Dreamio
//
//  Created by Bold Lion on 26.02.19.
//  Copyright © 2019 Bold Lion. All rights reserved.
//

import UIKit
import SCLAlertView

typealias emptyClosure = () -> Void

struct Alerts {
    
    static func showBasicAlert(on vc: UIViewController, withTitle title: String, message: String,  action: String ) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: action, style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(alertAction)
        vc.present(alert, animated: true, completion: nil)
    }
    
    static func showBasicAlertWithCancel(on vc: UIViewController, withTitle title: String, message: String,  action: String, completion: @escaping () -> Void ) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: action, style: UIAlertAction.Style.default, handler: { _ in
            completion()
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        alert.addAction(alertAction)
        vc.present(alert, animated: true, completion: nil)
    }
    
    static func showBasicAlertWithCompletion(on vc: UIViewController, withTitle title: String, message: String,  action: String, completion: @escaping () -> Void ) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: action, style: UIAlertAction.Style.default, handler: { _ in
            completion()
        })
        alert.addAction(alertAction)
        vc.present(alert, animated: true, completion: nil)
    }
    
    static func showAlertWithTwoOptionsWithCompletion(on vc: UIViewController, withTitle title: String, message: String, action1: String, action2: String, action1Completion: @escaping () -> Void, action2Completion: @escaping () -> Void ) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let aler1 = UIAlertAction(title: action1, style: UIAlertAction.Style.default, handler: { _ in
            action1Completion()
        })
        let aler2 = UIAlertAction(title: action2, style: UIAlertAction.Style.default, handler: { _ in
            action2Completion()
        })
        alert.addAction(aler1)
        alert.addAction(aler2)
        vc.present(alert, animated: true, completion: nil)
    }
    
    static func showAlertWithTextFieldAndCompletion(on vc: UIViewController, withTitle title: String, message: String, textFieldPlaceholder: String, actionTitle: String, completion: @escaping (_ enteredText: String) -> Void) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alertController.addTextField { textField -> Void in
            textField.placeholder = textFieldPlaceholder
        }
        let saveAction = UIAlertAction(title: actionTitle, style: .default, handler: { alert -> Void in
            if let textFieldContent = alertController.textFields![0].text {
                completion(textFieldContent)
            }
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: { [unowned alertController] _ in
            alertController.dismiss(animated: true, completion: nil)
        })
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        vc.present(alertController, animated: true, completion: nil)
    }
    
    
    // ACTIVE ALERTS
    static func showWarningAlertWithCancelAndCustomAction(title: String, subTitle: String, actionTitle: String, action: @escaping emptyClosure) {
        let appearance = SCLAlertView.SCLAppearance( showCloseButton: false )
        let alert = SCLAlertView(appearance: appearance) // create alert with appearance
        alert.addButton("Cancel", action: { [unowned alert] in
            alert.dismiss(animated: true)
        })
        alert.addButton(actionTitle, action: action)
        alert.showWarning(title, subTitle: subTitle)
    }
    
    static func showWarningWithOKAction(title: String, subtitle: String) {
        let appearance = SCLAlertView.SCLAppearance( showCloseButton : false)
        let alert = SCLAlertView(appearance: appearance)
        alert.addButton("OK", action: { [unowned alert] in
            alert.dismiss(animated: true)
        })
        alert.showWarning(title, subTitle: subtitle)
    }
    
    
    static func showEntryMenu(viewAction: @escaping emptyClosure, editAction: @escaping emptyClosure, deleteAction:  @escaping emptyClosure) {
        let appearance = SCLAlertView.SCLAppearance( showCloseButton : false)
        let alert = SCLAlertView(appearance: appearance)
        alert.addButton("View", action: {
             viewAction()
        })
        alert.addButton("Edit", action: {
            editAction()
        })
        alert.addButton("Delete", action: {
            deleteAction()
        })
        alert.addButton("Cancel", action: { [unowned alert] in
            alert.dismiss(animated: true)
        })
        alert.showInfo("Select an action", subTitle: "")
    }
    
    static func showSuccessWithOkay(okayAction: @escaping emptyClosure, title: String, subTitle: String?) {
        let appearance = SCLAlertView.SCLAppearance( showCloseButton : false)
        let alert = SCLAlertView(appearance: appearance)
        alert.addButton("Okay", action: {
            okayAction()
        })
        if let subtitle = subTitle {
            alert.showInfo(title, subTitle: subtitle)
        }
        else {
            alert.showSuccess(title, subTitle: "")
        }
    }

    static func showWarningWithCancelAndCustomAction(title: String, subtitle: String?, customAction: @escaping emptyClosure, actionTitle: String) {
        let appearance = SCLAlertView.SCLAppearance( showCloseButton: false)
        let alert = SCLAlertView(appearance: appearance)

        alert.addButton("Cancel") {
            alert.dismiss(animated: true)
        }
        alert.addButton(actionTitle, action: {
            customAction()
        })
        if let subTitle = subtitle {
            alert.showWarning(title, subTitle: subTitle)
        }
        else {
            alert.showWarning(title, subTitle: "")
        }
    }
    
    static func showWarningWithTwoCustomActions(title: String, subtitle: String?, dismissTitle: String, dismissAction: @escaping emptyClosure,  customAction2: @escaping emptyClosure, action2Title: String) {
        let appearance = SCLAlertView.SCLAppearance( showCloseButton: false)
        let alert = SCLAlertView(appearance: appearance)
        
        alert.addButton(dismissTitle) {
            dismissAction()
            alert.dismiss(animated: true)
        }
        alert.addButton(action2Title, action: {
            customAction2()
        })
        if let subTitle = subtitle {
            alert.showWarning(title, subTitle: subTitle)
        }
        else {
            alert.showWarning(title, subTitle: "")
        }
    }
    
}
