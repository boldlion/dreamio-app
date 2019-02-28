//
//  RenameNotebookVC.swift
//  Dreamio
//
//  Created by Bold Lion on 26.02.19.
//  Copyright © 2019 Bold Lion. All rights reserved.
//

import UIKit
import SVProgressHUD

protocol RenameNotebookVCDelegate {
    func refetchNotebooks()
}

class RenameNotebookVC: UIViewController {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    var delegate: RenameNotebookVCDelegate?
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
    
    @IBAction func saveTapped(_ sender: UIButton) {
        guard let title = titleTextField.text else { return }
        guard let id = notebookId else { return }
        view.endEditing(true)
        SVProgressHUD.show(withStatus: "Saving....")
        if title != "" {
            Api.Notebooks.renameNotebook(withId: id, title: title, onSuccess: { [unowned self] in
                SVProgressHUD.showSuccess(withStatus: "Notebook Successfully Renamed!")
                self.delegate?.refetchNotebooks()
                self.dismiss(animated: true)
            }, onError: { error in
                SVProgressHUD.showError(withStatus: error)
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
