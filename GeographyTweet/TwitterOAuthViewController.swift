//
//  TwitterOAuthViewController.swift
//  GeographyTweet
//
//  Created by Mehrdad Ahmadi on 2019-03-04.
//  Copyright © 2019 Mehrdad Ahmadi. All rights reserved.
//

import UIKit
import OAuthSwift

class TwitterOAuthViewController: OAuthWebViewController, UIWebViewDelegate {
    
    // MARK: - Variabless
    
    var targetURL: URL?
    let webView = UIWebView()
    
    
    // MARK: - ViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.frame = UIScreen.main.bounds
        webView.scalesPageToFit = true
        webView.delegate = self
        view.addSubview(webView)
        loadURL()
    }
    
    
    // MARK: - Methods
    
    func loadURL() {
        guard let url = targetURL else { return }
        let urlRequest = URLRequest(url: url)
        webView.loadRequest(urlRequest)
    }
    
    override func handle(_ url: URL) {
        targetURL = url
        super.handle(url)
        loadURL()
    }
    
    
    // MARK: - UIWebViewDelegate
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebView.NavigationType) -> Bool {
        if let url = request.url, url.scheme == "oauth-swift" {
            UserDefaults.standard.setValue(true, forKey: "LoggedIn")
            dismissWebViewController()
        }
        return true
    }
    
    
}
