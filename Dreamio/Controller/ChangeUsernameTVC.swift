//
//  ChangeUsernameTVC.swift
//  Dreamio
//
//  Created by Bold Lion on 20.02.19.
//  Copyright © 2019 Bold Lion. All rights reserved.
//

import UIKit
import SVProgressHUD

protocol ChangeUsernameTVCDelegate {
    func updateUserInfo()
}

class ChangeUsernameTVC: UITableViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    
    var username: String?
    
    var delegate: ChangeUsernameTVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        usernameTextField.delegate = self
        guard let oldUsername = username else { return }
        usernameTextField.text = oldUsername
    }

    @IBAction func saveTapped(_ sender: UIButton) {
        view.endEditing(true)
        guard let newUsername = usernameTextField.text else { return }
        let trimmedUsername = newUsername.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmedUsername != "" {
            guard let oldUsername = username else { return }
            if trimmedUsername != oldUsername {
                
                Api.Auth.updateUserUsername(username: newUsername, onSuccess: { [unowned self] in
                    self.delegate?.updateUserInfo()
                    SVProgressHUD.showSuccess(withStatus: "Your username was successfully updated!")
                    }, onError: { errorMessage in
                        SVProgressHUD.showError(withStatus: errorMessage!)
                        self.usernameTextField.text = self.username
                })
            }
            else {
                SVProgressHUD.showInfo(withStatus: "No change has been made.")
                return
            }
        }
        else {
            SVProgressHUD.showError(withStatus: "Enter valid username, please.")
            self.usernameTextField.text = self.username
            return
        }
    }
}

extension ChangeUsernameTVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
