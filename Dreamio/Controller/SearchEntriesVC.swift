//
//  SearchEntriesVC.swift
//  Dreamio
//
//  Created by Bold Lion on 25.04.19.
//  Copyright © 2019 Bold Lion. All rights reserved.
//

import UIKit
import SCLAlertView

class SearchEntriesVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var transferedLabel: String?
    var entries = [Entry]()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let label = transferedLabel else { return }
        navigationItem.title = "Entries for \(label)"
        setDelegates()
        fetchEntriesForLabel(label: label)
    }
    
    func fetchEntriesForLabel(label: String) {
        if let label = transferedLabel {
            activityIndicator.startAnimating()
            Api.Labels.fetchEntriesForLabel(label: label, onSuccess: { [unowned self] entry in
                self.entries.append(entry)
                self.tableView.reloadData()
                self.activityIndicator.stopAnimating()
            }, onError: { [unowned self] message in
                self.activityIndicator.stopAnimating()
                SCLAlertView().showError("Error", subTitle: message)
            })
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Segues.EntriesToCreateEntryVC {
            let navController = segue.destination as! UINavigationController
            var destinationVC = NewEntryVC()
            destinationVC = navController.viewControllers[0] as! NewEntryVC
            destinationVC.delegate = self
            if let entryToSend = sender as? Entry {
                destinationVC.entry = entryToSend
                destinationVC.notebookId = entryToSend.notebookId
            }
        }
    }
    
    deinit {
        print("SearchEntriesVC deinit")
    }
}


extension SearchEntriesVC: UITableViewDelegate, UITableViewDataSource {
    
    func setDelegates() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return entries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Cell_Id.entryTVCell) as! EntryTVCell
        cell.entry = entries[indexPath.row]
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let entry = entries[indexPath.row]
        self.performSegue(withIdentifier: Segues.EntriesToCreateEntryVC, sender: entry)
    }
}

extension SearchEntriesVC: EntryTVCellDelegate {
    func settingsFor(entry: Entry) {
        guard let id = entry.id else { return }
        guard let notebookId = entry.notebookId else { return }
        
        Alerts.showEntryMenu(
            viewAction: { [unowned self] in
                self.performSegue(withIdentifier: Segues.EntriesToCreateEntryVC, sender: entry) },
            editAction: { [unowned self] in
                self.performSegue(withIdentifier: Segues.EntriesToCreateEntryVC, sender: entry) },
            deleteAction: { [unowned self] in
                Alerts.showWarningAlertWithCancelAndCustomAction(title: "Delete Entry?", subTitle: "Are you sure you want to delete this entry? We cannot retrieve it once deleted.", actionTitle: "Yes", action: {
                    // 1. entries > entryUid > delete
                    Api.Entries.deleteEntryWithUid(uid: id, onSuccess: {
                        
                        // 2. notebook_entries > notebookUid > entryUid > delete
                        Api.Notebook_Entries.deleteEntryForNotebookWith(uid: notebookId, entryUid: id, onSuccess: { [unowned self] in
                            
                            // 3. entry_labels (fetch labels if the entry has any labels)
                            Api.Entry_Labels.fetchLabelsForEntryWith(uid: id, onSuccess: { label in
                                
                                // 3.1. There's at least 1 Label, so check the number of entryUid for the each label in Labels node
                                Api.Labels.deleteLabelForEntryWith(uid: id, label: label, onSuccess: { [unowned self] in
                                    self.entries = self.entries.filter({ $0.id != id })
                                    self.tableView.reloadData()
                                    }, deleteUserLabel: { [unowned self] in
                                        
                                        //3.2 delete the labe from user_labels node
                                        Api.User_Labels.deleteLabel(label: label, onSuccess: { [unowned self] in
                                            
                                            // 3.3 delete entry_labels entryUid
                                            Api.Entry_Labels.deleteEntryWith(id: id, onSuccess: { [unowned self] in
                                                self.entries = self.entries.filter({ $0.id != id })
                                                self.tableView.reloadData()
                                                }, onError: { error in
                                                    SCLAlertView().showError("Error", subTitle: error)
                                            })
                                            }, onError: { error in
                                                SCLAlertView().showError("Error", subTitle: error)
                                        })
                                    }, onError: { error in
                                        SCLAlertView().showError("Error", subTitle: error)
                                })
                            },
                                                                     // 3.2 Entry has NO labels{
                                onNoLabels: { [unowned self] in
                                    self.entries = self.entries.filter({ $0.id != id })
                                    self.tableView.reloadData()
                                }, onError: { error in
                                    SCLAlertView().showError("Error", subTitle: error)
                            })
                            }, onError: { error in
                                SCLAlertView().showError("Error", subTitle: error)
                        })
                    }, onError: { error in
                        SCLAlertView().showError("Error", subTitle: error)
                    })
                })
            }
        )
    }
}

extension SearchEntriesVC: NewEntrtVCDelegate {
    func fetchNewEntryWith(id: String) {
        Api.Entries.fetchEntryWith(uid: id, onSuccess: { [unowned self] entry in
            self.entries.insert(entry, at: 0)
            self.tableView.reloadData()
            }, onError: { message in
                SCLAlertView().showError("Oops!", subTitle: message)
        })
    }
}
