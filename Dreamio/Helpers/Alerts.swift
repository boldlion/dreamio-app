//
//  Alerts.swift
//  Dreamio
//
//  Created by Bold Lion on 26.02.19.
//  Copyright © 2019 Bold Lion. All rights reserved.
//

import UIKit

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
}
