//
//  DetailViewController.swift
//  Nine
//
//  Created by abc on 7/5/22.
//

import UIKit
import WebKit

class ArticlesDetailViewController: UIViewController, WKUIDelegate {
    
    static func initialize(detailItem: Item) -> ArticlesDetailViewController {
        let vc = ArticlesDetailViewController()
        vc.detailItem = detailItem
        return vc
    }
    
    private var webView: WKWebView!
    private var detailItem: Item!

    override func loadView() {
        // Create WKWebView programmatically
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        view = webView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let detailItem = detailItem else {
            print("Missing detailItem")
            return
        }
        
        let request = URLRequest(url: detailItem.url)
        webView.load(request)
        navigationItem.title = detailItem.headline
    }
}
