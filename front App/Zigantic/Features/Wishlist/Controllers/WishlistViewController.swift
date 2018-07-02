//
//  WishlistViewController.swift
//  Bityo
//
//  Created by Chirag Ganatra on 30/11/17.
//  Copyright © 2017 Chirag Ganatra. All rights reserved.
//

import UIKit
import Firebase

class WishlistViewController: UIViewController {

    @IBOutlet weak var btnNav: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var user : FSUser?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .default
        getUserInfo()
    }
    
    func getUserInfo() {
        FSUserManager.sharedInstance.getMeUpdate(
             completion: { (output:FSUser) in
                self.user = output
                self.tableView.reloadData()
        },
             failure: {(errorComment: String) -> Void in
                self.showAlert(title: appName, message: errorComment)
        })
    }
    
    override func showAlert(title:String ,message:String) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: UIAlertControllerStyle.alert)
        
        let cancelAction = UIAlertAction(title: "OK",
                                         style: .cancel, handler: nil)
        
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func heartTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    
    @IBAction func menuTapped(_ sender: Any) {
        sideMenuController().openMenu()
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

extension WishlistViewController : UITableViewDataSource, UITableViewDelegate{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (user == nil) {
            return 0
        }
        else {
            return (user?.wishes.count)!
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Storecell", for: indexPath) as! ProductCell
        if ((user?.wishes.count)! > indexPath.row) {
            cell.setupCell(user?.wishes[indexPath.row])
            return cell
        }
        else {
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        let vc = Utilities.viewController("FeedDetailViewController", onStoryboard: "Feeds") as! FeedDetailViewController
        
        FSProductManager.sharedInstance.getRefById(uid: (user?.wishes[indexPath.row])!,
                                                   completion: { (output:DataSnapshot) in
                    vc.productRef = output
                    self.navigationController?.pushViewController(vc, animated: true)
        },
                failure: {(errorComment: String) -> Void in
                    self.showAlert(title: appName, message: errorComment)
        })
    }
}


