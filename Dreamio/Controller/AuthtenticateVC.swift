//
//  PasscodeVC.swift
//  Dreamio
//
//  Created by Bold Lion on 1.05.19.
//  Copyright © 2019 Bold Lion. All rights reserved.
//

import UIKit
import LocalAuthentication
import SCLAlertView

class AuthtenticateVC: UIViewController {

    @IBOutlet weak var lockImageView: UIImageView!
    @IBOutlet weak var touchFaceIDButton: UIButton!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        if let lockImage = UIImage(named: "icon_auth") {
            let tintableImage = lockImage.withRenderingMode(.alwaysTemplate)
            lockImageView.image = tintableImage
            lockImageView.tintColor = .white
        }
        view.setGradientBackground(colorOne: Colors.purpleDarker, colorTwo: Colors.purpleLight)
    }
    
    @IBAction func touchFaceIDTapped(_ sender: UIButton) {
        authenticate()
    }
    
    func setUI() {
        //let faceTouchIdState = UserDefaults.standard.bool(forKey: DefaultsKeys.faceTouchIdState)
        if SecurityCheck.isFaceIDAvailable() {
            touchFaceIDButton.setTitle("Unlock with FaceID", for: .normal)
        }
        if SecurityCheck.isTouchIdAvailable() {
            touchFaceIDButton.setTitle("Unlock with Touch ID", for: .normal)
        }
        touchFaceIDButton.roundedCorners()
        touchFaceIDButton.authButton()
    }
    
    
    func authenticate() {
        let context = LAContext()
        var authError: NSError?
        context.localizedFallbackTitle = " "
        let policy = LAPolicy.deviceOwnerAuthenticationWithBiometrics
        
        if context.canEvaluatePolicy(policy, error: &authError) {
            context.evaluatePolicy(policy, localizedReason: "To unlock Dreamio.") { [weak self] (success, err) in
                DispatchQueue.main.async {
                    if success {
                        self?.performSegue(withIdentifier: Segues.PasscodeVCToTabbar, sender: nil)
                    }
                    else {
                        guard let errMessage = err else { return }
                        SCLAlertView().showError("Error!", subTitle: errMessage.localizedDescription)
                    }
                }
            }
        }
        else {
            // No touch Id or face id available, maybe not even passcode
            guard let err = authError else { return }
            if isBiometryReady() {
                print("do this")
            }
            else {
                SCLAlertView().showError("Error!", subTitle: err.localizedDescription)
            }
        }
    }
    
    func showEnterPasscode() {
        let context = LAContext()
        var errMess: NSError?
        let policy = LAPolicy.deviceOwnerAuthentication
        
        if context.canEvaluatePolicy(policy, error: &errMess) {
            context.evaluatePolicy(policy, localizedReason: "Please authenticate to unlock Dreamio.") { [unowned self] (success, err) in
                DispatchQueue.main.async {
                    if success && err == nil {
                        self.performSegue(withIdentifier: Segues.PasscodeVCToTabbar, sender: nil)
                    }
                    else {
                        SCLAlertView().showError("Error!", subTitle: err!.localizedDescription)
                    }
                }
            }
        }
        else {
            SCLAlertView().showError("Error!", subTitle: "Cannot evaluate policy")
        }
    }
    
    
    func isBiometryReady() -> Bool {
        let context : LAContext = LAContext()
        var error : NSError?
        
        context.localizedFallbackTitle = ""
        context.localizedCancelTitle = " "
        
        if (context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: &error)) {
            return true
        }
        if error?.code == -8 {
            let reason:String = "TouchID has been locked out due to few fail attemp. Enter iPhone passcode to enable touchID."
            context.evaluatePolicy(LAPolicy.deviceOwnerAuthentication, localizedReason: reason, reply: { [weak self] (success, error) in
                if success {
                    self?.performSegue(withIdentifier: Segues.PasscodeVCToTabbar, sender: nil)
                }
            })
            return true
        }
        return false
    }

    func evaluatePolicyErrorMessage(errorCode: Int) -> String {
        var message = ""
        if #available(iOS 11.0, macOS 10.13, *) {
            switch errorCode {
            case LAError.biometryNotAvailable.rawValue:
                message = "Authentication could not start because the device does not support biometric authentication."
                
            case LAError.biometryLockout.rawValue:
                message = "Authentication could not continue because the user has been locked out of biometric authentication, due to failing authentication too many times."
                
            case LAError.biometryNotEnrolled.rawValue:
                message = "Authentication could not start because the user has not enrolled in biometric authentication."
                
            default:
                message = "Did not find error code on LAError object"
            }
        }
        else {
            switch errorCode {
            case LAError.touchIDLockout.rawValue:
                message = "Too many failed attempts."
                
            case LAError.touchIDNotAvailable.rawValue:
                message = "TouchID is not available on the device"
                
            case LAError.touchIDNotEnrolled.rawValue:
                message = "TouchID is not enrolled on the device"
                
            default:
                message = "Did not find error code on LAError object"
            }
        }
        return message
    }
    
    func canEvaluatePolicyErrorMessage(errorCode: Int) -> String {
        
        var message = ""
        
        switch errorCode {
            
        case LAError.authenticationFailed.rawValue:
            message = "The user failed to provide valid credentials"
            
        case LAError.appCancel.rawValue:
            message = "Authentication was cancelled by application"
            
        case LAError.invalidContext.rawValue:
            message = "The context is invalid"
            
        case LAError.notInteractive.rawValue:
            message = "Not interactive"
            
        case LAError.passcodeNotSet.rawValue:
            message = "Passcode is not set on the device"
            
        case LAError.systemCancel.rawValue:
            message = "Authentication was cancelled by the system"
            
        case LAError.userCancel.rawValue:
            message = "The user did cancel"
            
        case LAError.userFallback.rawValue:
            message = "The user chose to use the fallback"
            
        default:
            message = canEvaluatePolicyErrorMessage(errorCode: errorCode)
        }
        
        return message
    }
}
