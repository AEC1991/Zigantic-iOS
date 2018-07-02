//
//  ChildFollowingViewController.swift
//  Bityo
//
//  Created by iOS Developer on 1/24/18.
//  Copyright © 2018 Chirag Ganatra. All rights reserved.
//

import UIKit
import Firebase

class ChildFollowingViewController: UIViewController {
    
    var user:FSUser?
    var selectedUser:FSUser?
    var usersImFollowing: [String] = []
    var products: [String] = []
    
    @IBOutlet weak var avatarCollection: UICollectionView!
    @IBOutlet weak var userView: UIView!
    @IBOutlet weak var userLine: UIView!
    
    @IBOutlet weak var avatarImgView: FSImageView!
    @IBOutlet weak var lblFullname: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    
    @IBOutlet weak var followingView: UIView!
    @IBOutlet weak var checkImgView: UIImageView!
    @IBOutlet weak var btnFollowing: UIButton!
    
    @IBOutlet weak var feedCollection: UICollectionView!
    
    @IBOutlet weak var nofollowingView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nofollowingView.isHidden = true
        getMyInfo()
        userView.isHidden = true
        userLine.isHidden = true
        
        let userAvatarGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapUser))
        avatarImgView.addGestureRecognizer(userAvatarGesture)
        
        let followGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapFollow))
        followingView.addGestureRecognizer(followGesture)

        
        // Do any additional setup after loading the view.
    }
    
    func tapFollow(sender: UITapGestureRecognizer){
        doFollow()
    }
    
    func tapUser(sender: UITapGestureRecognizer){
        
        if (selectedUser != nil) {
            let vc = Utilities.viewController("ParentMyProfileViewController", onStoryboard: "Wishlist") as! ParentMyProfileViewController
            vc.isFrom = "FeedDetails"
            vc.user = self.selectedUser
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func getMyInfo() {
        FSUserManager.sharedInstance.getByIdNoAvatarSingleEvent(uid:(FSUserManager.sharedInstance.user?.uid)!,
            completion: { (output:FSUser) in
                self.user = output
                self.usersImFollowing = output.usersImFollowing
                self.avatarCollection.reloadData()
        },
            failure: {(errorComment: String) -> Void in
                self.showAlert(title: appName, message: errorComment)
        })
    }
    
    func getUserInfo(_ userId:String) {
        FSUserManager.sharedInstance.getByIdNoAvatar(uid: userId,
                     completion: { (output:FSUser) in
                        self.selectedUser = output
                        self.products = output.products
                        self.showUserInfo(output)
                        if (self.userView.isHidden == true) {
                            self.userView.isHidden = false
                            self.userLine.isHidden = false
                        }
                        self.feedCollection.reloadData()
        },
                     failure: {(errorComment: String) -> Void in
                        self.showAlert(title: appName, message: errorComment)
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showUserInfo(_ user:FSUser) {
        lblFullname.text = user.username
        
        let calendar = Calendar.current
        let curDate = Date()
        let year = calendar.component(.year, from: (user.time)!)
        let month = calendar.component(.month, from: (user.time)!)
        lblTime.text =  "Member Since " + String(month) + "/" + String(year)
        
        self.avatarImgView.showLoading()
        self.avatarImgView?.sd_setImage(with: user.imgUrl, completed: { (image, error, type, url) in
            self.avatarImgView.hideLoading()
            if (image == nil || error != nil) {
                self.avatarImgView.image = UIImage(named: "user_default")
            }
        })
    }
    
    func doFollow() {
        if (FSUserManager.sharedInstance.checkImFollowing(selectedUser!) == true) {
            FSUserManager.sharedInstance.removeFollowingUser(inUser: selectedUser!)
            self.checkImgView.image = UIImage(named: "plus_white")
            btnFollowing.setTitle("Follow", for: .normal)
        }
        else {
            FSUserManager.sharedInstance.addFollowingUser(inUser: selectedUser!)
            self.checkImgView.image = UIImage(named: "check")
            btnFollowing.setTitle("Following", for: .normal)
        }
    }
    
    @IBAction func onFollow(_ sender: Any) {
        doFollow()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}

extension ChildFollowingViewController:UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == self.avatarCollection {
            return CGSize(width: 50.0, height: 50.0)
        }
        else {
            return CGSize(width: 95.0, height: 95.0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (collectionView == avatarCollection) {
            if (usersImFollowing != []) {
                nofollowingView.isHidden = true
                return usersImFollowing.count
            }
            else {
                nofollowingView.isHidden = false
                return 0
            }
        }
        else {
            if (products != nil) {
                return products.count
            }
            else {
                return 0
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == avatarCollection {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AvatarCell", for: indexPath) as! AvatarCell
            cell.setupCell(usersImFollowing[indexPath.row])
           return cell
        }
        else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FeedCell", for: indexPath) as! FeedCell
            cell.getById(products[indexPath.row])
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == avatarCollection {
            getUserInfo(usersImFollowing[indexPath.row])
        }
        else if collectionView == feedCollection {
            let vc = Utilities.viewController("FeedDetailViewController", onStoryboard: "Feeds") as! FeedDetailViewController

            FSProductManager.sharedInstance.getRefById(uid: products[indexPath.row],
                       completion: { (output:DataSnapshot) in
                            vc.productRef = output
                            self.navigationController?.pushViewController(vc, animated: true)
            },
                       failure: {(errorComment: String) -> Void in
                            self.showAlert(title: appName, message: errorComment)
            })
        }
    }
}
