//
//  RenameNotebookVC.swift
//  Dreamio
//
//  Created by Bold Lion on 26.02.19.
//  Copyright © 2019 Bold Lion. All rights reserved.
//

import UIKit
import SCLAlertView

protocol RenameNotebookVCDelegate: AnyObject {
    func refetchNotebooks()
}

class RenameNotebookVC: UIViewController {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    weak var delegate: RenameNotebookVCDelegate?
    var notebookId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTextFieldDelegates()
        handleTextField()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setUI()
    }
    
    func postNotificationNotebookWith(uid: String, newTitle: String) {
        // POST NOTIFICATION
        let name = Notification.Name(rawValue: NotificationKey.notebookRenamed)
        let dict = ["uid" : uid, "title": newTitle]
        NotificationCenter.default.post(name: name, object: nil, userInfo: dict)
    }
    
    @IBAction func saveTapped(_ sender: UIButton) {
        guard let title = titleTextField.text else { return }
        guard let id = notebookId else { return }
        view.endEditing(true)
        if title != "" {
            Api.Notebooks.renameNotebook(withId: id, title: title, onSuccess: { [unowned self] in
                SCLAlertView().showSuccess("Success!", subTitle: "Notebook Successfully Renamed!")
                self.postNotificationNotebookWith(uid: id, newTitle: title)
                self.delegate?.refetchNotebooks()
                self.dismiss(animated: true)
            }, onError: { error in
                SCLAlertView().showError("Error!", subTitle: error)
            })
        }
    }
    
    @IBAction func cancelTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    func setUI() {
        containerView.layer.cornerRadius = 10
        containerView.clipsToBounds = true
        headerView.clipsToBounds = true
        headerView.setGradientBackground(colorOne: Colors.purpleDarker, colorTwo: Colors.purpleLight)
    }
    
    deinit {
        print("RenameNotebookVC deinit")
    }
}

extension RenameNotebookVC: UITextFieldDelegate {
    
    func setupTextFieldDelegates() {
        titleTextField.delegate = self
        saveButton.isEnabled = false
    }
    
    func handleTextField() {
        titleTextField.addTarget(self, action: #selector(textfieldDidChange), for: .editingChanged)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc func textfieldDidChange () {
        guard let title = titleTextField.text, !title.isEmpty
            else {
                saveButton.isEnabled = false
                return
        }
        saveButton.isEnabled = true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}
