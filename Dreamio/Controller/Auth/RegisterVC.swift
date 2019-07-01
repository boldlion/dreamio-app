//
//  Register.swift
//  Dreamio
//
//  Created by Bold Lion on 14.02.19.
//  Copyright © 2019 Bold Lion. All rights reserved.
//

import UIKit
import SCLAlertView

class RegisterVC : UIViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var repeatTextField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var registerFormBackgroundView: UIView!
    @IBOutlet weak var privacyTextView: UITextView!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTextFieldsDelegate()
        registerButton.isEnabled = false
        handleTextFields()
        registerButton.authButton()
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
            let alert = SCLAlertView().showWait("Sending...", subTitle: "Please wait")
            
            Api.Auth.registerWith(username: usernameTextField.text!, email : emailTextField.text!, password: password, onSuccess: {
                    alert.close()
                },
                onError:  { error in
                    alert.close()
                    SCLAlertView().showError("Error", subTitle: error)
            })
        }
        else {
            SCLAlertView().showWarning("Passwords don't match", subTitle: "Please, try again.")
        }
    }
    
    func setupUI() {
        view.setGradientBackground(colorOne: Colors.purpleDarker, colorTwo: Colors.purpleLight)
        registerFormBackgroundView.roundedCorners()
        setHyperlinks()
    }
    
    func setHyperlinks() {
        let text = privacyTextView.text ?? ""
        let privacyPolicyPath = "https://www.dreamio.app/tos/"
        let font = privacyTextView.font
        let color = privacyTextView.textColor
        let attributedPolicyString = NSAttributedString.makeHyperlink(for: privacyPolicyPath, in: text, as: "Privacy Policy")
        privacyTextView.attributedText = attributedPolicyString
        privacyTextView.font = font
        privacyTextView.linkTextAttributes = [.foregroundColor: UIColor.white, .underlineStyle: NSUnderlineStyle.single.rawValue]
        
        privacyTextView.textColor = color
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    deinit {
        print("RegisterVC deinitialised")
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
        guard let name = usernameTextField.text,  !name.isEmpty,
              let email = emailTextField.text,    !email.isEmpty,
              let pass = passwordTextField.text,  !pass.isEmpty,
              let repPass = repeatTextField.text, !repPass.isEmpty
        else {
            registerButton.isEnabled = false
            registerButton.authButton()
            return
        }
        registerButton.isEnabled = true
        registerButton.authButton()
    }
    
}
