//
//  ProfileTVC.swift
//  Dreamio
//
//  Created by Bold Lion on 19.02.19.
//  Copyright © 2019 Bold Lion. All rights reserved.
//

import UIKit
import FirebaseAuth
import MessageUI
import StoreKit
import SCLAlertView
import LocalAuthentication

class ProfileTVC: UITableViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var faceTouchIDLabel: UILabel!
    @IBOutlet weak var faceTouchIdIcon: UIImageView!
    @IBOutlet weak var faceTouchIDSwitch: UISwitch!
    
    var oldUsername = ""
    var oldEmail = ""
    var user: UserModel!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setFaceTouchIDCellsUI()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTableViewFooter()
        setTextFieldDelegatesAndUserInteractionState()
        fetchCurrentUser()
        NavBar.setGradientNavigationBar(for: navigationController)
        tableView.rowHeight = 40
     //   showRateRequest()
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
    
    func setFaceTouchIDCellsUI() {
        if SecurityCheck.isTouchIdAvailable() {
            faceTouchIdIcon.image = UIImage(named: "icon_touchID")
            faceTouchIDLabel.text = "Touch ID"
            faceTouchIDSwitch.isOn = UserDefaults.standard.bool(forKey: DefaultsKeys.faceTouchIdState)
        }
        else if SecurityCheck.isFaceIDAvailable() {
            faceTouchIdIcon.image = UIImage(named: "icon_faceID")
            faceTouchIDLabel.text = "Face ID"
            faceTouchIDSwitch.isOn = UserDefaults.standard.bool(forKey: DefaultsKeys.faceTouchIdState)
        }
        else if !SecurityCheck.isFaceIDAvailable() && !SecurityCheck.isTouchIdAvailable() {
            faceTouchIDSwitch.isEnabled = false
        }
    }
    
    func setTableViewFooter() {
        let versionFooter = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 40))
        versionFooter.backgroundColor = .clear
        let footerLabel = UILabel(frame: versionFooter.frame)
        footerLabel.font = UIFont(name: "HelvetikaNeue-Bold", size: 13)
        footerLabel.textColor = .darkGray
        footerLabel.textAlignment = .center
        footerLabel.text = "Dreamio \(Bundle.main.releaseVersionNumberPretty) \(Bundle.main.releaseVersionNumber!)"
        versionFooter.addSubview(footerLabel)
        tableView.tableFooterView = versionFooter
    }
    
    @IBAction func faceTouchIDTapped(_ sender: UISwitch) {
        if SecurityCheck.isFaceIDAvailable() || SecurityCheck.isTouchIdAvailable() {
            print(sender.isOn)
            faceTouchIDSwitch.isEnabled = true
            UserDefaults.standard.set(sender.isOn, forKey: DefaultsKeys.faceTouchIdState)
        }
        else {
            faceTouchIDSwitch.isEnabled = false
            faceTouchIDSwitch.isOn = false
            if SecurityCheck.isTouchIdAvailable() {
                SCLAlertView().showWarning("Bummer!", subTitle: "This device doesn't support TouchID OR TochID is disabled. \n \n You can use Passcode instead if TouchID is not available.")
            }
            else if SecurityCheck.isFaceIDAvailable() {
                SCLAlertView().showWarning("Bummer!", subTitle: "This device doesn't support FaceID OR FaceID is disabled. \n \n You can use Passcode instead if FaceID is not available.")
            }
        }
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 2 && indexPath.row == 0 {
            // Rate
            SKStoreReviewController.requestReview()
        }
        if indexPath.section == 2 && indexPath.row == 1 {
            // Support
            showMailComposeVC(with: "I need help", email: "support@dreamio.app", body: nil)
        }
        else if indexPath.section == 3 && indexPath.row == 0 {
            // Feedback Cell
            showMailComposeVC(with: "Feedback", email: "feedback@dreamio.app", body: nil)
        }
        else if indexPath.section == 3 && indexPath.row == 1 {
            // Report a bug cell
            showMailComposeVC(with: "I found a bug", email: "feedback@dreamio.app", body: nil)
        }
        else if indexPath.section == 5 && indexPath.row == 0 {
            // Request Account Deletion
            guard let email = user.email else { return }
            showMailComposeVC(with: "Account Deletion", email: "support@dreamio.app", body: "I would like delete my account and all of my data. \n \n My email is: \(email)")
        }
    }
    
    func showMailComposeVC(with subject: String, email: String, body: String?) {
        if MFMailComposeViewController.canSendMail() {
            let mailComposer = MFMailComposeViewController()
            mailComposer.setSubject(subject)
            mailComposer.setToRecipients([email])
            if let content = body {
                mailComposer.setMessageBody(content, isHTML: false)
            }
            mailComposer.mailComposeDelegate = self
            present(mailComposer, animated: true, completion: nil)
           
        } else {
            SCLAlertView().showError("Hold on!", subTitle: "Since you have not configured your email in the settings app, please contact us with your request at support@dreamio.app")
        }
    }
    
    @IBAction func logoutTapped(_ sender: UIButton) {
        try! Auth.auth().signOut()
        if SecurityCheck.isFaceIDAvailable() || SecurityCheck.isTouchIdAvailable() {
            faceTouchIDSwitch.isEnabled = false
            UserDefaults.standard.set(false, forKey: DefaultsKeys.faceTouchIdState)
        }
    }
    
    func calculateDaysBetweenTwoDates(start: Date, end: Date) -> Int {
        
        let currentCalendar = Calendar.current
        guard let start = currentCalendar.ordinality(of: .day, in: .era, for: start) else {
            return 0
        }
        guard let end = currentCalendar.ordinality(of: .day, in: .era, for: end) else {
            return 0
        }
        return end - start
    }
    
    func showRateRequest() {
        guard let creationDate = Auth.auth().currentUser?.metadata.creationDate else { return }
        let today = Date()
        let result = calculateDaysBetweenTwoDates(start: creationDate, end: today)
        if result > 4 {
            // Ask for Rate
            SKStoreReviewController.requestReview()
        }
    }
    
    deinit {
        print("ProfileVC deinit")
    }
}

extension ProfileTVC : MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        if let error = error {
            SCLAlertView().showError("Error!", subTitle: error.localizedDescription)
            controller.dismiss(animated: true)
            return
        }
        switch result {
        case .cancelled:
            break
        case .failed:
            SCLAlertView().showError("Bummer!", subTitle: "Something went wrong. Please, try again.")
        case .saved:
            break
        case .sent:
            SCLAlertView().showSuccess("Success!", subTitle: "Your message was successfully sent! \n We'd get back to you if needed. \n Thank you!")
        }
        controller.dismiss(animated: true)
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
