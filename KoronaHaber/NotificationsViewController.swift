//
//  NotificationsViewController.swift
//  KoronaHaber
//
//  Created by Erim on 30.03.2020.
//  Copyright © 2020 Erim. All rights reserved.
//

import UIKit
import Firebase

class NotificationsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var titleArray = [String]()
    var subtitleArray = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        print("view Notifications View Controller")
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        getNotifications()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        configureTableView()
    }

    private func configureTableView() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    private func getNotifications() {
        let firestore = Firestore.firestore()
        
        firestore.collection("notifications").addSnapshotListener { (snapshot, error) in
            if error != nil {
                let alert = UIAlertController(title: "HATA !", message: "Bir hata oluştu.", preferredStyle: .alert)
                let okButton = UIAlertAction(title: "Tamam", style: .default, handler: nil)
                alert.addAction(okButton)
                self.present(alert, animated: true, completion: nil)
            }
            else {
                if snapshot?.isEmpty != true {
                    self.titleArray.removeAll(keepingCapacity: false)
                    self.subtitleArray.removeAll(keepingCapacity: false)
                    
                    for document in snapshot!.documents {
                        
                        if let title = document["title"] {
                            print("Title : \(title)")
                            self.titleArray.append(title as! String)
                        }
                        if let subtitle = document["subtitle"] {
                            self.subtitleArray.append(subtitle as! String)
                        }
                    }
                    self.tableView.reloadData()
                }
            }
        }
    }

}

extension NotificationsViewController : UITableViewDelegate {
    
}

extension NotificationsViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titleArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationTableViewCell", for: indexPath) as! NotificationTableViewCell
        cell.titleLabel.text = titleArray[indexPath.row]
        cell.descriptionLabel.text = subtitleArray[indexPath.row]
        return cell
    }
    
    
}
