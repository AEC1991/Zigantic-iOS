//
//  ChildFollowersViewController.swift
//  Bityo
//
//  Created by iOS Developer on 1/24/18.
//  Copyright © 2018 Chirag Ganatra. All rights reserved.
//

import UIKit

class ChildFollowersViewController: UIViewController {

    @IBOutlet weak var nofollowerView: UIView!
    @IBOutlet weak var followerTable: UITableView!
   
    var user:FSUser?

    override func viewDidLoad() {
        super.viewDidLoad()
        nofollowerView.isHidden = true
        getUserInfo()
        // Do any additional setup after loading the view.
    }
    
    func getUserInfo() {
        FSUserManager.sharedInstance.getMeUpdateChange(
            completion: { (output:FSUser) in
                self.user = output
                self.followerTable.reloadData()
        },
            failure: {(errorComment: String) -> Void in
                self.showAlert(title: appName, message: errorComment)
        })
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

extension ChildFollowersViewController:UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (user == nil) {
            nofollowerView.isHidden = false
            return 0
        }
        else {
            if (user?.usersFollowingMe.count == 0) {
                nofollowerView.isHidden = false
            }
            else {
                nofollowerView.isHidden = true
            }
            return (user?.usersFollowingMe.count)!
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PeopleCell", for: indexPath) as! PeopleCell
        if ((user?.usersFollowingMe.count)! > indexPath.row) {
            cell.setupCell(user?.usersFollowingMe[indexPath.row])
            return cell
        }
        else {
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
}
