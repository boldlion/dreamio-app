//
//  NewEntryVC.swift
//  Dreamio
//
//  Created by Bold Lion on 4.03.19.
//  Copyright © 2019 Bold Lion. All rights reserved.
//

import UIKit
import SCLAlertView

protocol NewEntrtVCDelegate: AnyObject {
    func fetchNewEntryWith(id: String)
}

class NewEntryVC: UIViewController {
    @IBOutlet weak var entryContentUITextView: UITextView!
    @IBOutlet weak var entryTitleTextView: UITextView!
    @IBOutlet weak var titleHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var contentBottomConstraint: NSLayoutConstraint!
    
    var titlePlaceholder : UILabel!
    var contentPlaceholder: UILabel!
    var notebookId: String?
    var entry: Entry?
    var entryId: String?
    lazy var labels: [String] = {
        let labels = [String]()
        return labels
    }()
    var hasLabels = false
    var updatedLabels: [String]?
    
    weak var delegate: NewEntrtVCDelegate?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        populateEntryFields()
        saveButton.isEnabled = false
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        NavBar.setGradientNavigationBar(for: navigationController)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       // createToolbar()
        setTextViewsDelegates()
    }
    
    func populateEntryFields() {
        if let uid = entryId {
            fetchEntryWith(uid: uid)
        }
        if let title = entry?.title, let content = entry?.content {
            entryTitleTextView.text = title
            entryContentUITextView.text = content
            setupTitleTextViewPlaceholder()
            setupContentTextViewPlaceholder()
            textViewDidChange(entryTitleTextView)
            textViewDidChange(entryContentUITextView)
            navigationItem.title = "Edit & View Entry"
        }
        if let entryUid = entry?.id {
            fetchLabelsForEntryWith(uid: entryUid)
        }
    }
    
    func fetchLabelsForEntryWith(uid: String) {
        Api.Entry_Labels.fetchAllLabelsForEntryWith(uid: uid,
            onSuccess: { [unowned self] labels in
                self.labels = labels
                self.createToolbar()
            }, onNoLabels: { [unowned self] in
                self.labels = []
                self.createToolbar()
            }, onError: { errorMessage in
                 SCLAlertView().showError("Error", subTitle: errorMessage)
        })
    }
    
    func fetchEntryWith(uid: String) {
        Api.Entries.fetchEntryWith(uid: uid,
            onSuccess: { [unowned self] entry in
                self.entry = entry
                self.entryId = nil
                self.populateEntryFields() },
            onError: { errorMessage in
                SCLAlertView().showError("Error", subTitle: errorMessage)
        })
    }
    
    func createToolbar() {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        toolBar.barTintColor = .white
        toolBar.tintColor = Colors.purpleDarker
        
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(dismissKeyboard))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        
        var imageName = ""
        
        if let updated = updatedLabels {
            imageName = updated.count > 0 ? "label_selected" :  "label_empty"
        }
        else {
            imageName = labels.count > 0 ? "label_selected" : "label_empty"
        }

        let labelButton = UIBarButtonItem(image: UIImage(named: imageName), style: .plain, target: self, action: #selector(goToLabelsVC))
        toolBar.isUserInteractionEnabled = true
        toolBar.items = [labelButton, flexibleSpace, doneButton]
        entryTitleTextView.inputAccessoryView = toolBar
        entryContentUITextView.inputAccessoryView = toolBar
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func goToLabelsVC() {
        view.endEditing(true)
        var labelsToSend = [String]()
        if let updated = updatedLabels, updated.count >= 0 {
            labelsToSend = updated
        }
        else {
            labelsToSend = labels
        }
        performSegue(withIdentifier: Segues.NewEntryToLabelsVC, sender: labelsToSend)
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            UIView.animate(withDuration: 0.2, animations: { [unowned self] in
                self.contentBottomConstraint.constant = keyboardSize.height
                self.view.layoutIfNeeded()
            })
        }
    }
    @objc func keyboardWillHide(notification: Notification) {
        UIView.animate(withDuration: 0.2, animations: { [unowned self] in
            self.contentBottomConstraint.constant = 20
            self.view.layoutIfNeeded()
        })
    }
    
    @IBAction func cancelTapped(_ sender: UIBarButtonItem) {
        view.endEditing(true)
        if saveButton.isEnabled {
            
            Alerts.showWarningWithTwoCustomActions(title: "Wait!", subtitle: "You haven't saved your dream entry. Tap on SAVE button or dismiss it. You can always edit your entry.", dismissTitle: "Dismiss",
                dismissAction: { [unowned self]  in
                    self.clear()
                    self.dismiss(animated: true)
                },
                customAction2: {  [unowned self] in
                    self.saveEntry()
                },
                action2Title: "Save")
        }
        else {
            clear()
            dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func saveTapped(_ sender: UIBarButtonItem) {
        saveEntry()
    }
    
    func saveEntry() {
        view.endEditing(true)
        saveButton.isEnabled = !saveButton.isEnabled
        if notebookId != nil {
            guard let title = entryTitleTextView.text else { return }
            guard let content = entryContentUITextView.text else { return }
            guard let notebId = notebookId else { return }
            if entry != nil {
                guard let entryId = entry?.id else { return }
                updateDreamEntry(notebookId: notebId, entryId: entryId, title: title, content: content)
            }
            else {
                createNewEntry(notebookId: notebId, title: title, content: content)
            }
        }
        else {
            performSegue(withIdentifier: Segues.NewEntryToSelectNotebookVC, sender: nil)
        }
    }
    
    func success(alert: SCLAlertViewResponder, entryId: String) {
        alert.close()
        self.delegate?.fetchNewEntryWith(id: entryId)
        self.clear()
        self.dismiss(animated: true)
    }
    
    func createNewEntry(notebookId: String, title: String, content: String) {
        guard let entryID = Api.Entries.REF_ENTRIES.childByAutoId().key else { return }
        let alert = SCLAlertView().showWait("Saving...", subTitle: "Please wait...")
        // NOTE: Entry with labels
        if labels.count > 0 {
            Api.Entries.saveEntry(forNotebookUid: notebookId, entryUid: entryID, title: title, content: content,
                onSuccess: { [unowned self]  in
                    Api.Labels.doesLabelExistAlready(labels: self.labels,
                        onExist: { label in
                            Api.Labels.addNewEntryIdForLabel(label: label, entryId: entryID,
                                onSuccess: {
                                    Api.Entry_Labels.saveEntryLabelsWith(entryUid: entryID, labels: [label],
                                        onSuccess: {
                                            Api.Entries_Timestamp.setEntryTimestampFor(notebookWith: notebookId, entryId: entryID,
                                                onSuccess: { [unowned self] in
                                                    self.success(alert: alert, entryId: entryID) },
                                                onError: { [unowned self] message in
                                                    self.updateErrorBlock(alert: alert, message: message) }) },
                                        onError: { [unowned self] message in
                                            self.updateErrorBlock(alert: alert, message: message)  }) },
                                onError: { [unowned self] message in
                                    self.updateErrorBlock(alert: alert, message: message) }) },
                        onDoesntExist: { label in
                            Api.Labels.addNewLabel(label: label, entryId: entryID,
                                onSuccess: {
                                    Api.Entry_Labels.saveEntryLabelsWith(entryUid: entryID, labels: [label],
                                            onSuccess: {
                                                Api.User_Labels.updateLabels(labels: [label],
                                                    onSuccess: {
                                                        Api.Entries_Timestamp.setEntryTimestampFor(notebookWith: notebookId, entryId: entryID,
                                                            onSuccess: { [unowned self] in
                                                                self.success(alert: alert, entryId: entryID) },
                                                            onError: { [unowned self] message in
                                                                self.updateErrorBlock(alert: alert, message: message) }) },
                                                    onError: { [unowned self] message in
                                                        self.updateErrorBlock(alert: alert, message: message) }) },
                                            onError: { [unowned self] message in
                                                self.updateErrorBlock(alert: alert, message: message) }) },
                                onError: { [unowned self] message in
                                    self.updateErrorBlock(alert: alert, message: message) }) },
                        onError: { [unowned self] message in
                            self.updateErrorBlock(alert: alert, message: message) }) },
                onError: { [unowned self] message in
                    self.updateErrorBlock(alert: alert, message: message)
            })
        }
        // NOTE: Entry without labels
        else {
            Api.Entries.saveEntry(forNotebookUid: notebookId, entryUid: entryID, title: title, content: content,
                onSuccess: { [unowned self] in
                    Api.Entries_Timestamp.setEntryTimestampFor(notebookWith: notebookId, entryId: entryID,
                        onSuccess: { [unowned self, alert] in
                            self.success(alert: alert, entryId: entryID) },
                        onError: { [unowned self] message in
                            self.updateErrorBlock(alert: alert, message: message) }) },
                onError: { [unowned self] message in
                    self.updateErrorBlock(alert: alert, message: message)
            })
        }
    }
    
    func updateErrorBlock(alert: SCLAlertViewResponder, message: String) {
        alert.close()
        saveButton.isEnabled = true
        SCLAlertView().showError("Oh, Bummer!", subTitle: message)
    }
    
    // MARK:- Updated Dream Entry
    func updateDreamEntry(notebookId: String, entryId: String, title: String, content: String) {
        let alert = SCLAlertView().showWait("Saving...", subTitle: "Please wait...")
        if labels.isEmpty && updatedLabels == nil {
            // NOTE: The entry simply has no labels - Update Entry with title and content only
            Api.Entries.updateEntryWithUid(uid: entryId, title: title, content: content,
                onSuccess: { [unowned self, alert] in
                    self.success(alert: alert, entryId: entryId) },
                onError: { [unowned self] message in
                    self.updateErrorBlock(alert: alert, message: message)
            })
        }
        else if labels.isEmpty && updatedLabels != nil {
            //NOTE:  User just added labels to the entry
            guard let updatedL = updatedLabels else { return }
            Api.Labels.doesLabelExistAlready(labels: updatedL,
                onExist: { label in
                    Api.Labels.addNewEntryIdForLabel(label: label, entryId: entryId,
                        onSuccess: {
                            Api.Entry_Labels.saveEntryLabelsWith(entryUid: entryId, labels: [label],
                                onSuccess: {
                                    Api.Entries_Timestamp.setEntryTimestampFor(notebookWith: notebookId, entryId: entryId,
                                        onSuccess: { [unowned self] in
                                            self.success(alert: alert, entryId: entryId) },
                                        onError: { [unowned self] message in
                                            self.updateErrorBlock(alert: alert, message: message) }) },
                                onError: { [unowned self] message in
                                    self.updateErrorBlock(alert: alert, message: message) }) },
                        onError: { [unowned self] message in
                            self.updateErrorBlock(alert: alert, message: message) }) },
                onDoesntExist: { label in
                    Api.Labels.addNewLabel(label: label, entryId: entryId,
                        onSuccess: {
                            Api.Entry_Labels.saveEntryLabelsWith(entryUid: entryId, labels: [label],
                                onSuccess: {
                                    Api.User_Labels.updateLabels(labels: [label],
                                        onSuccess: {
                                            Api.Entries_Timestamp.setEntryTimestampFor(notebookWith: notebookId, entryId: entryId,
                                                onSuccess: { [unowned self] in
                                                    self.success(alert: alert, entryId: entryId) },
                                                onError: { [unowned self] message in
                                                    self.updateErrorBlock(alert: alert, message: message) }) },
                                        onError: { [unowned self] message in
                                            self.updateErrorBlock(alert: alert, message: message) }) },
                                onError: { [unowned self] message in
                                    self.updateErrorBlock(alert: alert, message: message) }) },
                        onError: { [unowned self] message in
                            self.updateErrorBlock(alert: alert, message: message) }) },
                onError: { [unowned self] message in
                    self.updateErrorBlock(alert: alert, message: message)
            })
        }
        else if !labels.isEmpty && updatedLabels != nil {
            // NOTE: Entry has existing labels but the user might have changed them (they might be the same, deleted or added more)
            guard let updatedLbls = updatedLabels else { return }
            if labels.containsSameElement(as: updatedLbls) {
                // Labels & Updated labels are the same, proceed to just update the title & content only
                Api.Entries.updateEntryWithUid(uid: entryId, title: title, content: content,
                    onSuccess: { [unowned self] in
                        self.success(alert: alert, entryId: entryId) },
                    onError: { [unowned self] message in
                        self.updateErrorBlock(alert: alert, message: message)
                })
            }
            else {
                // Labels are different ... see if they deleted or added labels and if it even have labels (LABELS ARE DEF NOT THE SAME!)
                if labels.count > updatedLbls.count || labels.count == updatedLbls.count || updatedLbls.count > labels.count {
                    // User Deleted Labels - remove deleted labels from database & update the labels based on updatedLabels elements
                    let possibleLabelsToDelete = Array(Set(labels).subtracting(updatedLbls))
                    if possibleLabelsToDelete.count > 0 {
                        for label in possibleLabelsToDelete {
                            Api.Labels.deleteLabelForEntryWith(uid: entryId, label: label,
                                onSuccess: { [unowned self] in
                                    Api.Entry_Labels.deleteLabelForEntryWith(id: entryId, label: label,
                                        onSuccess: {
                                            self.updateLabelsAndEntryFor(entryId: entryId, title: title, content: content,
                                                onSuccess: { [unowned self] in
                                                    self.success(alert: alert, entryId: entryId) },
                                                onError: { [unowned self] message in
                                                    self.updateErrorBlock(alert: alert, message: message) }) },
                                        onError: {[unowned self] message in
                                            self.updateErrorBlock(alert: alert, message: message) }) },
                                deleteUserLabel: {
                                    Api.User_Labels.deleteLabel(label: label,
                                        onSuccess: { [unowned self] in
                                            self.updateLabelsAndEntryFor(entryId: entryId, title: title, content: content,
                                                onSuccess: { [unowned self] in
                                                    self.success(alert: alert, entryId: entryId) },
                                                onError: { [unowned self] message in
                                                    self.updateErrorBlock(alert: alert, message: message) }) },
                                        onError: { [unowned self] message in
                                            self.updateErrorBlock(alert: alert, message: message) }) },
                                onError: { [unowned self] message in
                                    self.updateErrorBlock(alert: alert, message: message)
                            })
                        }
                    }
                    else {
                        // No Old Labels To delete - proceed to save new updated labels
                        updateLabelsAndEntryFor(entryId: entryId, title: title, content: content,
                            onSuccess: { [unowned self] in
                                self.success(alert: alert, entryId: entryId) },
                            onError: { [unowned self] message in
                                self.updateErrorBlock(alert: alert, message: message)
                        })
                    }
                }
            }
        }
    }
    
    func updateLabelsAndEntryFor(entryId: String, title: String, content: String, onSuccess: @escaping () -> Void, onError: @escaping (_ message: String) -> Void) {
        if let updatedL = updatedLabels, updatedL.count == 0 {
            // User deleted all labels and there are no new ones, Update only Entry details
            Api.Entries.updateEntryWithUid(uid: entryId, title: title, content: content,
                onSuccess: {
                    onSuccess() },
                onError: { message in
                    onError(message)
                    return
            })
        }
        else {
            guard let updatedL = updatedLabels else { return }
            // Update /labels & /entry_labels & entry
            Api.Entries.updateEntryWithUid(uid: entryId, title: title, content: content,
                onSuccess: {
                    Api.Labels.doesLabelExistAlready(labels: updatedL,
                        onExist: { label in
                            Api.Labels.addNewEntryIdForLabel(label: label, entryId: entryId,
                                onSuccess: {
                                    Api.Entry_Labels.saveEntryLabelsWith(entryUid: entryId, labels: [label],
                                         onSuccess: {
                                            onSuccess() },
                                         onError: { message in
                                            onError(message)
                                            return }) },
                                onError: { message in
                                    onError(message)
                                    return }) },
                        onDoesntExist: { label in
                           Api.Labels.addNewLabel(label: label, entryId: entryId,
                                onSuccess: {
                                    Api.Entry_Labels.saveEntryLabelsWith(entryUid: entryId, labels: [label],
                                        onSuccess: {
                                            Api.User_Labels.updateLabels(labels: [label],
                                                onSuccess: {
                                                    onSuccess() },
                                                onError: { message in
                                                    onError(message)
                                                    return }) },
                                        onError: { message in
                                            onError(message)
                                            return }) },
                                onError: { message in
                                    onError(message)
                                    return }) },
                        onError: { message in
                            onError(message)
                            return }) },
                onError: { message in
                    onError(message)
            })
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Segues.NewEntryToSelectNotebookVC {
            let destinationVC = segue.destination as! SelectNotebookVC
            destinationVC.delegate = self
        }
        if segue.identifier == Segues.NewEntryToLabelsVC {
            let navController = segue.destination as! UINavigationController
            var destinationVC = LabelsVC()
            destinationVC = navController.viewControllers[0] as! LabelsVC
            if let updatedL = updatedLabels, updatedL.count >= 0 {
                destinationVC.labels = updatedL
            }
            else if labels.count >= 1 {
                destinationVC.labels = labels
            }
            destinationVC.delegate = self
        }
    }
    
    func clear() {
        updatedLabels?.removeAll()
        labels.removeAll()
    }
    
    deinit {
        print("NewEntryVC deinit")
    }
}


extension NewEntryVC: UITextViewDelegate {
    
    @objc func changeSaveButtonState() {
        guard let updated = updatedLabels
            else {
            // NO UPDATED LABELS
            if !entryTitleTextView.text.isEmpty, entryTitleTextView.text != "", let content = entryContentUITextView.text, !content.isEmpty, content != "" {
                saveButton.isEnabled = true
                return
            }
            else {
                saveButton.tintColor = UIColor.lightGray
                saveButton.isEnabled = false
            }
            return
        }
        // UPDATED LABELS
        if !labels.containsSameElement(as: updated) || !entryTitleTextView.text.isEmpty, entryTitleTextView.text != "", let content = entryContentUITextView.text, !content.isEmpty, content != "" {
            saveButton.isEnabled = true
            return
        }
        else {
            saveButton.tintColor = UIColor.lightGray
            saveButton.isEnabled = false
        }
    }
    
    func setTextViewsDelegates() {
        entryTitleTextView.delegate = self
        entryContentUITextView.delegate = self
        setupTitleTextViewPlaceholder()
        setupContentTextViewPlaceholder()
    }
    
    func setupTitleTextViewPlaceholder() {
        titlePlaceholder = UILabel()
        titlePlaceholder.text = "Dream title"
        titlePlaceholder.textAlignment = .center
        titlePlaceholder.sizeToFit()
        entryTitleTextView.addSubview(titlePlaceholder)
        titlePlaceholder.frame.origin = CGPoint(x: 5, y: (entryTitleTextView.font?.pointSize)! / 2)
        titlePlaceholder.textColor = UIColor.lightGray
        titlePlaceholder.isHidden = !entryTitleTextView.text.isEmpty
    }
    
    func setupContentTextViewPlaceholder() {
        contentPlaceholder = UILabel()
        contentPlaceholder.text = "Enter dream content"
        contentPlaceholder.sizeToFit()
        entryContentUITextView.addSubview(contentPlaceholder)
        contentPlaceholder.frame.origin = CGPoint(x: 5, y: (entryContentUITextView.font?.pointSize)! / 2)
        contentPlaceholder.textColor = UIColor.lightGray
        contentPlaceholder.isHidden = !entryContentUITextView.text.isEmpty
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView == entryTitleTextView {
            titlePlaceholder.isHidden = !entryTitleTextView.text.isEmpty
            let size = CGSize(width: entryTitleTextView.bounds.width, height: .infinity)
            let estimatedSize = entryTitleTextView.sizeThatFits(size)
            if estimatedSize.height >= 120 {
                titleHeightConstraint.constant = 120
                entryTitleTextView.isScrollEnabled = true
            }
            else {
                entryTitleTextView.isScrollEnabled = false
                titleHeightConstraint.constant = estimatedSize.height
//                let style = NSMutableParagraphStyle()
//                style.lineSpacing = 20
//                let attributes = [NSAttributedString.Key.paragraphStyle : style]
//                entryTitleTextView.attributedText = NSAttributedString(string: textView.text, attributes: attributes)
            }
        }
        else if textView == entryContentUITextView {
            contentPlaceholder.isHidden = !entryContentUITextView.text.isEmpty
        }
        
        guard let title = entryTitleTextView.text, !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              let content = entryContentUITextView.text, !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            else {
                saveButton.tintColor = UIColor.lightGray
                saveButton.isEnabled = false
                return
        }
        saveButton.isEnabled = true
        saveButton.tintColor = .white
    }
}
extension NewEntryVC: SelectNotebookDelegate {
    func setNotebookIdForEntry(notebookId: String) {
        self.notebookId = notebookId
    }
}

extension NewEntryVC: LabelsVCDelegate {
    func transferedLabels(labels: [String]) {
        if entry == nil {
            // New Entry - Initial Label setting
             self.labels = labels
        }
        else {
            // Existing Entry - Update on Labels
            updatedLabels = labels
        }
        changeSaveButtonState()
    }
}
