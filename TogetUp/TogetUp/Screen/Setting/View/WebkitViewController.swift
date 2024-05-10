//
//  WebkitViewController.swift
//  TogetUp
//
//  Created by 이예원 on 5/10/24.
//

import UIKit
import WebKit

class WebkitViewController: UIViewController {
    @IBOutlet weak var webView: WKWebView!
    var urlString: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadWebPage()
    }
    
    private func loadWebPage() {
        if let urlString = urlString, let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
}
