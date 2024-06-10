//
//  WebViewController.swift
//  NewsReader
//
//  Created by ashishKT on 08/06/24.
//

import UIKit
import WebKit

class WebViewController: UIViewController {
    
    let webView =  WKWebView()
    
    //MARK:- Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }
    
    func configureURL(url: String) {
        if let url = URL(string: url) {
            let urlRequest = URLRequest(url: url)
            webView.load(urlRequest)
        }
    }
    
    func setUp() {
        self.view.backgroundColor = .systemBackground
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.navigationDelegate = self
        webView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        webView.clipsToBounds = true
        self.view.clipsToBounds = true
        view.addSubview(webView)
        
        webView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            webView.widthAnchor.constraint(equalTo: view.widthAnchor),
            webView.heightAnchor.constraint(equalTo: view.heightAnchor)
        ])
    }
    
}

extension WebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        print("Start loading")
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("End loading")
    }
}
