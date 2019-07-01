//
//  NotebookInfoVC.swift
//  Dreamio
//
//  Created by Bold Lion on 21.02.19.
//  Copyright © 2019 Bold Lion. All rights reserved.
//

import UIKit
import SCLAlertView

class NotebookInfoVC: UIViewController {

    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var createdOnLabel: UILabel!
    @IBOutlet weak var totalEntriesLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    
    var notebookId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchNotebookDetails()
         setUI()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        setUI()
    }
    
    func fetchNotebookDetails() {
        guard let uid = notebookId else { return }
        Api.Notebooks.fetchNotebookWith(uid: uid, onSuccess: { [unowned self] notebook in
            self.titleLabel.text = notebook.title
            if let creationTime = notebook.creationDate {
                self.createdOnLabel.text = self.convertIntToTime(number: creationTime)
            }
            Api.Notebook_Entries.fetchNotebookEntriesCount(forNotebookUid: uid, onSuccess: { [unowned self] entriesCount in
                self.totalEntriesLabel.text = String(entriesCount)
            }, onError: { error in
                SCLAlertView().showError("Error", subTitle: error)
            }, noEntries: { [unowned self] in
                 self.totalEntriesLabel.text = "0"
            })
        }, onError: { error in
            SCLAlertView().showError("Error", subTitle: error)
        })
    }
    
    func convertIntToTime(number: Int) -> String {
        let timeInterval = Double(number)
        let date = Date(timeIntervalSince1970: timeInterval)
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, YYYY"
        return formatter.string(from: date)
    }
    
    @IBAction func closeTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    func setUI() {
        headerView.backgroundColor = Colors.purpleDarker
        headerView.clipsToBounds = true
        backgroundView.layer.cornerRadius = 10
        backgroundView.clipsToBounds = true
        
        closeButton.backgroundColor = Colors.purpleDarker
        closeButton.clipsToBounds = true
        closeButton.layer.cornerRadius = 10
        closeButton.tintColor = .white
    }
    
    deinit {
        print("NotebookInfoVC deinit")
    }
}
