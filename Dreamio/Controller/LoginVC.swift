//
//  ViewController.swift
//  Dreamio
//
//  Created by Bold Lion on 14.02.19.
//  Copyright © 2019 Bold Lion. All rights reserved.
//

import UIKit
import SVProgressHUD

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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        isUserLogged()
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
    }
    
    func isUserLogged() {
        if Api.Users.CURRENT_USER != nil {
            performSegue(withIdentifier: Segues.LoginToTabbar, sender: nil)
        }
    }
    
    @IBAction func loginTapped(_ sender: UIButton) {
        view.endEditing(true)
        
        SVProgressHUD.setDefaultMaskType(.gradient)
        SVProgressHUD.show(withStatus: "Signing in...")
        
        guard let email = emailTextField.text, let pass = passwordTextField.text else { return }
        
        Api.Auth.loginWith(email: email, password: pass, onSuccess: { [unowned self] in
            SVProgressHUD.dismiss()
            self.performSegue(withIdentifier: Segues.LoginToTabbar, sender: nil)
        }, onError: { error in
            SVProgressHUD.showError(withStatus: error!)
        })
    }
    
    func setInitialUI() {
        view.set3ColorsGradientBackground(colorOne: Colors.bgGradientColor1, colorTwo: Colors.bgGradientColor2, colorThree: Colors.bgGradientColor3)
        formBackgroundView.roundedCorners()
        handleTextFields()
        loginButton.authButton()
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
            return
        }
        loginButton.isEnabled = true
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
