//
//  EntriesVC.swift
//  Dreamio
//
//  Created by Bold Lion on 19.02.19.
//  Copyright © 2019 Bold Lion. All rights reserved.
//

import UIKit
import SCLAlertView

class EntriesVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var dropDownTableView: UITableView!
    @IBOutlet weak var dropDownTableConstraint: NSLayoutConstraint!
    @IBOutlet weak var dimView: UIView!
    @IBOutlet weak var noDataStackView: UIStackView!
    
    @IBOutlet weak var noDataTitle: UILabel!
    @IBOutlet weak var noDataImageView: UIImageView!
    @IBOutlet weak var noDataButton_CreateNewEntry: UIButton!
    
    var notebooks = [Notebook]()
    var notebooksCopy = [Notebook]()
    var entries = [Entry]()
    var isDropDownOpen = false
    var isNoDataVisible = false
    var selectedNotebookUid: String?
    var changedNotebookUid: String?
    lazy var arrowImage: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    lazy var labels: [String] = {
        let labels = [String]()
        return labels
    }()
    
    // Pagination
    var fetchingMore = false
    var endReached = false
    let leadingScreensForBatching: CGFloat = 3.0
    
    // Notefication Observers
    let defaultNotebookChangedKey = Notification.Name(rawValue: NotificationKey.notebookDefaultChanged)
    let notebookRenamedKey = Notification.Name(rawValue: NotificationKey.notebookRenamed)
    let deletedNotebookKey = Notification.Name(rawValue: NotificationKey.notebookDeleted)
    let addedNotebookKey = Notification.Name(rawValue: NotificationKey.notebookAdded)
    let notebookIdTapped = Notification.Name(rawValue: NotificationKey.notebookIdTapped)
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        noDataStackView.isHidden = true
        dropDownTableView.tableFooterView = UIView()
        setTableViewDelegates()
        dimViewTap()
        createObservers()
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action: #selector(changeNotebook))
        navigationController?.navigationBar.addGestureRecognizer(tapGestureRecognizer)
        NavBar.setGradientNavigationBar(for: navigationController)
        fetchCurrentUserNotebooks()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        dropDownTableConstraint.constant = dropDownTableView.contentSize.height + 20
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isDropDownOpen = false
    }

    func createObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector (defaultNotebookStatusChanged), name: defaultNotebookChangedKey, object: nil)
        NotificationCenter.default.addObserver(forName: notebookRenamedKey, object: nil, queue: nil, using: notebookRenamed)
        NotificationCenter.default.addObserver(forName: deletedNotebookKey, object: nil, queue: nil, using: deletedNotebook)
        NotificationCenter.default.addObserver(self, selector: #selector(fetchCurrentUserNotebooks), name: addedNotebookKey, object: nil)
        NotificationCenter.default.addObserver(forName: notebookIdTapped, object: nil, queue: nil, using: userChangedNotebookTo)
    }
    
    @objc func userChangedNotebookTo(notication: Notification) -> Void {
        activityIndicator.startAnimating()
        
//        if CheckInternet.isConnectedToNetwork() {
            guard let notebookUid = notication.userInfo!["uid"] as? String else { return }
            for notebook in notebooks {
                guard let uid = notebook.id else { return }
                guard let title = notebook.title else { return }
                if notebookUid == uid {
                    navigationItem.titleView = navTitleWithImageAndText(titleText: title)
                    selectedNotebookUid = notebook.id!
                    break
                }
            }
            
            entries.removeAll()
            fetchEntriesForNotebook(completion: { [unowned self] newEntries in
                self.entries.append(contentsOf: newEntries)
                self.fetchingMore = false
                self.endReached = newEntries.count == 0
                UIView.performWithoutAnimation { [unowned self] in
                    self.activityIndicator.stopAnimating()
                    self.tableView.reloadData()
                }
            })
            isNoDataVisible = true
            noDataFormatAndShow()
            changeNotebook()
            isDropDownOpen = !isDropDownOpen
            closeMenu()
//        }
//        else {
//            activityIndicator.stopAnimating()
//            Alerts.showWarningWithOKAction(title: "No Internet Connection", subtitle: "Make sure you're connected to internet.")
//        }
    }
    
    
    @objc func defaultNotebookStatusChanged() {
        fetchCurrentUserNotebooks()
    }
    
    @objc func notebookRenamed(notification: Notification)  -> Void {
        guard let uid = notification.userInfo!["uid"] as? String else { return }
        guard let newTitle = notification.userInfo!["title"] as? String else { return }

        for (index, notebook) in notebooks.enumerated() {
            guard let id = notebook.id else { return }
            if id == uid {
                notebooks[index].title = newTitle
                updateNavigationTitle()
                setCopiedNotebook()
                break
            }
        }
    }

    @objc func deletedNotebook(notification: Notification)  -> Void  {
        guard let uid = notification.userInfo!["uid"] as? String else { return }
        notebooks = notebooks.filter({ $0.id != uid })
        setCopiedNotebook()
        updateNavigationTitle()
    }
    
    @objc func fetchCurrentUserNotebooks() {
        activityIndicator.startAnimating()
//        if CheckInternet.isConnectedToNetwork() {
            notebooks.removeAll()
            Api.User_Notebooks.fetchAllNotebooksForCurrentUser(onSuccess: { [unowned self] notebooks in
                self.notebooks = notebooks
                self.setTitleAfterFetchingNotebooks(notebooks: notebooks)
                self.setCopiedNotebook()
                }, onError: { [unowned self] message in
                    self.activityIndicator.stopAnimating()
                    SCLAlertView().showError("Error", subTitle: message)
            })
//        }
//        else {
//            activityIndicator.stopAnimating()
//            Alerts.showWarningWithOKAction(title: "No Internet Connection", subtitle: "Make sure you're connected to internet.")
//        }
    }

    func setTitleAfterFetchingNotebooks(notebooks: [Notebook]) {
        for notebook in notebooks {
            guard let isDefault = notebook.isDefault else { return }
            guard let title = notebook.title else { return }
            if isDefault == "yes" {
                navigationItem.titleView = navTitleWithImageAndText(titleText: title)
                selectedNotebookUid = notebook.id!
                
               // if CheckInternet.isConnectedToNetwork() {
                    fetchEntriesForNotebook(completion: { newEntries in
                        self.entries.append(contentsOf: newEntries)
                        self.fetchingMore = false
                        self.endReached = newEntries.count == 0
                        UIView.performWithoutAnimation { [unowned self] in
                            self.activityIndicator.stopAnimating()
                            self.tableView.reloadData()
                        }
                    })
//                }
//                else {
//                    activityIndicator.stopAnimating()
//                    Alerts.showWarningWithOKAction(title: "No Internet Connection", subtitle: "Make sure you're connected to internet.")
//                }
            }
        }
    }
    
    func updateNavigationTitle() {
        for notebook in notebooks {
            guard let isDefault = notebook.isDefault else { return }
            guard let title = notebook.title else { return }
            if isDefault == "yes" {
                navigationItem.titleView = self.navTitleWithImageAndText(titleText: title)
                isDropDownOpen = false
                selectedNotebookUid = notebook.id!
                break
            }
        }
    }
    
    func setCopiedNotebook() {
        notebooksCopy.removeAll()
        notebooksCopy = notebooks.filter({ $0.isDefault! != "yes" })
    }
    
    func fetchEntriesForNotebook(completion: @escaping (_ entries: [Entry]) -> Void) {
        guard let notebookUid = selectedNotebookUid else { return }
        activityIndicator.startAnimating()
    //    if CheckInternet.isConnectedToNetwork() {
            Api.Notebook_Entries.doesNotebookEntryUidExistWith(uid: notebookUid, onExist: { [unowned self] in
                
                Api.Entries_Timestamp.fetchEntriesTimestampFor(notebookUid: notebookUid, lastEntry: self.entries.last, completion: { [unowned self] newEntriesArray in
                    self.activityIndicator.stopAnimating()
                    completion(newEntriesArray)
                    }, onError: { [unowned self] errorMessage in
                        self.activityIndicator.stopAnimating()
                        SCLAlertView().showError("Something went wrong...", subTitle: errorMessage)
                    })
                }, onDoesntExist: { [unowned self] in
                    self.activityIndicator.stopAnimating()
                    self.isNoDataVisible = false
                    self.noDataFormatAndShow()
            })
//        }
//        else {
//            activityIndicator.stopAnimating()
//            Alerts.showWarningWithOKAction(title: "No Internet Connection", subtitle: "Make sure you're connected to internet.")
//        }
    }
    
    func beginEntriesBatchFetch() {
        fetchingMore = true
        activityIndicator.startAnimating()
       // if CheckInternet.isConnectedToNetwork() {
            fetchEntriesForNotebook(completion: { [unowned self] newEntries in
                self.entries.append(contentsOf: newEntries)
                self.fetchingMore = false
                self.endReached = newEntries.count == 0
                self.activityIndicator.stopAnimating()
                UIView.performWithoutAnimation { [unowned self] in
                    self.tableView.reloadData()
                }
            })
//        }
//        else {
//            activityIndicator.stopAnimating()
//            Alerts.showWarningWithOKAction(title: "No Internet Connection", subtitle: "Make sure you're connected to internet.")
//        }
    }

    func navTitleWithImageAndText(titleText: String) -> UIView {
        let titleView = UIView()
        let label = UILabel()
        label.text = titleText
        label.font = UIFont.init(name: "HelveticaNeue-Regular", size: 15)
        label.sizeToFit()
        label.center = titleView.center
        label.textColor = .white
        label.textAlignment = NSTextAlignment.center
        
        if notebooks.count > 1 {
            let image = UIImageView()
            image.image = UIImage(named: "icon_dropdown-1")
            
            // Maintains the image's aspect ratio:
            let imageAspect = image.image!.size.width / image.image!.size.height
            
            // Sets the image frame so that it's immediately before the text:
            let imageX = label.frame.maxX
            let imageY = label.frame.origin.y / 3
            
            let imageWidth = (label.frame.size.height * imageAspect) / 2
            let imageHeight = label.frame.size.height / 3
            
            image.frame = CGRect(x: imageX, y: imageY, width: imageWidth, height: imageHeight)
            
            image.contentMode = UIView.ContentMode.scaleAspectFit
            arrowImage = image

            titleView.addSubview(image)
        }
        titleView.addSubview(label)
        // Sets the titleView frame to fit within the UINavigation Title
        titleView.sizeToFit()
        return titleView
    }

    @IBAction func addNewEntry(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: Segues.EntriesToCreateEntryVC, sender: sender)
    }
    
    @IBAction func noData_CreateNewEntryTapped(_ sender: UIButton) {
        performSegue(withIdentifier: Segues.EntriesToCreateEntryVC, sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Segues.EntriesToCreateEntryVC {
            guard let notebookId = selectedNotebookUid else { return }
            let navController = segue.destination as! UINavigationController
            var destinationVC = NewEntryVC()
            destinationVC = navController.viewControllers[0] as! NewEntryVC
            destinationVC.notebookId = notebookId
            destinationVC.delegate = self
            if let entryToSend = sender as? Entry {
                destinationVC.entry = entryToSend
            }
        }
    }
    
    @objc func changeNotebook() {
        if notebooks.count > 1 {
            UIView.animate(withDuration: 0.3, animations: { [unowned self] in
                if self.isDropDownOpen {
                    self.closeMenu()
                }
                else {
                    self.showMenu()
                }
                self.view.layoutIfNeeded()
            })
        }
    }
    
    func showMenu() {
        isNoDataVisible = false
        dropDownTableView.isHidden = false
        dimView.isHidden = false
        isDropDownOpen = !isDropDownOpen
        dropDownTableConstraint.constant = 200
        dropDownTableView.reloadData()
        UIView.animate(withDuration: 2.0, animations: { [unowned self] in
            self.arrowImage.transform = self.arrowImage.transform.rotated(by: CGFloat(Double.pi / 1))
        })
    }
    
    @objc func closeMenu() {
        UIView.animate(withDuration: 0.2, animations: { [unowned self] in
            UIView.animate(withDuration: 2.0, animations: { [unowned self] in
                self.arrowImage.transform = self.arrowImage.transform.rotated(by: CGFloat(-Double.pi / 1))
            })
            self.dimView.isHidden = true
            self.dropDownTableView.isHidden = true
            self.dropDownTableConstraint.constant = 0
            self.isDropDownOpen = !self.isDropDownOpen
        })
    }
    
    func noDataFormatAndShow() {
        if isNoDataVisible {
            // hide no data view
            tableView.isHidden = false
            noDataImageView.isHidden = true
            noDataTitle.isHidden = true
            noDataStackView.isHidden = true
            noDataButton_CreateNewEntry.isHidden = true
        }
        else {
            // show no data view
            tableView.isHidden = true
            noDataStackView.isHidden = false
            noDataImageView.isHidden = false
            noDataTitle.isHidden = false
            noDataButton_CreateNewEntry.isHidden = false
            noDataButton_CreateNewEntry.layer.borderColor = Colors.purpleDarker.cgColor
            noDataButton_CreateNewEntry.layer.cornerRadius = 5
            noDataButton_CreateNewEntry.layer.borderWidth = 1
            noDataButton_CreateNewEntry.tintColor = Colors.purpleDarker
            noDataButton_CreateNewEntry.clipsToBounds = true
            activityIndicator.stopAnimating()
        }
    }
    
    func dimViewTap() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(closeMenu))
        dimView.isUserInteractionEnabled = true
        dimView.addGestureRecognizer(tap)
    }
    
    deinit {
        print("EntriesVC deinitialised")
    }
}

