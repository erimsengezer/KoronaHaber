//
//  NewsViewController.swift
//  KoronaHaber
//
//  Created by Erim on 30.03.2020.
//  Copyright © 2020 Erim. All rights reserved.
//

import UIKit
import Firebase
import Alamofire
import AlamofireImage
import Lottie
import SDWebImage
import MarqueeLabel
import GoogleMobileAds

class ViewController: UIViewController, GADInterstitialDelegate {

    var interstitial : GADInterstitial!
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var blurView: UIView!
    @IBOutlet weak var animationView: AnimationView!
    @IBOutlet weak var countLabel: MarqueeLabel!
    
    var titles = [String]()
    var descrips = [String]()
    var images = [String]()
    var lastImages = [UIImage]()
    var urls = [String]()
    
    var selectedURL = ""
    let refresher = UIRefreshControl()
    var fetchingMore = false
    var started = 0
    var ended = 20
    var totalConfirmed = ""
    var totalDeaths = ""
    var totalRecovered = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("News View Controller")
        
        getAnimation()
        getData()
        getCount()
        scrollingLabel()
        
        interstitial = GADInterstitial(adUnitID: "ca-app-pub-9394312041468898/2708871623")
        interstitial.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.configureCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(scrollingLabel), name: NSNotification.Name(rawValue: "getCount"), object: nil)
        loadADS()
        NotificationCenter.default.addObserver(self, selector: #selector(showADS), name: NSNotification.Name("ADS"), object: nil)
    }
    
    func loadADS() {
        let request = GADRequest()
        interstitial.load(request)
    }
    
    @objc func showADS() {
        if interstitial.isReady {
            print("Show Ads")
            interstitial.present(fromRootViewController: self)
        }
    }
    
    @objc private func scrollingLabel() {
        countLabel.text = " Vaka Sayısı : \(totalConfirmed), Ölüm Sayısı : \(totalDeaths), İyileşen hasta sayısı : \(totalRecovered)"
        countLabel.type = .continuous

        countLabel.unpauseLabel()
        countLabel.speed = .rate(50)
        countLabel.animationDelay = 0.0
    }
    
    private func getCount() {
        let firestore = Firestore.firestore()
        
        firestore.collection("counts").addSnapshotListener { (snapshot, error) in
            if error == nil {
                if snapshot?.isEmpty != true {
                    for document in snapshot!.documents {
                        if let totalConfirmed = document["totalConfirmed"] {
                            self.totalConfirmed = totalConfirmed as! String
                        }
                        if let totalDeaths = document["totalDeaths"] {
                            self.totalDeaths = totalDeaths as! String
                        }
                        if let totalRecovered = document["totalRecovered"] {
                            self.totalRecovered = totalRecovered as! String
                        }
                    }
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "getCount"), object: nil)
                }
            }
        }
    }
    
    private func getData() {
        let firestore = Firestore.firestore()
        firestore.collection("news")
            .limit(to: 100)
            .order(by: "datetime", descending: true)
            .addSnapshotListener { (snapshot, error) in
            if error != nil {
                print(error?.localizedDescription ?? "Error")
            }
            else {
                if snapshot?.isEmpty != true {
                    print("StartedF \(self.started)")
                    for document in snapshot!.documents {
                        if let title = document.get("title") as? String {
                            self.titles.append(title)
                        }

                        if let description = document.get("description") as? String {
                            self.descrips.append(description)
                        }

                        if let image = document.get("image") as? String {
                            self.images.append(image)
                        }

                        if let url = document.get("url") as? String {
                            self.urls.append(url)
                        }
                    }
                }
                self.collectionView.reloadData()
            }
        }
    }
    
    private func configureCollectionView() {
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        
        refresher.addTarget(self, action: #selector(refreshCollectionView), for: .valueChanged)
        collectionView.addSubview(refresher)
    }
    
    @objc func refreshCollectionView() {
        print("Refresh !")
        Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { (timer) in
            self.collectionView.reloadData()
            self.refresher.endRefreshing()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        
        if offsetY > contentHeight - scrollView.frame.height {
            if !fetchingMore {
                beginBatchFetch()
            }
        }
    }
    
    func beginBatchFetch() {
        fetchingMore = true
        print("begin fetching more")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
//            let newItems = (self.titles.count...self.titles.count + 20).map { index in index }
//            self.titles.append(newItems)
            self.started += 20
            self.ended += 20
            print("Started \(self.started)")
            
            self.fetchingMore = false
            self.collectionView.reloadData()
        })
    }

    
//MARK: - Loading Animation Start
    
    func addBlurEffect() {
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        view.addSubview(blurEffectView)
        blurView.addSubview(blurEffectView)
    }

    func playAnimation() {
        addBlurEffect()
        let stayAnimation = Animation.named("stay-home")

        animationView.animation = stayAnimation
        animationView.loopMode = .loop

        animationView.play()
    }

    func stopAnimation() {
        self.animationView.stop()
//        self.animationView.removeFromSuperview()
//        self.blurView.removeFromSuperview()
        self.animationView.isHidden = true
        self.blurView.isHidden = true
    }

    func getAnimation() {
        playAnimation()
        Timer.scheduledTimer(withTimeInterval: 4.0, repeats: false) { (timer) in
            self.stopAnimation()
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
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "WebView") as! WebViewController
        vc.choosenURL = selectedURL
        
        self.present(vc, animated: true, completion: nil)
    }

    func interstitialWillLeaveApplication(_ ad: GADInterstitial) {
        print("interstitialWillLeaveApplication")
    }

    func interstitialWillPresentScreen(_ ad: GADInterstitial) {
        print("interstitialWillPresentScreen")
    }
}

extension ViewController : UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Clicked \(titles[indexPath.row])")
        selectedURL = urls[indexPath.row]
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "WebView") as! WebViewController
        vc.choosenURL = selectedURL
        self.present(vc, animated: true, completion: nil)
        
    }
}

extension ViewController : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return titles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CollectionViewCell
        let imageURL = URL(string: images[indexPath.row])!
        cell.imageView.sd_setImage(with: imageURL, placeholderImage: UIImage(named: "loading.gif"), options: .continueInBackground)
        cell.label.text = titles[indexPath.row]
        cell.descLabel.text = descrips[indexPath.row]
        return cell
    }
}

extension ViewController : UICollectionViewDelegateFlowLayout {
    
}
