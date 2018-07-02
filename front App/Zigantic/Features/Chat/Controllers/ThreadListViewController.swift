//
//  ThreadListViewController.swift
//  Bityo
//
//  Created by Chirag Ganatra on 30/11/17.
//  Copyright © 2017 Chirag Ganatra. All rights reserved.
//

import UIKit
import Firebase
import AudioToolbox
import SwipeCellKit

class ThreadListViewController: UIViewController {

    @IBOutlet weak var emptyImgView: UIImageView!
    @IBOutlet weak var tblView: UITableView!
    
    var items = [DataSnapshot]()
    var buttonDisplayMode: ButtonDisplayMode = .titleAndImage
    var buttonStyle: ButtonStyle = .backgroundColor
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.emptyImgView.isHidden = true
        FSUserManager.sharedInstance.isOnline()
        self.fetchData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.emptyImgView.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .default
        
        if let selectionIndexPath = self.tblView.indexPathForSelectedRow {
            self.tblView.deselectRow(at: selectionIndexPath, animated: animated)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Downloads conversations
    func fetchData() {
        self.items = []
        Conversation.showConversations(
            completion: { (outItems) in
                self.items = outItems
//                self.items.sort{ $0.lastMessage.timestamp > $1.lastMessage.timestamp }
                DispatchQueue.main.async {
                    if self.items.count == 0 {
                        self.emptyImgView.isHidden = false
                    }
                    
                    self.tblView.reloadData()
                }
        },
            failure: {(error) in
                self.showAlert(title: appName, message: error)
        })
    }
    
    func playSound()  {
        var soundURL: NSURL?
        var soundID:SystemSoundID = 0
        let filePath = Bundle.main.path(forResource: "newMessage", ofType: "wav")
        soundURL = NSURL(fileURLWithPath: filePath!)
        AudioServicesCreateSystemSoundID(soundURL!, &soundID)
        AudioServicesPlaySystemSound(soundID)
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

extension ThreadListViewController : UITableViewDataSource, UITableViewDelegate{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.items.count == 0 {
            return 0
        } else {
            self.emptyImgView.isHidden = true
            return self.items.count
        }
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]?
    {
        let deleteAction  = UITableViewRowAction(style: .default, title: "Delete") { (rowAction, indexPath) in
            print("Delete Button tapped. Row item value = \(self.items[indexPath.row])")
        }
        return [deleteAction]
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ThreadCell", for: indexPath) as! ThreadCell
        cell.delegate = self

        switch self.items.count {
        case 0:
            return cell
        default:
            cell.clearCellData()
            cell.setupCell(items[indexPath.row])
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 100
        return UITableViewAutomaticDimension
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

extension ThreadListViewController: SwipeTableViewCellDelegate {
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        if orientation == .left {
            return nil
        }
        else {
            let delete = SwipeAction(style: .destructive, title: nil) { action, indexPath in
                print("indexpath ", indexPath.row)
                Conversation.deleteConversationRoom(refId: self.items[indexPath.row].key)
                self.items.remove(at: indexPath.row)
                self.tblView.reloadData()
            }
            configure(action: delete, with: .trash)
            return [delete]
        }
    }
    
    func configure(action: SwipeAction, with descriptor: ActionDescriptor) {
        action.title = descriptor.title(forDisplayMode: buttonDisplayMode)
        action.image = descriptor.image(forStyle: buttonStyle, displayMode: buttonDisplayMode)
        
        switch buttonStyle {
            
        case .backgroundColor:
            action.backgroundColor = descriptor.color
            
        case .circular:
            action.backgroundColor = .clear
            action.textColor = descriptor.color
            action.font = .systemFont(ofSize: 13)
            action.transitionDelegate = ScaleTransition.default
        }
    }

    
}

enum ActionDescriptor {
    case read, unread, more, flag, trash
    
    func title(forDisplayMode displayMode: ButtonDisplayMode) -> String? {
        guard displayMode != .imageOnly else { return nil }
        
        switch self {
        case .read: return "Read"
        case .unread: return "Unread"
        case .more: return "More"
        case .flag: return "Flag"
        case .trash: return "Delete"
        }
    }
    
    func image(forStyle style: ButtonStyle, displayMode: ButtonDisplayMode) -> UIImage? {
        guard displayMode != .titleOnly else { return nil }
        
        let name: String
        switch self {
        case .read: name = "Read"
        case .unread: name = "Unread"
        case .more: name = "More"
        case .flag: name = "Flag"
        case .trash: name = "Trash"
        }
        
        return UIImage(named: style == .backgroundColor ? name : name + "-circle")
    }
    
    var color: UIColor {
        switch self {
        case .read, .unread: return #colorLiteral(red: 0, green: 0.4577052593, blue: 1, alpha: 1)
        case .more: return #colorLiteral(red: 0.7803494334, green: 0.7761332393, blue: 0.7967314124, alpha: 1)
        case .flag: return #colorLiteral(red: 1, green: 0.5803921569, blue: 0, alpha: 1)
        case .trash: return #colorLiteral(red: 1, green: 0.2352941176, blue: 0.1882352941, alpha: 1)
        }
    }
}

enum ButtonDisplayMode {
    case titleAndImage, titleOnly, imageOnly
}

enum ButtonStyle {
    case backgroundColor, circular
}


