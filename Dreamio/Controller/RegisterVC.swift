//
//  Register.swift
//  Dreamio
//
//  Created by Bold Lion on 14.02.19.
//  Copyright © 2019 Bold Lion. All rights reserved.
//

import UIKit
import SVProgressHUD

class RegisterVC : UIViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var repeatTextField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var registerFormBackgroundView: UIView!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTextFieldsDelegate()
        registerButton.isEnabled = false
        handleTextFields()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        setupUI()
    }

    @IBAction func cancel(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func registerTapped(_ sender: UIButton) {
        guard let password = passwordTextField.text, let repPass  = repeatTextField.text else { return }
        
        if password == repPass {
            view.endEditing(true)
            SVProgressHUD.show(withStatus: "Waiting...")
            
            Api.Auth.registerWith(username: usernameTextField.text!, email : emailTextField.text!, password: password,
                                 onSuccess: { [unowned self] in
                                            SVProgressHUD.dismiss()
                                            self.performSegue(withIdentifier: Segues.RegisterToTabbar, sender: nil)
                                            },
                                 onError:  { error in
                                            SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.gradient)
                                            SVProgressHUD.showError(withStatus: error!)
            })
        }
        else {
            SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.gradient)
            SVProgressHUD.showError(withStatus: "Passwords don't match. Try again.")
            SVProgressHUD.dismiss(withDelay: 3)
        }
    }
    
    func setupUI() {
        view.set3ColorsGradientBackground(colorOne: Colors.bgGradientColor1, colorTwo: Colors.bgGradientColor2, colorThree: Colors.bgGradientColor3)
        registerButton.authButton()
        registerFormBackgroundView.roundedCorners()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }

}

extension RegisterVC : UITextFieldDelegate {
    
    func setTextFieldsDelegate() {
        usernameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        repeatTextField.delegate = self
    }
    
    func handleTextFields() {
        usernameTextField.addTarget(self, action: #selector(self.textFieldDidChange), for: .editingChanged)
        emailTextField.addTarget(self, action: #selector(self.textFieldDidChange), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(self.textFieldDidChange), for: .editingChanged)
        repeatTextField.addTarget(self, action: #selector(self.textFieldDidChange), for: .editingChanged)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case usernameTextField:
            emailTextField.becomeFirstResponder()
            return true
        case emailTextField:
            passwordTextField.becomeFirstResponder()
            return true
        case passwordTextField:
            repeatTextField.becomeFirstResponder()
            return true
        case repeatTextField:
            repeatTextField.resignFirstResponder()
            return true
        default:
            break
        }
        return true
    }
    
    @objc func textFieldDidChange()  {
        guard let name = usernameTextField.text,      !name.isEmpty,
              let email = emailTextField.text,    !email.isEmpty,
              let pass = passwordTextField.text,  !pass.isEmpty,
              let repPass = repeatTextField.text, !repPass.isEmpty
        else {
            registerButton.isEnabled = false
            return
        }
        registerButton.isEnabled = true
    }
    
}
