//
//  NotificationsViewController.swift
//  Bityo
//
//  Created by Chirag Ganatra on 29/11/17.
//  Copyright © 2017 Chirag Ganatra. All rights reserved.
//

import UIKit
import FirebaseDatabase

class NotificationsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var notifies = [FSNotification]()
    var items = [DataSnapshot]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.fetchData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.notifies = DELEGATE.notifies
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        UIApplication.shared.statusBarStyle = .default
    }
    
    //Downloads conversations
    func fetchData() {
        self.items = []
        Conversation.showConversations(
            completion: { (outItems) in
                self.items = outItems
                //                self.items.sort{ $0.lastMessage.timestamp > $1.lastMessage.timestamp }
                DispatchQueue.main.async {
                    
                    self.tableView.reloadData()
                }
        },
            failure: {(error) in
                self.showAlert(title: appName, message: error)
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
    @IBAction func menuTapped(_ sender: Any) {
        self.sideMenuController().openMenu()
    }

}
extension NotificationsViewController : UITableViewDelegate, UITableViewDataSource{
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (items.count > 0) {
            return items.count
        }
        else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationCell", for: indexPath) as! NotificationCell
        
        switch self.items.count {
        case 0:
            return cell
        default:
            cell.clearCellData()
            cell.setupCell(items[indexPath.row])
            
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        gotoMessage(self.items[indexPath.row])
    }
    
    func gotoMessage(_ ref:DataSnapshot?) {
        
        let idData = (ref!.key).components(separatedBy: ":")
        let productId = idData[0]
        let partnerId = idData[1]
        let valueDic = ref!.value as! NSDictionary
        let conversationId = valueDic["location"] as! String
        
        FSUserManager.sharedInstance.getByIdNoAvatarSingleEvent(uid:partnerId,
            completion: { (partner:FSUser) in
                FSProductManager.sharedInstance.getById(uid: productId,
                    completion: { (output:FSProduct) in
                        DispatchQueue.main.async {
                            let vc = Utilities.viewController("MessagesViewController", onStoryboard: "Chat") as! MessagesViewController
                            vc.product = output
                            vc.partner = partner
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                },
                    failure: {(errorComment: String) -> Void in
                        self.showAlert(title: appName, message: errorComment)
                })
        },
                failure: {(errorComment: String) -> Void in
                    self.showAlert(title: appName, message: errorComment)
        })
    }
}


