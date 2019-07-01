//
//  LibraryVC.swift
//  Dreamio
//
//  Created by Bold Lion on 19.02.19.
//  Copyright © 2019 Bold Lion. All rights reserved.
//

import UIKit
import SCLAlertView

class NotebookVC: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var notebooks = [Notebook]()
    weak var lastFlippedNotebook: NotebookCell?
    var defaultNotebookId: String?
    var isDefault: Bool?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionViewDelegates()
        fetchNotebooks()
        collectionView.isPrefetchingEnabled = true
        NavBar.setGradientNavigationBar(for: navigationController)
        
    }
    
    func fetchNotebooks() {
        activityIndicator.startAnimating()
        notebooks.removeAll()
        Api.User_Notebooks.fetchAllNotebooksForCurrentUser(onSuccess: { [unowned self] notebooks in
            for notebook in notebooks {
                guard let status = notebook.isDefault else { return }
                guard let id = notebook.id else { return }
                if status == "yes" {
                    self.defaultNotebookId = id
                    self.isDefault = true
                    self.notebooks.insert(notebook, at: 0)
                }
                else {
                    self.notebooks.append(notebook)
                }
            }
            self.activityIndicator.stopAnimating()
            self.collectionView.reloadData()

        }, onError: { [unowned self] errMessage in
            self.activityIndicator.stopAnimating()
            SCLAlertView().showError("Something went wrong...", subTitle: errMessage)
        })
    }
    
    @IBAction func addNewBook(_ sender: Any) {
        performSegue(withIdentifier: Segues.NotebookVCToCreateNotebook, sender: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Segues.NotebooksToNotebookInfo {
            let destinationVC = segue.destination as! NotebookInfoVC
            let notebookId = sender as! String
            destinationVC.notebookId = notebookId
        }
        if segue.identifier == Segues.NotebookVCToCreateNotebook {
            let destinationVC = segue.destination as! CreateNotebook
            destinationVC.delegate = self
        }
        if segue.identifier == Segues.NotebooksToRenameNotebookVC {
            let destinationVC = segue.destination as! RenameNotebookVC
            let notebookId = sender as!  String
            destinationVC.delegate = self
            destinationVC.notebookId = notebookId
        }
        if segue.identifier == Segues.NotebookVCToUpdateNotebookCoverVC {
            let destinationVC = segue.destination as! UpdateNotebookCoverVC
            let notebookId = sender as! String
            destinationVC.delegate = self
            destinationVC.notebookId = notebookId
        }
    }
    
    deinit {
        print("NotebookVC deinit")
    }
}

extension NotebookVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionViewDelegates() {
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return notebooks.count
    }
    
    func collectionView(_ collectionView: UICollectionView,  cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Cell_Id.notebook, for: indexPath) as! NotebookCell
        cell.notebook = notebooks[indexPath.row]
        cell.delegate = self
        cell.flipNotebookDelegate = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let notebookId = notebooks[indexPath.row].id else { return }
        postNotificationForChangedNotebookWith(uid: notebookId, key: NotificationKey.notebookIdTapped)
        tabBarController?.selectedIndex = 0
    }
}

extension NotebookVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat =  40
        let collectionViewSize = collectionView.frame.size.width - padding
        return CGSize(width: collectionViewSize/2, height: collectionViewSize/2 * 1.33)
    }
}

