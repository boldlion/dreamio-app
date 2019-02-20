//
//  ProfileTVC.swift
//  Dreamio
//
//  Created by Bold Lion on 19.02.19.
//  Copyright © 2019 Bold Lion. All rights reserved.
//

import UIKit
import SVProgressHUD

class ProfileTVC: UITableViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    var oldUsername = ""
    var oldEmail = ""
    var user: UserModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTextFieldDelegatesAndUserInteractionState()
        fetchCurrentUser()
    }
    
    func fetchCurrentUser() {
        Api.Users.observeCurrentUser(completion: { [unowned self] userData in
            guard let email = userData.email, let username = userData.username else { return }
            self.user = userData
            self.emailTextField.text = email
            self.usernameTextField.text = username
            self.oldUsername = username
            self.oldEmail = email
            self.tableView.reloadData()
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Segues.ProfileToChangeEmail {
            let changeEmailTVC = segue.destination as! ChangeEmailTVC
            guard let email = user.email else { return }
            changeEmailTVC.delegate = self
            changeEmailTVC.email = email
        }
        if segue.identifier == Segues.ProfileToChangeUsername {
            let changeUsernameTVC = segue.destination as! ChangeUsernameTVC
            guard let username = user.username else { return }
            changeUsernameTVC.username = username
            changeUsernameTVC.delegate = self
        }
        if segue.identifier == Segues.ProfileToChangePassword {
            let changePassTVC = segue.destination as! ChangePasswordTVC
            guard let email = user.email else { return }
            changePassTVC.email = email
        }
        
    }
    
    @IBAction func deleteAcountTapped(_ sender: UIButton) {
        // TODO: Delete functionality not working yet
    }
    
    @IBAction func logoutTapped(_ sender: UIButton) {
        Api.Auth.logout(onSuccess: { [unowned self] in
            let storyboard = UIStoryboard(name: Storyboards.auth, bundle: nil)
            let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginVC")
            self.present(loginVC, animated: true, completion: nil)
        }, onError: { errorMessage in
            SVProgressHUD.showError(withStatus: errorMessage)
        })
    }
}

extension ProfileTVC : UITextFieldDelegate {
    
    func setTextFieldDelegatesAndUserInteractionState() {
        usernameTextField.delegate = self
        emailTextField.delegate = self
        usernameTextField.isUserInteractionEnabled = false
        emailTextField.isUserInteractionEnabled = false
    }
}

extension ProfileTVC: ChangeEmailTVCDelegate, ChangeUsernameTVCDelegate {
    func updateUserInfo() {
        fetchCurrentUser()
    }
}
