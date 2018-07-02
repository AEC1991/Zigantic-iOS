//
//  ChildStoreViewController.swift
//  Bityo
//
//  Created by Chirag Ganatra on 30/11/17.
//  Copyright © 2017 Chirag Ganatra. All rights reserved.
//

import UIKit
import Firebase

class ChildStoreViewController: UIViewController {

    @IBOutlet weak var downConst: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    
    var user: FSUser?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
extension ChildStoreViewController : UITableViewDataSource, UITableViewDelegate{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (FSUserManager.sharedInstance.user?.products.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Storecell", for: indexPath) as! ProductCell
        if ((FSUserManager.sharedInstance.user?.products.count)! > indexPath.row) {
            cell.setupCell(FSUserManager.sharedInstance.user?.products[indexPath.row])
            return cell
        }
        else {
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        let vc = Utilities.viewController("FeedDetailViewController", onStoryboard: "Feeds") as! FeedDetailViewController
        
        FSProductManager.sharedInstance.getRefById(uid: (FSUserManager.sharedInstance.user?.products[indexPath.row])!,
                                                   completion: { (output:DataSnapshot) in
                            vc.productRef = output
                            self.navigationController?.pushViewController(vc, animated: true)
        },
                       failure: {(errorComment: String) -> Void in
                        self.showAlert(title: appName, message: errorComment)
        })
    }
}

