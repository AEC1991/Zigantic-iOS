//
//  UserListVC.swift
//  Zigantic
//
//  Created by iOS Developer on 4/3/18.
//  Copyright © 2018 Chirag Ganatra. All rights reserved.
//

import UIKit
import Firebase

class UserListVC: UIViewController {
    
    @IBOutlet weak var userCollection: UICollectionView!
    var resultFeeds:[DataSnapshot] = []
    var searchFeeds:[DataSnapshot] = []
    var selectedUser:FSUser?
    
    private let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getFeeds()
    }
    
    func getFeeds() {
        FSUserManager.sharedInstance.getUsers(
            completion: { (outFeeds) in
                DispatchQueue.main.async(execute: {
                    self.resultFeeds = outFeeds
                    self.arrangeData()
                    
                    self.userCollection.reloadData()
                    self.userCollection.collectionViewLayout.invalidateLayout()
                    
                    self.refreshControl.endRefreshing()
                })
        },
            failure: {(error) in
                self.showAlert(title: appName, message: error)
        })
    }
    
    func arrangeData() {
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let editProfile = segue.destination as? EditProfileViewController {
            editProfile.user = selectedUser
        }
    }
}

extension UserListVC : UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return resultFeeds.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UserCell", for: indexPath) as! UserCell
        cell.setupCell(ref: self.resultFeeds[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cellRef = resultFeeds[indexPath.row]
        var data = cellRef.value as? NSDictionary
        selectedUser = FSUser(dataDictionary: data!)
        self.performSegue(withIdentifier: "show.user", sender: nil)
    }
}

