//
//  UpdateEmailTVC.swift
//  Dreamio
//
//  Created by Bold Lion on 20.02.19.
//  Copyright © 2019 Bold Lion. All rights reserved.
//

import UIKit
import SVProgressHUD

protocol ChangeEmailTVCDelegate {
    func updateUserInfo()
}

class ChangeEmailTVC: UITableViewController {

    @IBOutlet weak var emailTextField: UITextField!
    
    var email: String?
    var newEmail = ""
    
    var delegate: ChangeEmailTVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.delegate = self
        guard let oldEmail = email else { return }
        emailTextField.text = oldEmail
    }

    @IBAction func saveTapped(_ sender: UIButton) {
        view.endEditing(true)
        guard let emailAddress = emailTextField.text else { return }
        let trimmedEmail = emailAddress.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmedEmail != "" {
            guard let oldEmail = email else { return }
            if oldEmail != trimmedEmail {
                Api.Auth.updateUserEmail(email: trimmedEmail, onSuccess: { [unowned self] in
                    self.delegate?.updateUserInfo()
                    SVProgressHUD.showSuccess(withStatus: "Your email has been updated!")
                }, onError: { errorMessage in
                    SVProgressHUD.showError(withStatus: errorMessage!)
                })
            }
            else {
                SVProgressHUD.showInfo(withStatus: "No change has been made.")
                return
            }
        }
        else {
            SVProgressHUD.showError(withStatus: "Enter valid email address, please.")
            return
        }
    }
}

extension ChangeEmailTVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
