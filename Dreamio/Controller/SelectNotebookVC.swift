//
//  SelectNotebookVC.swift
//  Dreamio
//
//  Created by Bold Lion on 5.03.19.
//  Copyright © 2019 Bold Lion. All rights reserved.
//

import UIKit
import SCLAlertView

protocol SelectNotebookDelegate: class {
    func setNotebookIdForEntry(notebookId: String)
}

class SelectNotebookVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var headerLabel: UILabel!
    
    var notebooks = [Notebook]()
    var selectedNotebookId: String?
    weak var delegate: SelectNotebookDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTableViewDelegates()
        fetchUserNotebooks()
        setUI()
        setButtonsUI()
    }
    
    func fetchUserNotebooks() {
        Api.User_Notebooks.fetchUserNotebooksForCurrentUser(onSuccess: { [unowned self] notebook in
            self.notebooks.append(notebook)
            self.tableView.reloadData()
        }, onError: { errorMessage in
            SCLAlertView().showError("Error", subTitle: errorMessage)
        })
    }
    
    @IBAction func saveTapped(_ sender: UIButton) {
        if selectedNotebookId != nil {
            guard let id = selectedNotebookId else { return }
            delegate?.setNotebookIdForEntry(notebookId: id)
            dismiss(animated: true)
        }
    }
    
    @IBAction func cancelTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    func setUI() {
        headerView.clipsToBounds = true
        headerView.layer.cornerRadius = 5
        headerView.setGradientBackground(colorOne: Colors.purpleDarker, colorTwo: Colors.purpleLight)
        headerView.layer.maskedCorners =  [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        headerLabel.textColor = .white
        
        tableView.layer.cornerRadius = 5
        tableView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
    }
    
    func setButtonsUI() {
        cancelButton.setTitleColor(.white, for: .normal)
        saveButton.isEnabled = false
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.setTitleColor(.lightGray, for: .disabled)
    }
    
    
    deinit {
        print("SelectNotebookVC deinit")
    }
}

extension SelectNotebookVC : UITableViewDataSource, UITableViewDelegate {
    
    func setTableViewDelegates() {
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notebooks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Cell_Id.selectNotebookTVCell) as! SelectNotebookTVCell
        cell.notebook = notebooks[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        if let id = notebooks[indexPath.row].id {
            selectedNotebookId = id
            saveButton.isEnabled = true
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = .none
        selectedNotebookId = nil
        saveButton.isEnabled = false
    }
}
