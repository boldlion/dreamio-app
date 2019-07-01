//
//  SearchVC.swift
//  Dreamio
//
//  Created by Bold Lion on 25.04.19.
//  Copyright © 2019 Bold Lion. All rights reserved.
//

import UIKit
import SCLAlertView

class SearchVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var entry = [Entry]()
    var labels = [(key: String, value: Int)]()
    var filteredLabels = [(key: String, value: Int)]()
    
    var searchBar = UISearchBar()
    var isSearching = false
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 44
        setSearchBar()
        setDelegates()
        loadTopLabels()
    }
    func loadTopLabels() {
        activityIndicator.startAnimating()
        Api.Labels.fetchTopLabels(onSuccess: { [unowned self] labelsArray in
            self.activityIndicator.stopAnimating()
            self.labels = labelsArray
            self.tableView.reloadData()
        }, onError: { [unowned self] message in
            self.activityIndicator.stopAnimating()
            SCLAlertView().showError("Error!", subTitle: message)
        })
    }
    
    func doSearch() {
        if let searchText = searchBar.text {
            Api.Entries.queryEntries(withText: searchText, onSucces: { [unowned self] entry in
                self.entry.insert(entry, at: 0)
                self.tableView.reloadData()
            }, onError: { errorMessage in
                SCLAlertView().showError("Error!", subTitle: errorMessage)
            })
        }
    }
    
    func setSearchBar() {
        searchBar.searchBarStyle = .minimal
        searchBar.placeholder = "Search for a label..."
        searchBar.setTextColor(color: .white)
        searchBar.autocapitalizationType = .none
        searchBar.setPlaceholderText(color: .white)
        searchBar.setSearchImage(color: .white)
        searchBar.setClearButton(color: .white)
        searchBar.frame.size.width = view.frame.size.width - 60
        let searchItem = UIBarButtonItem(customView: searchBar)
        navigationItem.rightBarButtonItem = searchItem
    }
    
    func setDelegates() {
        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Segues.SearchVCToSearchEntriesVC {
            let label = sender as! String
            let destinationVC = segue.destination as! SearchEntriesVC
            destinationVC.transferedLabel = label
        }
    }

    deinit {
        print("SearchVC deinit")
    }
}

extension SearchVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching {
            return filteredLabels.count
        }
        else {
            if labels.count > 0 {
                return labels.count
            }
            else {
                return 0
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Cell_Id.labelTVC) as! LabelTVC
        if isSearching {
            cell.label.text = filteredLabels[indexPath.row].key
            cell.postNumber.text = String(filteredLabels[indexPath.row].value)
        }
        else {
            cell.label.text = labels[indexPath.row].key
            cell.postNumber.text = String(labels[indexPath.row].value)
        }
        cell.numberLabel.text = String(indexPath.row + 1) + "."
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var label = ""
        if isSearching {
            label = filteredLabels[indexPath.row].key
        }
        else {
            label = labels[indexPath.row].key
        }
        performSegue(withIdentifier: Segues.SearchVCToSearchEntriesVC, sender: label)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 40))
        header.backgroundColor = .darkGray
        
        let label = UILabel(frame: CGRect(x: 16, y: 5, width: header.frame.width, height: 30))
        label.text = "Top Labels"
        label.font = UIFont(name: "Helvetica-Bold", size: 13)
        label.textColor = .white
        header.addSubview(label)
        
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
}

extension SearchVC: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
       // print(searchBar.text)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredLabels = labels.filter({ ($0.key.prefix(searchText.count)) == searchText })
        isSearching = true
        tableView.reloadData()
    }
}