extension EntriesVC : UITableViewDelegate, UITableViewDataSource {
    
    func setTableViewDelegates() {
        dropDownTableView.delegate = self
        dropDownTableView.dataSource = self
        dropDownTableView.isHidden = true
        dropDownTableConstraint.constant = 0
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tableView {
            return entries.count
        }
        else {
            return notebooksCopy.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.tableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: Cell_Id.entryTVCell, for: indexPath) as! EntryTVCell
            cell.entry = entries[indexPath.row]
            cell.delegate = self
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: Cell_Id.dropDownNotebookCell) as! DropDownNotebookTVCell
            cell.notebook = notebooksCopy[indexPath.row]
            return cell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == self.tableView {
            let entry = entries[indexPath.row]
            DispatchQueue.main.async { [unowned self] in
                self.performSegue(withIdentifier: Segues.EntriesToCreateEntryVC, sender: entry)
            }
        }
        else if tableView == dropDownTableView {
            if selectedNotebookUid != nil {
                
            //    if CheckInternet.isConnectedToNetwork() {
                    guard let id = notebooksCopy[indexPath.row].id else { return }
                    guard let title = notebooksCopy[indexPath.row].title else { return }
                    
                    selectedNotebookUid = id
                    notebooksCopy = notebooks.filter({ $0.id != id })
                    navigationItem.titleView = navTitleWithImageAndText(titleText: title)
                    activityIndicator.startAnimating()
                    entries.removeAll()
                    fetchEntriesForNotebook(completion: { [unowned self] newEntries in
                        self.entries.append(contentsOf: newEntries)
                        self.fetchingMore = false
                        self.endReached = newEntries.count == 0
                        UIView.performWithoutAnimation { [unowned self] in
                            self.tableView.reloadData()
                            self.activityIndicator.stopAnimating()
                        }
                    })
                    isNoDataVisible = true
                    noDataFormatAndShow()
                    changeNotebook()
                    isDropDownOpen = !isDropDownOpen
                    closeMenu()
//                }
//                else {
//                    activityIndicator.stopAnimating()
//                    Alerts.showWarningWithOKAction(title: "No Internet Connection", subtitle: "Make sure you're connected to internet.")
//                }
            }
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == self.tableView {
           return 150
        }
        else {
            return 50
        }
    }
    
