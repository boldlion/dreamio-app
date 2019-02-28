//
//  LibraryVC.swift
//  Dreamio
//
//  Created by Bold Lion on 19.02.19.
//  Copyright © 2019 Bold Lion. All rights reserved.
//

import UIKit
import SVProgressHUD

class NotebookVC: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var notebooks = [Notebook]()
    weak var lastFlippedNotebook: NotebookCell?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerCell()
        fetchNotebooks()
        NavBar.setGradientNavigationBar(for: navigationController)        
    }
    
    func fetchNotebooks() {
        
//        if notebooks.isEmpty {
//            createNewNotebook()
//        }
//        else {
            // Fetch Notebook from Database
            notebooks.removeAll()
            Api.User_Notebooks.fetchUserNotebooksForCurrentUser(onSuccess: { [unowned self] notebook in
                self.notebooks.insert(notebook, at: 0)
                self.collectionView.reloadData()
                }, onError: { error in
                    SVProgressHUD.showError(withStatus: error)
            })
      //  }
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
}

extension NotebookVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func registerCell() {
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if !notebooks.isEmpty {
            return notebooks.count
        }
        else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Cell_Id.notebook, for: indexPath) as! NotebookCell
        cell.notebook = notebooks[indexPath.row]
        cell.delegate = self
        cell.flipNotebookDelegate = self
        return cell
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

    
    func deleteNotebook(with id: String) {
        for notebook in notebooks {
            guard let notebookId = notebook.id else { return }
            if notebookId == id {
                Alerts.showBasicAlertWithCancel(on: self, withTitle: "Delete this notebook?", message: "Once deleted we cannot retrieve it back. Are you sure you want to proceed?", action: "Yes", completion: { [unowned self] in
                    Api.Notebooks.deleteNotebook(withId: notebookId, onSuccess: { [unowned self] in
                        SVProgressHUD.showSuccess(withStatus: "Deleted!")
                        for (index, notebook) in self.notebooks.enumerated() {
                            if notebook.id == notebookId {
                                self.notebooks.remove(at: index)
                                self.collectionView.reloadData()
                            }
                        }
                    }, onError: {  error in
                        SVProgressHUD.showError(withStatus: error)
                    })
                })
            }
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
}

extension NotebookVC: CreateNotebookDelegate, RenameNotebookVCDelegate, UpdateNotebookCoverVCDelegate {
    
    func refetchNotebooks() {
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
