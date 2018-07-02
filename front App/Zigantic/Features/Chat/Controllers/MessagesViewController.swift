//
//  MessagesViewController.swift
//  Bityo
//
//  Created by Chirag Ganatra on 30/11/17.
//  Copyright © 2017 Chirag Ganatra. All rights reserved.
//

import UIKit
import Photos
import Firebase
import CoreLocation
import IQKeyboardManagerSwift
import MapKit

class MessagesViewController: UIViewController, UITextViewDelegate {
    
    let minTextViewHeight: CGFloat = 36
    let maxTextViewHeight: CGFloat = 108
    
    @IBOutlet weak var avatarImgView: FSImageView!
    @IBOutlet weak var lblFullname: UILabel!
    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var ratingView: FloatRatingView!
    
    @IBOutlet weak var recvLocationImg: FSImageView!
    @IBOutlet weak var lblOfferTime: UILabel!
    @IBOutlet weak var productImgView: FSImageView!
    @IBOutlet weak var lblPrice: UILabel!
    
    @IBOutlet weak var btnReject: UIButton!
    @IBOutlet weak var textViewHeight: NSLayoutConstraint!
    @IBOutlet weak var tblview: UITableView!
    
    @IBOutlet weak var autoTxtView: AutoTextView!
    
    private let refreshControl = UIRefreshControl()
    @IBOutlet weak var statusTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var headerTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    var product:FSProduct?
    var partner:FSUser?
    
    var items = [Message]()
    
    var currentUser: FSUser?
    var cachedMapSnapshotImage: UIImage?
    var canSendLocation = true
    
    // The magic sauce
    // This is how we attach the input bar to the keyboard
        
    @IBAction func onAcceptOffer(_ sender: Any) {
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.currentUser = FSUserManager.sharedInstance.user
        setupTopBar()
        setupUI()
        self.fetchData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if (self.items.count > 0) {
            self.tblview.scrollToRow(at: IndexPath(row: items.count - 1, section: 0), at: .bottom, animated: false)
        }
        NotificationCenter.default.addObserver(self, selector: #selector(self.showKeyboard(notification:)), name: Notification.Name.UIKeyboardWillShow, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        IQKeyboardManager.sharedManager().enable = false
        UIApplication.shared.statusBarStyle = .default
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.sharedManager().enable = true
        NotificationCenter.default.removeObserver(self)
        DELEGATE.curConversationId = ""
    }

    func setupTopBar() {
        self.avatarImgView.showLoading()
        self.avatarImgView?.sd_setImage(with: partner?.imgUrl, completed: { (image, error, type, url) in
            self.avatarImgView.hideLoading()
            self.partner?.avatarImage = image

            if (error != nil || image == nil) {
                self.avatarImgView.image = UIImage(named: "user_default")
                self.partner?.avatarImage = UIImage(named: "user_default")
            }
        })
        
        lblFullname.text = partner?.username
        lblLocation.text = partner?.address
        productImgView.showLoading()
        let imgUrl = self.product?.imgUrls![0] as? String

        self.productImgView?.sd_setImage(with: URL(string: imgUrl!), completed: { (image, error, type, url) in
            self.productImgView.hideLoading()
        })
        
        let tapAvatarGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapAvatar))
        self.avatarImgView.addGestureRecognizer(tapAvatarGesture)
        