    // Pagination
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        
        if offsetY > contentHeight - scrollView.frame.size.height * leadingScreensForBatching {
            
          //  if CheckInternet.isConnectedToNetwork() {
                if !fetchingMore && !endReached {
                    beginEntriesBatchFetch()
                }
                else {
                    activityIndicator.stopAnimating()
                }
//            }
//            else {
//                activityIndicator.stopAnimating()
//                Alerts.showWarningWithOKAction(title: "No Internet Connection", subtitle: "Make sure you're connected to internet.")
//            }
        }
    }
}

extension EntriesVC: EntryTVCellDelegate {
    func settingsFor(entry: Entry) {
        guard let id = entry.id else { return }
        guard let notebookId = selectedNotebookUid else { return }
        
        Alerts.showEntryMenu(
            viewAction: { [unowned self] in
                self.performSegue(withIdentifier: Segues.EntriesToCreateEntryVC, sender: entry) },
            editAction: { [unowned self] in
                self.performSegue(withIdentifier: Segues.EntriesToCreateEntryVC, sender: entry) },
            deleteAction: { [unowned self] in
                Alerts.showWarningAlertWithCancelAndCustomAction(title: "Delete Entry?", subTitle: "Are you sure you want to delete this entry? We cannot retrieve it once deleted.", actionTitle: "Yes", action: { [unowned self] in
                    
                    // DELETE ENTRY
                  //  if CheckInternet.isConnectedToNetwork() {
                        // 1. entries > entryUid > delete
                        Api.Entries.deleteEntryWithUid(uid: id, onSuccess: { [unowned self] in
                            
                            // 2. entries_timestamp > notebookId > entryUid
                            Api.Entries_Timestamp.deleteEntryTimestampForNotebook(id: notebookId, entryId: id, onSuccess: { [unowned self] in
                                
                                // 3. notebook_entries > notebookUid > entryUid > delete
                                Api.Notebook_Entries.deleteEntryForNotebookWith(uid: notebookId, entryUid: id, onSuccess: { [unowned self] in
                                                                                                                                                                    
                                    // 4. entry_labels (fetch labels if the entry has any labels)
                                    Api.Entry_Labels.fetchLabelsForEntryWith(uid: id, onSuccess: { [unowned self] label in
                                        
                                        // 4.1. There's at least 1 Label, so check the number of entryUid for the each label in Labels node
                                        Api.Labels.deleteLabelForEntryWith(uid: id, label: label,
                                            onSuccess: { [unowned self] in
                                                self.entries = self.entries.filter({ $0.id != id })
                                                self.isNoDataVisible = !self.entries.isEmpty
                                                self.noDataFormatAndShow()
                                                self.tableView.reloadData() },
                                            deleteUserLabel: { [unowned self] in
                                                
                                            //4.1.2 delete the label from user_labels node
                                                Api.User_Labels.deleteLabel(label: label, onSuccess: { [unowned self] in
                                                    
                                                     // 4.3 delete entry_labels entryUid
                                                     Api.Entry_Labels.deleteEntryWith(id: id,
                                                          onSuccess: { [unowned self] in
                                                              self.entries = self.entries.filter({ $0.id != id })
                                                              self.isNoDataVisible = !self.entries.isEmpty
                                                              self.noDataFormatAndShow()
                                                              self.tableView.reloadData() },
                                                        onError: { error in
                                                            SCLAlertView().showError("Error", subTitle: error) })
                                                    },
                                            onError: { error in
                                                  SCLAlertView().showError("Error", subTitle: error) })
                                            },
                                        onError: { error in
                                              SCLAlertView().showError("Error", subTitle: error) })
                                        },
                                     // 4.2 Entry has NO labels
                                     onNoLabels: { [unowned self] in
                                            self.entries = self.entries.filter({ $0.id != id })
                                            self.isNoDataVisible = !self.entries.isEmpty
                                            self.noDataFormatAndShow()
                                            self.tableView.reloadData() },
                                     onError: { error in
                                         SCLAlertView().showError("Error", subTitle: error) })
                                    },
                                 onError: { error in
                                     SCLAlertView().showError("Error", subTitle: error) })
                                },
                             onError: { message in
                                   SCLAlertView().showError("Something went wrong...", subTitle: message) })
                            },
                       onError: { error in
                             SCLAlertView().showError("Error", subTitle: error) })
//                    }
//                    else {
//                        Alerts.showWarningWithOKAction(title: "No Internet Connection", subtitle: "Make sure you're connected to internet.")
//                    }
                })
            }
        )
    }
}

extension EntriesVC: NewEntrtVCDelegate {
    func fetchNewEntryWith(id: String) {
      //  if CheckInternet.isConnectedToNetwork() {
            Api.Entries.fetchEntryWith(uid: id, onSuccess: { [unowned self] entry in
                var userUpdatedEntry = false
                var entryIndex = 0
                for (index, entry) in self.entries.enumerated() {
                    guard let entryId = entry.id else { return }
                    if id == entryId {
                        userUpdatedEntry = true
                        entryIndex = index
                        break
                    }
                }
                
                if userUpdatedEntry {
                    // User Updated the entry
                    self.entries[entryIndex] = entry
                    self.isNoDataVisible = true
                    self.noDataFormatAndShow()
                    self.tableView.reloadData()
                }
                else {
                    // User just added new entry
                    self.entries.insert(entry, at: 0)
                    self.isNoDataVisible = true
                    self.noDataFormatAndShow()
                    self.tableView.reloadData()
                }
                }, onError: { message in
                    SCLAlertView().showError("Oops!", subTitle: message)
            })
//        }
//        else {
//            Alerts.showWarningWithOKAction(title: "No Internet Connection", subtitle: "Make sure you're connected to internet.")
//        }
        
    }
}