extension NotebookVC : NotebookCellDelegate {
    func setNotebookAsDefault(with notebook: Notebook) {
        guard let selectedNotebookStatus = notebook.isDefault else { return }
        guard let selectedNotebookId = notebook.id else { return }
        if isDefault != nil && isDefault == true {
            guard let previousDefaultId = defaultNotebookId else { return }
            if previousDefaultId == selectedNotebookId {
                if selectedNotebookStatus == "yes" {
                    SCLAlertView().showWarning("Hold on!", subTitle: "To change the default notebook status, please set another notebook as default.")
                }
                else {
                    Api.Notebooks.setAsDefaultNotebook(forNotebookId: selectedNotebookId, onSuccess: { [unowned self] in
                        for (index, noteb) in self.notebooks.enumerated() {
                            guard let tempNotebookId = noteb.id else { return }
                            if selectedNotebookId == tempNotebookId {
                                self.notebooks[index].isDefault = "yes"
                                self.defaultNotebookId = tempNotebookId
                                self.isDefault = true
                                self.collectionView.performBatchUpdates({ [unowned self] in
                                    let indexSet = IndexSet(integersIn: 0...0)
                                    self.postNotificationWithKey(key: NotificationKey.notebookDefaultChanged)
                                    self.collectionView.reloadSections(indexSet)
                                })
                            }
                        }
                    }, onError: { error in
                        SCLAlertView().showError("Error", subTitle: error)
                    })
                }
            }
            else {
                Api.Notebooks.removeDefaultNotebookStatus(forNotebookId: previousDefaultId, onSuccess: { [unowned self] in
                    Api.Notebooks.setAsDefaultNotebook(forNotebookId: selectedNotebookId, onSuccess: { [unowned self] in
                        for (index, noteb) in self.notebooks.enumerated() {
                            guard let tempNotebookId = noteb.id else { return }
                            if previousDefaultId == tempNotebookId {
                                self.notebooks[index].isDefault = "no"
                            }
                            if selectedNotebookId == tempNotebookId {
                                self.notebooks[index].isDefault = "yes"
                                self.defaultNotebookId = tempNotebookId
                                self.isDefault = true
                                let moveNotebookToTheBeginning = self.notebooks.remove(at: index)
                                self.notebooks.insert(moveNotebookToTheBeginning, at: 0)
                                self.collectionView.performBatchUpdates({ [unowned self] in
                                    let indexSet = IndexSet(integersIn: 0...0)
                                    self.postNotificationWithKey(key: NotificationKey.notebookDefaultChanged)
                                    self.collectionView.reloadSections(indexSet)
                                })
                            }
                        }
                    }, onError: {  error in
                        SCLAlertView().showError("Error", subTitle: error)
                    })
                }, onError: { error in
                    SCLAlertView().showError("Error", subTitle: error)
                })
            }
        }
        else {
            Api.Notebooks.setAsDefaultNotebook(forNotebookId: selectedNotebookId, onSuccess: { [unowned self] in
                for (index, noteb) in self.notebooks.enumerated() {
                    guard let tempNotebookId = noteb.id else { return }
                    if selectedNotebookId == tempNotebookId {
                        self.notebooks[index].isDefault = "yes"
                        self.defaultNotebookId = tempNotebookId
                        self.isDefault = true
                        let moveNotebookToTheBeginning = self.notebooks.remove(at: index)
                        self.notebooks.insert(moveNotebookToTheBeginning, at: 0)
                        self.collectionView.performBatchUpdates({ [unowned self] in
                            let indexSet = IndexSet(integersIn: 0...0)
                            self.postNotificationWithKey(key: NotificationKey.notebookDefaultChanged)
                            self.collectionView.reloadSections(indexSet)
                        })
                    }
                }
            }, onError: { error in
                SCLAlertView().showError("Error", subTitle: error)
            })
        }
    }
    
    func deleteNotebook(with id: String) {
        
        if notebooks.count > 1 {
            for (index, notebook) in notebooks.enumerated() {
                guard let notebookId = notebook.id else { return }
                guard let isDefault = notebook.isDefault else { return }
            
                if notebookId == id && isDefault == "no" {
                    Alerts.showWarningAlertWithCancelAndCustomAction(title: "Delete Notebook?", subTitle: "Once deleted we cannot retrieve it back. Are you sure you want to proceed?", actionTitle: "Yes", action: { [unowned self] in
                            Api.Notebooks.deleteNotebook(withId: id, onSuccess: { [unowned self] in
                                self.notebooks.remove(at: index)
                                self.collectionView.reloadData()
                                self.postNotificationForDeletedNotebookWith(uid: id, key: NotificationKey.notebookDeleted)
                                }, onError: {  error in
                                    SCLAlertView().showError("Error", subTitle: error)
                            })
                        })
                    break
                }
                else if notebookId == id && isDefault == "yes" {
                    Alerts.showWarningWithOKAction(title: "Oops!", subtitle: "In order to delete your default notebook, you have to set another notebook as default first.")
                    return
                }
            }
        }
        else {
            SCLAlertView().showWarning("Oops!", subTitle: "In order to delete the only notebook in your library, you'd need to create another one and set it as default first.")
            return
        }
    }
    
