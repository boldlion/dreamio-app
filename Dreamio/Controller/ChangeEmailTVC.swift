//
//  UpdateEmailTVC.swift
//  Dreamio
//
//  Created by Bold Lion on 20.02.19.
//  Copyright © 2019 Bold Lion. All rights reserved.
//

import UIKit
import SCLAlertView

protocol ChangeEmailTVCDelegate: AnyObject {
    func updateUserInfo()
}

class ChangeEmailTVC: UITableViewController {

    @IBOutlet weak var emailTextField: UITextField!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    var email: String?
    
    weak var delegate: ChangeEmailTVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.delegate = self
        guard let oldEmail = email else { return }
        emailTextField.text = oldEmail
    }

    @IBAction func saveTapped(_ sender: UIButton) {
        view.endEditing(true)
        let alert = SCLAlertView().showWait("Sending request...", subTitle: "Please, wait!")

        guard let emailAddress = emailTextField.text else { return }
        let trimmedEmail = emailAddress.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmedEmail != "" {
            guard let oldEmail = email else { return }
            if oldEmail != trimmedEmail {
                Api.Auth.updateUserEmail(email: trimmedEmail, onSuccess: { [unowned self] in
                    alert.close()
                    self.email = trimmedEmail
                    self.delegate?.updateUserInfo()
                    SCLAlertView().showSuccess("Done!", subTitle: "Your email has been updated!")
                }, onError: { errorMessage in
                    alert.close()
                    SCLAlertView().showError("Oops!", subTitle: errorMessage!)
                })
            }
            else {
                alert.close()
                SCLAlertView().showWarning("Oops!", subTitle: "You haven't made any change.")
                return
            }
        }
        else {
            alert.close()
            SCLAlertView().showError("Oops!", subTitle: "Enter valid email address, please.")
            return
        }
    }
    
    deinit {
        print("ChangeEmailTVC has been deinitialised")
    }
}

extension ChangeEmailTVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
