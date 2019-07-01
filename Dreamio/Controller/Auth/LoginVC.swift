//
//  ViewController.swift
//  Dreamio
//
//  Created by Bold Lion on 14.02.19.
//  Copyright © 2019 Bold Lion. All rights reserved.
//

import UIKit
import SCLAlertView

class LoginVC: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var lostPassButton: UIButton!
    @IBOutlet weak var formBackgroundView: UIView!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        setInitialUI()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTextFieldDelegates()
        handleTextFields()
        loginButton.isEnabled = false
        loginButton.authButton()

    }
    
    @IBAction func loginTapped(_ sender: UIButton) {
        view.endEditing(true)
        let alert = SCLAlertView().showWait("Signing in...", subTitle: "Please wait")
        guard let email = emailTextField.text, let pass = passwordTextField.text else { return }
        
        Api.Auth.loginWith(email: email, password: pass, onSuccess: {
            alert.close()
        }, onError: {  error in
            alert.close()
            SCLAlertView().showError("Error", subTitle: error!)
        })
    }
    
    func setInitialUI() {
        view.setGradientBackground(colorOne: Colors.purpleDarker, colorTwo: Colors.purpleLight)
        formBackgroundView.roundedCorners()
        handleTextFields()
    }
    
    deinit {
        print("LoginVC deinitialised")
    }
}

extension LoginVC: UITextFieldDelegate {
    
    func setTextFieldDelegates() {
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    func handleTextFields() {
        emailTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }

    @objc func textFieldDidChange() {
        guard let email = emailTextField.text, !email.isEmpty,
              let pass = passwordTextField.text, !pass.isEmpty
        else {
            loginButton.isEnabled = false
            loginButton.authButton()
            return
        }
        loginButton.isEnabled = true
        loginButton.authButton()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case emailTextField:
            passwordTextField.becomeFirstResponder()
        case passwordTextField:
            passwordTextField.resignFirstResponder()
        default:
            break
        }
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}
