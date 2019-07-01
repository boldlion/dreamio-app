//
//  CreditWebViewVC.swift
//  Dreamio
//
//  Created by Bold Lion on 21.04.19.
//  Copyright © 2019 Bold Lion. All rights reserved.
//

import UIKit
import WebKit

class CreditWebViewVC: UIViewController {

    @IBOutlet weak var wkwebView: WKWebView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var url: URL?
    
    var done = UIBarButtonItem()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Library"
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        navigationController?.navigationBar.barTintColor = Colors.purpleDarker
        wkwebView.navigationDelegate = self
        doneButtonSetup()
        loadUrl(url: url)
    }
    
    func loadUrl(url: URL?) {
        if let url = url {
            let urlRequest = URLRequest(url: url)
            wkwebView.load(urlRequest)
        }
    }
    
    func doneButtonSetup() {
        done = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneTapped))
        done.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .normal)
        navigationItem.leftBarButtonItem  = done
    }
    
    @objc func doneTapped() {
        dismiss(animated: true)
    }
    
    deinit {
        print("CreditWebViewVC deinit")
    }
}

extension CreditWebViewVC: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        activityIndicator.stopAnimating()
    }
}