        let tapProductGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapProduct))
        self.productImgView.addGestureRecognizer(tapProductGesture)
        
    }
    
    func setupUI() {
        
        if (UIScreen.main.nativeBounds.height == 2436) {
            headerTopConstraint.constant = -24.0
        }
        else {
            headerTopConstraint.constant = -20.0
        }
        
        // Add Refresh Control to Table View
        if #available(iOS 10.0, *) {
            refreshControl.tintColor = UIColor(rgb: 0xFECD24, a: 1.0)
            tblview.refreshControl = refreshControl
        } else {
            tblview.addSubview(refreshControl)
        }
        self.refreshControl.addTarget(self, action: #selector(handleRefresh), for: UIControlEvents.valueChanged)
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeDown.direction = UISwipeGestureRecognizerDirection.down
        self.view.addGestureRecognizer(swipeDown)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.hideKeyboard))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    @objc func tapAvatar() {
        let vc = Utilities.viewController("ParentMyProfileViewController", onStoryboard: "Wishlist") as! ParentMyProfileViewController
        vc.isFrom = "FeedDetails"
        vc.user = self.partner
        self.navigationController?.pushViewController(vc, animated: true)
    }

    @objc func tapProduct() {
        let vc = Utilities.viewController("FeedDetailViewController", onStoryboard: "Feeds") as! FeedDetailViewController
        
        FSProductManager.sharedInstance.getRefById(uid: (product?.uid)!,
               completion: { (output:DataSnapshot) in
                    vc.productRef = output
                    self.navigationController?.pushViewController(vc, animated: true)
        },
               failure: {(errorComment: String) -> Void in
                    self.showAlert(title: appName, message: errorComment)
        })
    }
    
    @objc func hideKeyboard() {
        self.view.endEditing(true)
        tableTopConstraint.constant = 107
        bottomConstraint.constant = 8
    }

    func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        self.autoTxtView.endEditing(true)
        tableTopConstraint.constant = 107
        bottomConstraint.constant = 8
    }
    
    func isRecevierTyping(){
        FSUser.collection.child((self.currentUser?.uid)!).child("typingIndicator").queryOrderedByValue().queryEqual(toValue: true).observe(.value) { (data: DataSnapshot) in
            print("Typing")
        }
    }

    //Downloads messages
    func fetchData() {
        self.items = [Message]()
        Message.downloadAllMessages(productId:(self.product?.uid)!, toID:partner!.uid,
                completion: { (message:Message) in
                    
                    if (DELEGATE.curConversationId == "") {
                        DELEGATE.curConversationId = message.conversationID
                    }
                    
                    self.items.append(message)
                    self.items.sort{ $0.timestamp < $1.timestamp }
                    self.tblview.reloadData()
                    self.tblview.scrollToRow(at: IndexPath.init(row: self.items.count - 1, section: 0), at: .bottom, animated: false)
                    self.refreshControl.endRefreshing()
                    
                    Message.markMessagesRead(readMsg: message)                    
        },
                failure: {(errorComment: String) -> Void in
                    self.showAlert(title: appName, message: errorComment)
        })
    }
    
    func composeMessage(type: MessageType, content: Any)  {
        let message = Message.init(type: type, content: content, owner: .sender, timestamp: Date().iso8601, isRead: false)
        Message.send(message: message, toID: partner!.uid, productID: product!.uid, completion: {(_) in
        })
    }
    
    func checkLocationPermission() -> Bool {
        var state = false
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            state = true
        case .authorizedAlways:
            state = true
        default: break
        }
        return state
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if (items.count > 0) {
            self.tblview.scrollToRow(at: IndexPath(row: items.count-1, section: 0), at: .bottom, animated: false)
        }
        var height = ceil(textView.contentSize.height) // ceil to avoid decimal
        print(height)
        if (height < minTextViewHeight + 1) { // min cap, + 5 to avoid tiny height difference at min height
            height = minTextViewHeight
        }
        if (height > maxTextViewHeight) { // max cap
            height = maxTextViewHeight
        }
        
        if height != textViewHeight.constant { // set when height changed
            textViewHeight.constant = height // change the value of NSLayoutConstraint
            textView.setContentOffset(CGPoint.zero, animated: false) // scroll to top to avoid "wrong contentOffset" artefact when line count changes
        }
        
        if (textView.text?.isEmpty)! {
            FSUser.collection.child((self.currentUser?.uid)!).child("typingIndicator").setValue(false)
        } else {
            FSUser.collection.child((self.currentUser?.uid)!).child("typingIndicator").setValue(true)
        }
    }
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        self.refreshControl.endRefreshing()
//        fetchData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onLocation(_ sender: Any) {
        self.performSegue(withIdentifier: "show.location", sender: nil)
    }
    
    @IBAction func sendMessage(_ sender: Any) {
        if let text = self.autoTxtView.text {
            if text.characters.count > 0 {
                self.composeMessage(type: .text, content: self.autoTxtView.text!)
                self.autoTxtView.text = ""
            }
        }
    }
    
    //MARK: NotificationCenter handlers
    func showKeyboard(notification: Notification) {
        if let frame = notification.userInfo![UIKeyboardFrameEndUserInfoKey] as? NSValue {
            let height = frame.cgRectValue.height
//            tableTopConstraint.constant = 57
            bottomConstraint.constant = height
            if self.items.count > 0 {
                self.tblview.scrollToRow(at: IndexPath.init(row: self.items.count - 1, section: 0), at: .bottom, animated: true)
            }
        }
    }

    @IBAction func backTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func animateExtraButtons(toHide: Bool)  {
        switch toHide {
        case true:
            self.bottomConstraint.constant = 8
            UIView.animate(withDuration: 0.3) {
//                self.inputView.layoutIfNeeded()
            }
        default:
            self.bottomConstraint.constant = 50
            UIView.animate(withDuration: 0.3) {
//                self.inputView.layoutIfNeeded()
            }
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let locationCtrl = segue.destination as? LocationViewController {
            locationCtrl.delegate = self
            if (sender != nil) {
                let location = sender as! CLLocationCoordinate2D
                locationCtrl.sendLocation = location
            }
            else {
                locationCtrl.sendLocation = nil
            }            
        }
    }
}

