//
//  ChangeUsernameTVC.swift
//  Dreamio
//
//  Created by Bold Lion on 20.02.19.
//  Copyright © 2019 Bold Lion. All rights reserved.
//

import UIKit
import SCLAlertView

protocol ChangeUsernameTVCDelegate: AnyObject {
    func updateUserInfo()
}

class ChangeUsernameTVC: UITableViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    var username: String?
    
    weak var delegate: ChangeUsernameTVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        usernameTextField.delegate = self
        guard let oldUsername = username else { return }
        usernameTextField.text = oldUsername
    }

    @IBAction func saveTapped(_ sender: UIButton) {
        view.endEditing(true)
        let alert = SCLAlertView().showWait("Sending request...", subTitle: "Please, wait!")
        
        guard let newUsername = usernameTextField.text else { return }
        let trimmedUsername = newUsername.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmedUsername != "" {
            guard let oldUsername = username else { return }
            if trimmedUsername != oldUsername {
                
                Api.Auth.updateUserUsername(username: newUsername,
                    onSuccess: { [unowned self] in
                        alert.close()
                        self.username = newUsername
                        self.delegate?.updateUserInfo()
                        SCLAlertView().showSuccess("Done!", subTitle: "Your username was successfully updated!")
                    },
                    onError: { [unowned self] errorMessage in
                        alert.close()
                        SCLAlertView().showError("Error!", subTitle: errorMessage!)
                        self.usernameTextField.text = self.username
                        return
                })
            }
            else {
                alert.close()
                SCLAlertView().showWarning("Oops!", subTitle: "No change has been made.")
                return
            }
        }
        else {
            alert.close()
            SCLAlertView().showError("Oops!", subTitle: "Enter valid username, please.")
            self.usernameTextField.text = username
            return
        }
    }
    
    deinit {
        print("ChangeUsernameTVC deinit")
    }
}

extension ChangeUsernameTVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