    func changeNotebookCover(with id: String) {
        performSegue(withIdentifier: Segues.NotebookVCToUpdateNotebookCoverVC, sender: id)
    }
    
    func renameNotebook(with id: String) {
        performSegue(withIdentifier: Segues.NotebooksToRenameNotebookVC, sender: id)
    }
    
    func infoForNotebook(with id: String) {
        performSegue(withIdentifier: Segues.NotebooksToNotebookInfo, sender: id)
    }
    
    func postNotificationWithKey(key: String) {
        let name = Notification.Name(rawValue: key)
        NotificationCenter.default.post(name: name, object: nil)
    }
    
    func postNotificationForDeletedNotebookWith(uid: String, key : String) {
        let name = Notification.Name(rawValue: key)
        NotificationCenter.default.post(name: name, object: nil, userInfo: ["uid" : uid])
    }
    
    func postNotificationForChangedNotebookWith(uid: String, key : String) {
        let name = Notification.Name(rawValue: key)
        NotificationCenter.default.post(name: name, object: nil, userInfo: ["uid" : uid])
    }
    
    func postNotificationForAddedNewNotebook(key: String) {
        let name = Notification.Name(rawValue: key)
        NotificationCenter.default.post(name: name, object: nil)
    }
}

extension NotebookVC: RenameNotebookVCDelegate, UpdateNotebookCoverVCDelegate {
    
    func refetchNotebooks() {
        fetchNotebooks()
    }
}

extension NotebookVC: CreateNotebookDelegate {
    func notebookAdded() {
        postNotificationForAddedNewNotebook(key: NotificationKey.notebookAdded)
        fetchNotebooks()
    }
}

extension NotebookVC: FlipNotebookDelegate {
    
    func willFlip(currentCell: NotebookCell, swipe: UISwipeGestureRecognizer.Direction) {
        // CASE 1. Flipping the same notebook back and forth
        if lastFlippedNotebook === currentCell {
            guard let lastCell = lastFlippedNotebook else { return }
            if lastCell.isOpen {
                switch swipe {
                case .left:
                    lastCell.showCover(options: .transitionFlipFromLeft)
                    lastFlippedNotebook = currentCell
                case .right:
                    lastCell.showCover(options: .transitionFlipFromRight)
                    lastFlippedNotebook = currentCell
                default:
                    break
                }
            }
            else {
                switch swipe {
                case .left:
                    lastFlippedNotebook?.showMenu(options: .transitionFlipFromLeft)
                    lastFlippedNotebook = currentCell
                case .right:
                    lastFlippedNotebook?.showMenu(options: .transitionFlipFromRight)
                    lastFlippedNotebook = currentCell
                default:
                    break
                }
            }
        }
        // CASE 2: Notebook was previously open, but the current notebook is not the previously opened
        else if lastFlippedNotebook != currentCell && lastFlippedNotebook != nil {
            guard let lastCell = lastFlippedNotebook else { return }
            if lastCell.isOpen && lastCell != currentCell {
                lastFlippedNotebook?.showCover(options: .transitionFlipFromRight)
                currentCell.showMenu(options: .transitionFlipFromRight)
                lastFlippedNotebook = currentCell
            }
            else {
                swipeCurrentCell(currentCell, swipe)
            }
        }
        // CASE 3. : First Opening of Notebook
        else {
            swipeCurrentCell(currentCell, swipe)
        }
    }

    
    fileprivate func swipeCurrentCell(_ currentCell: NotebookCell, _ swipe: UISwipeGestureRecognizer.Direction) {
        if currentCell.isOpen {
            switch swipe {
            case .left:
                currentCell.showMenu(options: .transitionFlipFromLeft)
                lastFlippedNotebook = currentCell
            case .right:
                currentCell.showCover(options: .transitionFlipFromRight)
                lastFlippedNotebook = currentCell
            default:
                break
            }
        }
        else {
            switch swipe {
            case .left:
                currentCell.showMenu(options: .transitionFlipFromLeft)
                lastFlippedNotebook = currentCell
            case .right:
                currentCell.showMenu(options: .transitionFlipFromRight)
                lastFlippedNotebook = currentCell
            default:
                break
            }
        }
    }
}
