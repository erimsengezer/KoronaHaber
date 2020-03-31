//
//  NewsViewController.swift
//  KoronaHaber
//
//  Created by Erim on 30.03.2020.
//  Copyright © 2020 Erim. All rights reserved.
//

import UIKit
import Firebase
import AlamofireImage
import Lottie

class ViewController: UIViewController {

    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var blurView: UIView!
    @IBOutlet weak var animationView: AnimationView!
    
    var titles = [String]()
    var descrips = [String]()
    var images = [String]()
    var urls = [String]()
    
    var selectedURL = ""
    let refresher = UIRefreshControl()
    var fetchingMore = false
    var started = 0
    var ended = 20
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        getAnimation()
//        getData()
        print("News View Controller")
        
        let strings = ["John", "Paul", "George", "Ringo"]
        let uppercased = strings.suffix(2)
        print("Upper \(uppercased)")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getData()
        configureCollectionView()
    }
    
    private func getData() {
        let firestore = Firestore.firestore()
        firestore.collection("news")
            .limit(to: 20)
            .order(by: "datetime")
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
        cell.imageView.af.setImage(withURL: imageURL)
        cell.label.text = titles[indexPath.row]
        return cell
    }
}

extension ViewController : UICollectionViewDelegateFlowLayout {
    
}
