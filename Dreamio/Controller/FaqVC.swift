//
//  FaqVC.swift
//  Dreamio
//
//  Created by Bold Lion on 1.05.19.
//  Copyright © 2019 Bold Lion. All rights reserved.
//

import UIKit
import WebKit

class FaqVC: UIViewController {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var wkWebView: WKWebView!
    let url = URL(string: "https://dreamioapp.github.io/faq.html")

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadUrl(url: url)
        wkWebView.navigationDelegate = self
    }

    func loadUrl(url: URL?) {
        if let url = url {
            let urlRequest = URLRequest(url: url)
            wkWebView.load(urlRequest)
        }
    }
    
    deinit {
        print("FaqVC deinit")
    }
}

extension FaqVC: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        activityIndicator.stopAnimating()
    }
}
