//
//  CreateNotebook.swift
//  Dreamio
//
//  Created by Bold Lion on 25.02.19.
//  Copyright © 2019 Bold Lion. All rights reserved.
//

import UIKit
import SVProgressHUD

protocol CreateNotebookDelegate {
    func refetchNotebooks()
}
 
class CreateNotebook: UIViewController {

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var saveButton = UIBarButtonItem()
    
    let notebookCovers = NotebookCoversString.covers
    var selectedCover: String?
    
    var selectedIndexPath: IndexPath?
    let cellScaling: CGFloat = 0.6
    
    var delegate: CreateNotebookDelegate?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        setCollectionViewDelegates()
        titleTextField.delegate = self
        setCarousel()
        collectionView.allowsSelection = true
        setNavSaveButton()
        handleTextFields()
        NavBar.setGradientNavigationBar(for: navigationController)
    }

    func setNavSaveButton() {
        saveButton = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveTapped))
        saveButton.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.lightGray], for: .disabled)
        saveButton.setTitleTextAttributes([NSAttributedString.Key.foregroundColor:  UIColor.white], for: .normal)
        saveButton.isEnabled = false
        navigationItem.rightBarButtonItem  = saveButton
    }
    
    @objc func saveTapped() {
        view.endEditing(true)
        SVProgressHUD.showInfo(withStatus: "Saving, please wait!")
        guard let title = titleTextField.text else { return }
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if selectedCover != "" && selectedCover != nil {
            Api.Notebooks.createNotebook(with: selectedCover!, title: trimmedTitle, onSuccess: { [unowned self] in
                SVProgressHUD.dismiss()
                self.delegate?.refetchNotebooks()
                _ = self.navigationController?.popViewController(animated: true)
            }, onError: { error in
                SVProgressHUD.showError(withStatus: error)
            })
        }
        else {
            SVProgressHUD.showError(withStatus: "Select a cover please.")
            return
        }
    }
    
    func setCarousel() {
        let screenSize = UIScreen.main.bounds.size
        let cellWidth = screenSize.width * cellScaling
        let cellHeight = screenSize.height *  cellScaling
        let insetX = (view.bounds.width - cellWidth) / 2
        let insetY = (view.bounds.height - cellHeight) / 2
        
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: cellWidth, height: cellHeight)
        collectionView.contentInset = UIEdgeInsets(top: insetY, left: insetX, bottom: insetY, right: insetX)
    }
}

extension CreateNotebook:  UICollectionViewDataSource {
    
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
        if selectedIndexPath != indexPath {
            // Select Cell
            selectedIndexPath = indexPath
            selectedCover = notebookCovers[indexPath.row]
        }
        else {
            // Deselect Cell
            selectedIndexPath = nil
            selectedCover = nil
        }
        collectionView.reloadData()
    }
}

extension CreateNotebook: UIScrollViewDelegate, UICollectionViewDelegate {
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


extension CreateNotebook : UITextFieldDelegate {
    
    func handleTextFields() {
        titleTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    @objc func textFieldDidChange() {
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        titleTextField.resignFirstResponder()
        return true
    }
}
