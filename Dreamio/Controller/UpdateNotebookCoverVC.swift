//
//  UpdateNotebookCoverVC.swift
//  Dreamio
//
//  Created by Bold Lion on 26.02.19.
//  Copyright © 2019 Bold Lion. All rights reserved.
//

import UIKit
import SCLAlertView

protocol UpdateNotebookCoverVCDelegate: AnyObject {
    func refetchNotebooks()
}
class UpdateNotebookCoverVC: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    var saveButton = UIBarButtonItem()
    var cancelButton = UIBarButtonItem()
    
    var notebookId: String?
    var selectedCover: String?
    var selectedIndexPath: IndexPath?
    var notebookCovers = NotebookCoversString.covers
    let cellScaling: CGFloat = 0.6
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    weak var delegate: UpdateNotebookCoverVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        fetchNotebookInfo()
        setCarousel()
        setNavButtons()
        setCollectionViewDelegates()
        collectionView.allowsMultipleSelection = false
        collectionView.contentInsetAdjustmentBehavior = .never
    }
    
    func fetchNotebookInfo() {
        guard let id = notebookId else { return }
        Api.Notebooks.fetchNotebookWith(uid: id, onSuccess: { [unowned self] notebook in
            guard let coverStr = notebook.coverImageString else { return }
            self.notebookCovers = self.notebookCovers.filter({ $0 != coverStr })
            self.collectionView.reloadData()
        }, onError: { error in
            SCLAlertView().showError("Something went wrong...", subTitle: error)
        })
    }
    
    func setNavButtons() {
        saveButton = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveTapped))
        saveButton.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.lightGray], for: .disabled)
        saveButton.setTitleTextAttributes([NSAttributedString.Key.foregroundColor:  UIColor.white], for: .normal)
        saveButton.isEnabled = false
        cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelTapped))
        cancelButton.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .normal)
        navigationItem.rightBarButtonItem  = saveButton
        navigationItem.leftBarButtonItem = cancelButton
    }
    
    @objc func saveTapped() {
        guard let notebookUid = notebookId else { return }
        guard let coverImageName = selectedCover else { return }
        Api.Notebooks.updateNotebookCoverImage(forNotebookId: notebookUid, name: coverImageName, onSuccess: { [unowned self] in
            SCLAlertView().showSuccess("Done!", subTitle: "Notebook cover successfully updated!")
            self.delegate?.refetchNotebooks()
            self.navigationController?.popViewController(animated: true)
        }, onError: { error in
            SCLAlertView().showError("Oops!", subTitle: "Select a cover please.")
        })
    }
    
    @objc func cancelTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    func setCarousel() {
        let screenSize = UIScreen.main.bounds.size
        let cellWidth = floor(screenSize.width * cellScaling)
        let cellHeight = floor(screenSize.height * cellScaling)
        
        let insetX = (view.bounds.width - cellWidth) / 2
        let insetY = (view.bounds.height - cellHeight) / 2
        
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: cellWidth, height: cellHeight)
        collectionView.contentInset = UIEdgeInsets(top: insetY, left: insetX, bottom: insetY, right: insetX)
    }
    
    deinit {
        print("UpdateNotebookCoverVC deinit")
    }
}

extension UpdateNotebookCoverVC:  UICollectionViewDataSource {
    
    func setCollectionViewDelegates() {
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return notebookCovers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Cell_Id.createNotebook, for: indexPath) as! CreateNotebookCVCell
        let cover = notebookCovers[indexPath.row]
        cell.coverImageView.image = UIImage(named: cover)
        if selectedIndexPath == indexPath {
            cell.showDimViewAndCheckmark()
        } else {
            cell.hideDimViewAndCheckmark()
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if selectedIndexPath != indexPath || selectedIndexPath == nil {
            // Select Cell
            selectedIndexPath = indexPath
            selectedCover = notebookCovers[indexPath.row]
            saveButton.isEnabled = true
        } else {
            // Deselect Cell
            selectedIndexPath = nil
            saveButton.isEnabled = false
            selectedCover = nil
        }
        collectionView.reloadData()
    }
}

extension UpdateNotebookCoverVC: UIScrollViewDelegate, UICollectionViewDelegate {
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        let cellWidthIncludingSpacing = layout.itemSize.width + layout.minimumLineSpacing
        
        var offset = targetContentOffset.pointee
        let index = (offset.x + scrollView.contentInset.left) / cellWidthIncludingSpacing
        let roundedIndex = round(index)
        
        offset = CGPoint(x: roundedIndex * cellWidthIncludingSpacing - scrollView.contentInset.left, y: -scrollView.contentInset.top)
        targetContentOffset.pointee = offset
    }
}
