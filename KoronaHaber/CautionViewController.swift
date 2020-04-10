//
//  CautionViewController.swift
//  KoronaHaber
//
//  Created by Erim on 30.03.2020.
//  Copyright © 2020 Erim. All rights reserved.
//

import UIKit

class CautionViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        print("Caution View Controller")
        imageView.isUserInteractionEnabled = true
    }
    @IBAction func scaleImage(_ sender: UIPinchGestureRecognizer) {
//        imageView.transform = CGAffineTransform(scaleX: sender.scale, y: sender.scale)
        if let imageView = sender.view {
            imageView.transform = imageView.transform.scaledBy(x: sender.scale, y: sender.scale)
            sender.scale = 1
        }
    }
    
}
