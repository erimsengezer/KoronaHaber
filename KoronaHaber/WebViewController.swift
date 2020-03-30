//
//  WebViewController.swift
//  KoronaHaber
//
//  Created by Erim on 30.03.2020.
//  Copyright © 2020 Erim. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController {

    @IBOutlet weak var webView: WKWebView!
    var choosenURL = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = URL(string: choosenURL)
        let urlRequest = URLRequest(url: url!)
        
        webView.load(urlRequest)
    }
    @IBAction func closeButtonClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
