//
//  LostPasswordVC.swift
//  Dreamio
//
//  Created by Bold Lion on 14.02.19.
//  Copyright © 2019 Bold Lion. All rights reserved.
//

import UIKit
import SCLAlertView

class LostPasswordVC: UIViewController {

    @IBOutlet weak var lostPasswordTextField: UITextField!
    @IBOutlet weak var retrievePassButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTextFieldDelegates()
        retrievePassButton.authButton()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        setUI()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction func cancelTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction func retrievePasswordTapped(_ sender: UIButton) {
        view.endEditing(true)
        guard let email = lostPasswordTextField.text else { return }
        let alert = SCLAlertView().showWait("Sending...", subTitle: "Please wait")
        
        Api.Auth.resetPassword(withEmail: email, onSuccess: { [unowned self] in
            alert.close()
            Alerts.showSuccessWithOkay(okayAction: { [unowned self] in
                self.dismiss(animated: true, completion: nil)
            }, title: "Success!", subTitle: "You should receive an email with instructions to reset your password")
        }, onError: { error in
            alert.close()
            SCLAlertView().showError("Error", subTitle: error)
        })
    }
    
    fileprivate func setUI() {
        view.setGradientBackground(colorOne: Colors.purpleDarker, colorTwo: Colors.purpleLight)
        handleTextField()
    }
    
    deinit {
        print("LostPasswordVC deinitialised")
    }
}

extension LostPasswordVC : UITextFieldDelegate {
    
    func setupTextFieldDelegates() {
        lostPasswordTextField.delegate = self
        retrievePassButton.isEnabled = false
    }
    
    func handleTextField() {
        lostPasswordTextField.addTarget(self, action: #selector(textfieldDidChange), for: .editingChanged)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc func textfieldDidChange () {
        guard let email = lostPasswordTextField.text, !email.isEmpty
            else {
                retrievePassButton.isEnabled = false
                retrievePassButton.authButton()
                return
            }
        retrievePassButton.isEnabled = true
        retrievePassButton.authButton()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}
