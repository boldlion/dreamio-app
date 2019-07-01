//
//  LabelsVC.swift
//  Dreamio
//
//  Created by Bold Lion on 12.03.19.
//  Copyright © 2019 Bold Lion. All rights reserved.
//

import UIKit

protocol LabelsVCDelegate: AnyObject  {
    func transferedLabels(labels: [String])
}

class LabelsVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    var labels = [String]()
    
    weak var delegate: LabelsVCDelegate?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTableViewdelegates()
        tableView.register(AddLabelsTVCell.self, forCellReuseIdentifier: Cell_Id.addLabelsTVCell)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        NavBar.setGradientNavigationBar(for: navigationController)
    }
    
    @IBAction func saveTapped(_ sender: UIBarButtonItem) {
        delegate?.transferedLabels(labels: labels)
        dismiss(animated: true)
        labels.removeAll()
    }
    
    @IBAction func cancelTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
    // To avoid issues with parsing DB with numbers
    func stringRepresentationOfNumbers(label: String) -> String {
        switch label {
        case "0":
            return "zero"
        case "1":
            return "one"
        case "2":
            return "two"
        case "3":
            return "three"
        case "4":
            return "four"
        case "5":
            return "five"
        default:
            return label
        }
    }
    
    deinit {
        print("LabelsVC deinit")
    }
}

extension LabelsVC: UITableViewDelegate, UITableViewDataSource {
    
    func setTableViewdelegates() {
        tableView.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Cell_Id.addLabelsTVCell) as! AddLabelsTVCell
        if labels.count >= 1 {
            cell.labelsField.addTags(labels)
        }
        cell.delegate = self
        return cell
    }
}

extension LabelsVC: AddLabelsTVCellDelegate {
    func onDidAddTag(label: String) {
        let trimmedLabel = (label.trimmingCharacters(in: .whitespacesAndNewlines)).lowercased()
        let labelToAdd = stringRepresentationOfNumbers(label: trimmedLabel)
        labels.append(labelToAdd)
        //changeSaveButtonStatus()
    }
    
    func onDidRemoveTag(label: String) {
        labels = labels.filter({ $0 != label })
       // changeSaveButtonStatus()
    }
    
    func onDidChangeHeightTo() {
        tableView?.beginUpdates()
        tableView?.endUpdates()
    }
}
