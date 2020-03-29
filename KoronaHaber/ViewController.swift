//
//  NewsViewController.swift
//  KoronaHaber
//
//  Created by Erim on 30.03.2020.
//  Copyright © 2020 Erim. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        print("News View Controller")
        configureCollectionView()
        
    }
    
    private func configureCollectionView() {
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
    }


}

extension ViewController : UICollectionViewDelegate {
    
}

extension ViewController : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CollectionViewCell
        cell.imageView.image = UIImage(named: "home")
        cell.label.text = "Test"
        return cell
    }
}

extension ViewController : UICollectionViewDelegateFlowLayout {
    
}
