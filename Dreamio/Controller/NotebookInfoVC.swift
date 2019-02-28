//
//  NotebookInfoVC.swift
//  Dreamio
//
//  Created by Bold Lion on 21.02.19.
//  Copyright © 2019 Bold Lion. All rights reserved.
//

import UIKit
import SVProgressHUD

class NotebookInfoVC: UIViewController {

    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var createdOnLabel: UILabel!
    @IBOutlet weak var lastEntryLabel: UILabel!
    @IBOutlet weak var totalEntriesLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    
    var notebookId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchNotebookDetails()
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
            // TODO: Fetch total entries
            self.totalEntriesLabel.text = "0"
            //TODO: Fetch last entry date
            self.lastEntryLabel.text = "N/A"
            
        }, onError: { error in
            SVProgressHUD.showError(withStatus: error)
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
        headerView.setGradientBackground(colorOne: Colors.purpleDarker, colorTwo: Colors.purpleLight)
        headerView.clipsToBounds = true
        backgroundView.layer.cornerRadius = 10
        backgroundView.clipsToBounds = true
        
        closeButton.layer.borderColor = Colors.purpleDarker.cgColor
        closeButton.clipsToBounds = true
        closeButton.layer.borderWidth = 2
        closeButton.layer.cornerRadius = 10
        closeButton.tintColor = Colors.purpleDarker
        
    }
}
