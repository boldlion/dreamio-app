//
//  ChangePasswordTVC.swift
//  Dreamio
//
//  Created by Bold Lion on 20.02.19.
//  Copyright © 2019 Bold Lion. All rights reserved.
//

import UIKit
import SVProgressHUD

class ChangePasswordTVC: UITableViewController {

    @IBOutlet weak var newPasswordTextField: UITextField!
    @IBOutlet weak var oldPasswordTextField: UITextField!
    
    var email: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTextFieldsDelegates()
    }

    @IBAction func saveTapped(_ sender: UIButton) {
        view.endEditing(true)
        
        guard let currentPassword = oldPasswordTextField.text else { return }
        guard let newPassword = newPasswordTextField.text else { return }
        let currentPassTrimmed = currentPassword.trimmingCharacters(in: .whitespacesAndNewlines)
        let newPassTrimmed = newPassword.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard let email = email else { return }
        
        if currentPassTrimmed != "" || newPassTrimmed != "" {
            if currentPassTrimmed != newPassTrimmed {
                Api.Auth.updateUserPassword(email: email, currentPassword: currentPassword, newPassword: newPassword, onError: { error in
                    SVProgressHUD.showError(withStatus: error)
                }, onSuccess: {
                    SVProgressHUD.showSuccess(withStatus: "Your password has been updated!")
                })
            }
            else {
                SVProgressHUD.showError(withStatus: "New password cannot be identical to current password")
                return
            }
        }
        else {
            SVProgressHUD.showError(withStatus: "Fill out both passwords, please.")
            return
        }
    }
    
    @IBAction func forgotPasswordTapped(_ sender: UIButton) {
        guard let email = email else { return }
        let alert = UIAlertController(title: "Reset Password", message: "Would you like us to send you an email to \(email) in order to reset your password?", preferredStyle: .actionSheet)
        let okayAction = UIAlertAction(title: "Yes", style: .default, handler: { action in
            Api.Auth.resetPassword(withEmail: email, onSuccess: {
                SVProgressHUD.showSuccess(withStatus: "We've sent you an email with a link to reset your password.")
            }, onError: { error in
                SVProgressHUD.showError(withStatus: error!)
            })
        })
        let cancelAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
        alert.addAction(okayAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
}

extension ChangePasswordTVC : UITextFieldDelegate {
    
    func setTextFieldsDelegates() {
        newPasswordTextField.delegate = self
        oldPasswordTextField.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case oldPasswordTextField:
            newPasswordTextField.becomeFirstResponder()
        case newPasswordTextField:
            newPasswordTextField.resignFirstResponder()
        default:
            break
        }
        return true
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}
