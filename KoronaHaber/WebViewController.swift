//
//  WebViewController.swift
//  KoronaHaber
//
//  Created by Erim on 30.03.2020.
//  Copyright © 2020 Erim. All rights reserved.
//

import UIKit
import WebKit
import Firebase
import GoogleMobileAds

class WebViewController: UIViewController, GADInterstitialDelegate {
    
    var interstitial : GADInterstitial!
    
    @IBOutlet weak var webView: WKWebView!
    var choosenURL = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = URL(string: choosenURL)
        let urlRequest = URLRequest(url: url!)
        
        webView.load(urlRequest)
        interstitial = GADInterstitial(adUnitID: "ca-app-pub-9394312041468898/2708871623")
        interstitial.delegate = self
        loadADS()
    }
    @IBAction func closeButtonClicked(_ sender: Any) {
        showADS()
    }
    
    func loadADS() {
        let request = GADRequest()
        interstitial.load(request)
    }
    
    func showADS() {
        if interstitial.isReady {
            print("Show Ads")
            interstitial.present(fromRootViewController: self)
        }
    }
    
    func interstitial(_ ad: GADInterstitial, didFailToReceiveAdWithError error: GADRequestError) {
        print("interstitialDidFailToReceiveAdWithError:\(error.localizedDescription)")

    }

    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        print("interstitialDidReceiveAd")

    }

    func interstitialWillDismissScreen(_ ad: GADInterstitial) {
        print("interstitialWillDismissScreen")

    }

    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        print("interstitialDidDismissScreen")
        self.dismiss(animated: true, completion: nil)
    }

    func interstitialWillLeaveApplication(_ ad: GADInterstitial) {
        print("interstitialWillLeaveApplication")
    }

    func interstitialWillPresentScreen(_ ad: GADInterstitial) {
        print("interstitialWillPresentScreen")
    }
    
}
