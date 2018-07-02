//
//  ChildProfileDetailsViewController.swift
//  Bityo
//
//  Created by Chirag Ganatra on 30/11/17.
//  Copyright © 2017 Chirag Ganatra. All rights reserved.
//

import UIKit

class ChildProfileDetailsViewController: UIViewController {

    @IBOutlet weak var btnMsg: UIButton!
    @IBOutlet weak var btnFollow: UIButton!
    @IBOutlet weak var constTwoButtonHeight: NSLayoutConstraint!
    
    @IBOutlet weak var avatarImageView: FSImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var phoneTxt: UITextField!
    @IBOutlet weak var followingsCountLbl: UILabel!
    @IBOutlet weak var followersCountLbl: UILabel!
    @IBOutlet weak var ratingLbl: UILabel!
    @IBOutlet weak var totalTransactionLbl: UITextField!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var followersView: UIView!
    @IBOutlet weak var followingView: UIView!
    
    var user : FSUser?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        let tapFollowerGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapFollower))
        followersView.addGestureRecognizer(tapFollowerGesture)

        let tapFollowingGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapFollowing))
        followingView.addGestureRecognizer(tapFollowingGesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getUserInfo()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tapFollower(sender: UITapGestureRecognizer){
        let vc = Utilities.viewController("FollowParentViewController", onStoryboard: "Follow") as! FollowParentViewController
        self.navigationController?.pushViewController(vc, animated: true)
//        let vc = Utilities.viewController("ChildFollowersViewController", onStoryboard: "Follow") as! ChildFollowersViewController
//        self.navigationController?.pushViewController(vc, animated: true)

    }
    
    func tapFollowing(sender: UITapGestureRecognizer){
        let vc = Utilities.viewController("FollowParentViewController", onStoryboard: "Follow") as! FollowParentViewController
        self.navigationController?.pushViewController(vc, animated: true)

//        let vc = Utilities.viewController("ChildFollowingViewController", onStoryboard: "Follow") as! ChildFollowingViewController
//        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func getUserInfo() {
        FSUserManager.sharedInstance.getByIdNoAvatar(uid: (user?.uid)!,
             completion: { (output:FSUser) in
                self.user = output
                self.showUserInfo()
        },
             failure: {(errorComment: String) -> Void in
                self.showAlert(title: appName, message: errorComment)
        })
    }
    
    func showUserInfo() {
        emailTxt.text = user?.email
        phoneTxt.text = user?.phone
        ratingLbl.text = String((user?.rating)!)
        followingsCountLbl.text = String((user?.usersImFollowing.count)!)
        followersCountLbl.text = String((user?.usersFollowingMe.count)!)
        
        if (FSUserManager.sharedInstance.checkImFollowing(user!) == true) {
            btnFollow.setTitle("Unfollow", for: .normal)
        }
        else {
            btnFollow.setTitle("Follow", for: .normal)
        }
        
        avatarImageView.layer.cornerRadius = avatarImageView.bounds.width / 2
        avatarImageView.layer.masksToBounds = true
        
        if (user?.imgUrl != nil && user?.imgUrl?.absoluteString != "") {
            avatarImageView.showLoading()
            Utilities.downloadImage(url: (user?.imgUrl)!, completion: {(avatarImage) in
                self.avatarImageView.hideLoading()
                self.user?.avatarImage = avatarImage
                self.avatarImageView.image = avatarImage
            },
                failure: {(errorComment: String) -> Void in
                    self.avatarImageView.hideLoading()
            })
        }
        else {
            self.avatarImageView.image = UIImage(named: "user_default")
        }
    }
    
    @IBAction func onFollow(_ sender: Any) {
        if (FSUserManager.sharedInstance.checkImFollowing(user!) == true) {
            FSUserManager.sharedInstance.removeFollowingUser(inUser: user!)
        }
        else {
            FSUserManager.sharedInstance.addFollowingUser(inUser: user!)
        }
    }
    
    @IBAction func onMessage(_ sender: Any) {
        let vc = Utilities.viewController("MessagesViewController", onStoryboard: "Chat") as! MessagesViewController
        self.navigationController?.pushViewController(vc, animated: true)
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

extension ChildProfileDetailsViewController:UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "verifyCell", for: indexPath) as! VerifyCell
        
        if ((user?.verifiedLinks.count)! <= indexPath.row) {
            return cell
        }
        cell.lblReport.text = "Confirmed\n" + (user?.verifiedLinks[indexPath.row])!
        cell.verifyImgView.image = UIImage(named: (user?.verifiedLinks[indexPath.row])!)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize  {
            return CGSize(width: 10, height: 160)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (user?.verifiedLinks == nil) {
            return 0
        }
        else {
            return (user?.verifiedLinks.count)!
        }
    }

}

class VerifyCell:UICollectionViewCell {
    
    @IBOutlet weak var verifyImgView: UIImageView!
    
    @IBOutlet weak var lblReport: UILabel!
    
    override func awakeFromNib() {
    }
}




