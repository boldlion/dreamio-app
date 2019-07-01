//
//  LibraryCell.swift
//  Dreamio
//
//  Created by Bold Lion on 20.02.19.
//  Copyright © 2019 Bold Lion. All rights reserved.
//

import UIKit

protocol NotebookCellDelegate: AnyObject {
    func deleteNotebook(with id: String)
    func changeNotebookCover(with id: String)
    func renameNotebook(with id: String)
    func infoForNotebook(with id: String)
    func setNotebookAsDefault(with notebook: Notebook)
}
protocol FlipNotebookDelegate: AnyObject {
    func willFlip(currentCell: NotebookCell, swipe: UISwipeGestureRecognizer.Direction)
}

class NotebookCell: UICollectionViewCell {
    
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var defaultNotebookImageView: UIImageView!
    
    @IBOutlet weak var action_coverImage: UIImageView!
    @IBOutlet weak var action_renameImage: UIImageView!
    @IBOutlet weak var action_infoImage: UIImageView!
    @IBOutlet weak var action_deleteImage: UIImageView!
    
    weak var delegate: NotebookCellDelegate?
    weak var flipNotebookDelegate: FlipNotebookDelegate?
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        setUI()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //setUI()
        addSwipeGestures()
      //  tapGestures()
        tapGesture_changeDefaultNotebook()
        tapGesture_info()
        tapGesture_delete()
        tapGesture_rename()
        tapGesture_changeCover()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        defaultNotebookImageView.image = UIImage(named: "icon_default_deselected")
        coverImageView.image = UIImage()
        setUI()
    }
    
     var notebook: Notebook? {
        didSet {
            updateView()
        }
    }
    
    var isOpen = false
    
    func addSwipeGestures() {
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(swipeView(swipe:)))
        swipeLeft.direction = UISwipeGestureRecognizer.Direction.left
        contentView.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(swipeView(swipe:)))
        swipeRight.direction = UISwipeGestureRecognizer.Direction.right
        contentView.addGestureRecognizer(swipeRight)
    }
    
   @objc func swipeView(swipe: UISwipeGestureRecognizer) {
        switch swipe.direction {
        case .left:
            swipeLeftAction(swipe: .left )
        case .right:
            swipeRightAction(swipe: .right)
        default:
            break
        }
    }
    
    func swipeLeftAction(swipe: UISwipeGestureRecognizer.Direction) {
        if isOpen {
            flipNotebookDelegate?.willFlip(currentCell: self, swipe: swipe)
        }
        else {
            flipNotebookDelegate?.willFlip(currentCell: self, swipe: swipe)
        }
    }
    
    func swipeRightAction(swipe: UISwipeGestureRecognizer.Direction) {
        if isOpen {
            flipNotebookDelegate?.willFlip(currentCell: self, swipe: swipe)
        }
        else {
            flipNotebookDelegate?.willFlip(currentCell: self, swipe: swipe)
        }
    }
    
    func showCover(options: UIView.AnimationOptions ) {
        UIView.transition(with: backView, duration: 0.3, options: options, animations: { [unowned self] in
            self.coverImageView.isHidden = false
            self.titleLabel.isHidden = false
            self.titleView.isHidden = false
            self.isOpen = false
        })
    }
    
    func showMenu(options: UIView.AnimationOptions) {
        UIView.transition(with: backView, duration: 0.3, options: options, animations: { [unowned self] in
            self.coverImageView.isHidden = true
            self.titleLabel.isHidden = true
            self.titleView.isHidden = true
            self.isOpen = true
        })
    }
    
    func updateView() {
        if let title = notebook?.title {
            titleLabel.text = title
        }

        if let coverImage = notebook?.coverImageString {
            coverImageView.image = UIImage(named: coverImage)
        }
        
        if let defaultNotebook = notebook?.isDefault {
            defaultNotebookImageView.image = defaultNotebook == "yes" ? UIImage(named: "icon_default_selected") : UIImage(named: "icon_default_deselected")
        }
    }
    
    func setUI() {
        coverImageView.clipsToBounds = true
        backView.backgroundColor = Colors.purpleDarker
        backView.layer.maskedCorners =  [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]

        layer.shadowColor = UIColor.lightGray.cgColor
        layer.shadowOffset = CGSize(width:1, height: 1)
        layer.shadowRadius = 2.0
        layer.shadowOpacity = 1.0
        layer.masksToBounds = false

        contentView.clipsToBounds = true
        contentView.layer.cornerRadius = 10
        contentView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
    }
    
    func tapGesture_changeDefaultNotebook() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(changeDefaultNotebook))
        defaultNotebookImageView.isUserInteractionEnabled = true
        defaultNotebookImageView.addGestureRecognizer(tap)
    }
    
    func tapGesture_changeCover() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(changeCover))
        action_coverImage.isUserInteractionEnabled = true
        action_coverImage.addGestureRecognizer(tap)
    }
    
    func tapGesture_rename() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(rename))
        action_renameImage.isUserInteractionEnabled = true
        action_renameImage.addGestureRecognizer(tap)
    }
    
    func tapGesture_info() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(info))
        action_infoImage.isUserInteractionEnabled = true
        action_infoImage.addGestureRecognizer(tap)
    }
    
    func tapGesture_delete() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(deleteNotebook))
        action_deleteImage.isUserInteractionEnabled = true
        action_deleteImage.addGestureRecognizer(tap)
    }
    
    @objc func changeDefaultNotebook() {
        if let notebook = notebook {
            delegate?.setNotebookAsDefault(with: notebook)
        }
    }
    
    @objc func changeCover() {
        if let id = notebook?.id {
            showCover(options: .transitionFlipFromRight)
            delegate?.changeNotebookCover(with: id)
        }
    }
    
    @objc func rename() {
        if let id = notebook?.id {
            showCover(options: .transitionFlipFromRight)
            delegate?.renameNotebook(with: id)
        }
    }
    
    @objc func info() {
        if let id = notebook?.id {
            delegate?.infoForNotebook(with: id)
        }
    }
    
    @objc func deleteNotebook() {
        if let id = notebook?.id {
            showCover(options: .transitionFlipFromRight)
            delegate?.deleteNotebook(with: id)
        }
    }
    
    deinit {
        print("NotebookCell deinitialised")
    }
}