extension MessagesViewController : LocationViewControllerDelegate {
    
    func sendLocation(location: CLLocationCoordinate2D) {
        let coordinate = String(location.latitude) + ":" + String(location.longitude)
        let message = Message.init(type: .location, content: coordinate, owner: .sender, timestamp: Date().iso8601, isRead: false)
        
        Message.send(message: message, toID: partner!.uid, productID: product!.uid, completion: {(_) in
        })
    }
}

extension MessagesViewController : UITableViewDataSource, UITableViewDelegate{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell:MessageCell!
        
        switch self.items[indexPath.row].owner {
        case .receiver:
            cell = tableView.dequeueReusableCell(withIdentifier: "Receiver", for: indexPath) as! MessageCell
            cell.profilePic.image = self.currentUser?.avatarImage
            if (self.currentUser?.avatarImage == nil) {
                cell.profilePic.showLoading()
                cell.profilePic?.sd_setImage(with: currentUser?.imgUrl, completed: { (image, error, type, url) in
                    cell.profilePic.hideLoading()
                    if (error != nil || image == nil) {
                        cell.profilePic.image = UIImage(named: "user_default")
                    }
                })
            }

        case .sender:
            cell = tableView.dequeueReusableCell(withIdentifier: "Sender", for: indexPath) as! MessageCell
            cell.profilePic.image = self.partner?.avatarImage
        }
        cell.clearCellData()
        cell.setCellIndex(index: indexPath.row)        
        cell.delegate = self
        cell.lblTime.text = self.items[indexPath.row].timeString as! String

        switch self.items[indexPath.row].type {
        case .text:
            cell.pinImgView.isHidden = true
            
            if items[indexPath.row].owner == .sender {
                cell.sentLocationImg.isHidden = true
                cell.offerView.isHidden = true
                cell.btnCheckOut.isHidden = true
            }
            else {
                cell.recvLocationImg.isHidden = true
                cell.offerSentView.isHidden = true
            }
            
            cell.lblView.isHidden = false
            cell.lblMessage.isHidden = false

            cell.lblTime.isHidden = false
            cell.lblMessage.text = self.items[indexPath.row].content as! String
        case .offer:
            cell.pinImgView.isHidden = true
            let price = items[indexPath.row].content as! String

            if self.items[indexPath.row].owner == .sender {
                cell.lblView.isHidden = true
                cell.lblOfferTime.text = cell.lblTime.text
                cell.lblTime.isHidden = true
                cell.offerView.isHidden = false
                cell.offerView.layer.borderWidth = 1
                cell.offerView.layer.borderColor = themeOrangeColor.cgColor
                cell.btnCheckOut.isHidden = true

                
                if items[indexPath.row].offerStatus == "Sent" {
                    cell.lblAcceptStatus.text = "Offer"
                    cell.btnAccept.isHidden = false
                    cell.btnReject.isHidden = false
                    cell.statusTopConstraint.constant = -34.0
                }
                else if items[indexPath.row].offerStatus == "Accept" {
                    cell.lblAcceptStatus.text = "Accepted"
                    cell.btnAccept.isHidden = true
                    cell.btnReject.isHidden = true
                    cell.statusTopConstraint.constant = -6.0
                    if FSUserManager.sharedInstance.user?.uid != product?.sellerId {
                        cell.btnCheckOut.isHidden = false
                    }
                }
                else if items[indexPath.row].offerStatus == "Reject" {
                    cell.lblAcceptStatus.text = "Rejected"
                    cell.btnAccept.isHidden = true
                    cell.btnReject.isHidden = true
                    cell.statusTopConstraint.constant = -6.0
                }

                cell.lblPrice.text = "$" + price
            }
            else {
                cell.lblView.isHidden = true
                cell.lblTime.isHidden = true
                cell.lblMessage.isHidden = true
                cell.offerSentView.isHidden = false
                cell.offerSentView.layer.borderWidth = 1
                cell.offerSentView.layer.borderColor = themeOrangeColor.cgColor
                cell.lblSentPrice.text = "$" + price
                
                if items[indexPath.row].offerStatus == "Sent" {
                    cell.lblStatus.text = "Offer"
                }
                else if items[indexPath.row].offerStatus == "Accept" {
                    cell.lblStatus.text = "Accepted"
                }
                else if items[indexPath.row].offerStatus == "Reject" {
                    cell.lblStatus.text = "Rejected"
                }
            }
        case .photo:
            if let image = self.items[indexPath.row].image {
                cell.lblMessage.isHidden = true
            } else {
                self.items[indexPath.row].downloadImage(indexpathRow: indexPath.row, completion: { (state, index) in
                    if state == true {
                        DispatchQueue.main.async {
                            self.tblview.reloadData()
                        }
                    }
                })
            }
        case .location:
            
            if items[indexPath.row].owner == .sender {
                cell.sentLocationImg.isHidden = false
                cell.offerView.isHidden = true
                cell.lblOfferTime.isHidden = false
                cell.btnCheckOut.isHidden = true
            }
            else {
                cell.offerSentView.isHidden = true
                cell.recvLocationImg.isHidden = false
            }
            cell.lblView.isHidden = true
            cell.lblMessage.isHidden = true
            
            let coordinates = (self.items[indexPath.row].content as! String).components(separatedBy: ":")
            let location = CLLocationCoordinate2D.init(latitude: CLLocationDegrees(coordinates[0])!, longitude: CLLocationDegrees(coordinates[1])!)
            
            let mapSnapshotOptions = MKMapSnapshotOptions()
            
            // Set the region of the map that is rendered.
            let region = MKCoordinateRegionMakeWithDistance(location, 500, 500)
            mapSnapshotOptions.region = region
            
            // Set the scale of the image. We'll just use the scale of the current device, which is 2x scale on Retina screens.
            mapSnapshotOptions.scale = UIScreen.main.scale
            
            // Set the size of the image output.
            mapSnapshotOptions.size = CGSize(width:150, height:150)
            
            // Show buildings and Points of Interest on the snapshot
            mapSnapshotOptions.showsBuildings = true
            mapSnapshotOptions.showsPointsOfInterest = true
            
            let snapShotter = MKMapSnapshotter(options: mapSnapshotOptions)
            
            if items[indexPath.row].owner == .sender {
                cell.sentLocationImg.showLoading()
            }
            else {
                cell.recvLocationImg.showLoading()
            }

            snapShotter.start { (snapshot:MKMapSnapshot?, error:Error?) in
                
                
                if (error != nil || snapshot?.image == nil) {
                    return
                }
                let image = snapshot?.image
                if self.items[indexPath.row].owner == .sender {
                    cell.sentLocationImg.hideLoading()
                    cell.sentLocationImg.image = image
                }
                else {
                    cell.recvLocationImg.hideLoading()
                    cell.recvLocationImg.image = image
                }

                cell.pinImgView.isHidden = false
            }
            cell.lblMessage.isHidden = true
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        
        if self.items[indexPath.row].type == .location {
            let coordinates = (self.items[indexPath.row].content as! String).components(separatedBy: ":")
            let location = CLLocationCoordinate2D.init(latitude: CLLocationDegrees(coordinates[0])!, longitude: CLLocationDegrees(coordinates[1])!)

            self.performSegue(withIdentifier: "show.location", sender: location)
        }
        else if items[indexPath.row].type == .offer && items[indexPath.row].offerStatus == "Accept" {
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch self.items[indexPath.row].type {
        case .text:
            return UITableViewAutomaticDimension
        case .offer:
            if self.items[indexPath.row].owner == .sender{
                return 160
            }
            else {
                return 80
            }
        case .photo:
            return UITableViewAutomaticDimension
        case .location:
            return 160
        }
    }
}

extension MessagesViewController:MessageCellDelegate {
    
