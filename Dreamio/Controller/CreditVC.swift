//
//  CreditVC.swift
//  Dreamio
//
//  Created by Bold Lion on 21.04.19.
//  Copyright © 2019 Bold Lion. All rights reserved.
//

import UIKit
class CreditVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    let libraries = ["IQKeyboardManagerSwift", "WSTagsField", "SCLAlertView"]
    let urls = ["https://github.com/hackiftekhar/IQKeyboardManager",
                "https://github.com/whitesmith/WSTagsField",
                "https://github.com/vikmeup/SCLAlertView-Swift"]
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
    }
}

extension CreditVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return libraries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Cell_Id.creditTVCell) as! CreditTVCell
        cell.libraryName.text = libraries[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let myURL = URL(string: urls[indexPath.row]) {
            let storyboard = UIStoryboard(name: Storyboards.profile, bundle: nil)
            let creditWebViewVC = storyboard.instantiateViewController(withIdentifier: "CreditWebViewVC") as! CreditWebViewVC
            let navController = UINavigationController(rootViewController: creditWebViewVC)
            creditWebViewVC.url = myURL
            present(navController, animated: true)
        }
    }
}
