//
//  LostPasswordVC.swift
//  Dreamio
//
//  Created by Bold Lion on 14.02.19.
//  Copyright © 2019 Bold Lion. All rights reserved.
//

import UIKit
import SVProgressHUD

class LostPasswordVC: UIViewController {

    @IBOutlet weak var lostPasswordTextField: UITextField!
    @IBOutlet weak var retrievePassButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTextFieldDelegates()
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
        SVProgressHUD.setDefaultMaskType(.gradient)
        SVProgressHUD.show(withStatus: "Sending...")
        
        // TODO: The DNS needs to be changed from those provided by Firebase in order to have custom emails
        Api.Auth.resetPassword(withEmail: email, onSuccess: {
            SVProgressHUD.showSuccess(withStatus: "Done! You check your email.")
            self.dismiss(animated: true, completion: nil)
        }, onError: { error in
             SVProgressHUD.showError(withStatus: error!)
        })
    }
    
    fileprivate func setUI() {
        view.set3ColorsGradientBackground(colorOne: UIColor.hex("#0F2027"), colorTwo: UIColor.hex("#203A43"), colorThree: UIColor.hex("#2C5364"))
        retrievePassButton.authButton()
        handleTextField()
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
                return
            }
        retrievePassButton.isEnabled = true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}