    func offerTapped(_ index: Int) {
        if FSUserManager.sharedInstance.user?.uid == product?.sellerId {
            return
        }
        
        if items[index].type == .offer && items[index].offerStatus == "Accept" {
        }
    }

    func acceptOffer(_ index: Int) {
        let price = items[index].content as! String
        let offerMsg = items[index]
        offerMsg.type = .offer
        offerMsg.offerStatus = "Accept"
        
        Message.updateMessage(readMsg: offerMsg)
        
        let message = Message.init(type: .offer, content: price, owner: .sender, timestamp: Date().iso8601, isRead: false)
        message.offerStatus = "Accept"
        Message.send(message: message, toID: partner!.uid, productID: product!.uid, completion: {(_) in
        })
    }
    
    func rejectOffer(_ index: Int) {
        let price = items[index].content as! String
        let offerMsg = items[index] as! Message
        offerMsg.type = .offer
        offerMsg.offerStatus = "Reject"
        
        Message.updateMessage(readMsg: offerMsg)
        
        let message = Message.init(type: .offer, content: price, owner: .sender, timestamp: Date().iso8601, isRead: false)
        message.offerStatus = "Reject"
        Message.send(message: message, toID: partner!.uid, productID: product!.uid, completion: {(_) in
        })
    }
    
    func locationTapped(_ index: Int) {
        if self.items[index].type == .location {
            let coordinates = (self.items[index].content as! String).components(separatedBy: ":")
            let location = CLLocationCoordinate2D.init(latitude: CLLocationDegrees(coordinates[0])!, longitude: CLLocationDegrees(coordinates[1])!)
            
            self.performSegue(withIdentifier: "show.location", sender: location)
        }
    }
}


