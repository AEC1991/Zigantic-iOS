//
//  SidemenuViewController.swift
//  Bityo
//
//  Created by Chirag Ganatra on 28/11/17.
//  Copyright © 2017 Chirag Ganatra. All rights reserved.
//

import UIKit
import JDStatusBarNotification

class SidemenuViewController: UIViewController {

    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var avatarImageView: FSImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var btnNotification: SSBadgeButton!
    
    var user:FSUser?
    var items : [String] = ["Feed", "Dashboard", "Messages", "Wallet", "Order Management", "Wishlist", "My Profile"]
    var selectedIndex = 0
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        statusBar?.backgroundColor = .clear
        
        FSUserManager.sharedInstance.getMeUpdateChange(
            completion: { (output:FSUser) in
                self.user = output
                self.initUI()
        },
            failure: {(errorComment: String) -> Void in
                if (errorComment != FSMessage.USER_LOGOUT) {
                    self.showAlert(title: appName, message: errorComment)
                }
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIApplication.shared.statusBarStyle = .default

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.statusBarStyle = .lightContent
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initUI() {
        
        if (user!.unreadNum > 0) {
            btnNotification.badgeEdgeInsets = UIEdgeInsets(top: 15, left: 0, bottom: 0, right: 10)
            btnNotification.badge = String(user!.unreadNum)
            btnNotification.badgeLabel.isHidden = false
        }
        else {
            btnNotification.badgeLabel.isHidden = true
        }
        
        fullNameLabel.text = user?.username
        if ((user?.avatarImage) != nil)
        {
            avatarImageView.image = user?.avatarImage
        }
        else {
            if (user?.imgUrl != nil)
            {
                avatarImageView.showLoading()
                Utilities.downloadImage(url: (user?.imgUrl)!, completion: {(avatarImage) in
                    self.avatarImageView.hideLoading()
                    FSUserManager.sharedInstance.user?.avatarImage = avatarImage
                    self.avatarImageView.image = avatarImage
                },
                    failure: {(errorComment: String) -> Void in
                        self.avatarImageView.hideLoading()
                        self.avatarImageView.image = UIImage(named: "user_default")
                })
            }
            else {
                self.avatarImageView.image = UIImage(named: "user_default")
            }
        }
    }

    
    @IBAction func notificationTapped(_ sender: Any) {
        gotoViewController(name: "NavNotifications", storyBoard: "Settings")
    }
    
    @IBAction func settingsTapped(_ sender: Any) {
        gotoViewController(name: "NavSettings", storyBoard: "Settings")
    }
    
    func gotoViewController(name : String,storyBoard : String)
    {
        let vc = Utilities.viewController(name, onStoryboard: storyBoard)
        self.sideMenuController().changeContentViewController(vc, closeMenu: true)
    }
}

extension SidemenuViewController : UITableViewDataSource, UITableViewDelegate{
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SideCell", for: indexPath) as! SideCell
        cell.lblName.text = items[indexPath.row]
        if indexPath.row == self.selectedIndex {
            cell.viewSelector.backgroundColor = themeOrangeColor
        }else{
            cell.viewSelector.backgroundColor = .clear
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedIndex = indexPath.row
        self.tblView.reloadData()
        switch indexPath.row {
        case 0:
            gotoViewController(name: "navFeeds", storyBoard: "Feeds")
            break
        case 1:            
            gotoViewController(name: "NavDashboard", storyBoard: "DashBoard")
            break
        case 2:
            gotoViewController(name: "NavChat", storyBoard: "Chat")
            break
        case 3:
            gotoViewController(name: "navWallet", storyBoard: "Wallet")
            break

//            JDStatusBarNotification.show(withStatus: "Coming soon!!!", dismissAfter: 3.0, styleName: JDStatusBarStyleError)
            
            break
        case 4:            
            gotoViewController(name: "NavOrder", storyBoard: "Order")
            break
        case 5:
            gotoViewController(name: "navWish", storyBoard: "Wishlist")
            break
        case 6:
            gotoViewController(name: "navProfile", storyBoard: "Wishlist")
            break
        default:
            break
        }
    }
}

class SideCell : UITableViewCell
{
    
    @IBOutlet weak var viewSelector: UIView!
    @IBOutlet weak var lblName : UILabel!
    
    override func awakeFromNib() {
        
    }
}
