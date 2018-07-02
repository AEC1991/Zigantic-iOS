//
//  ThreadCell.swift
//  Bityo
//
//  Created by iOS Developer on 2/1/18.
//  Copyright © 2018 Chirag Ganatra. All rights reserved.
//

import UIKit
import SwipeCellKit
import FirebaseDatabase

class ThreadCell: SwipeTableViewCell {
    
    @IBOutlet weak var avatarImgView: FSImageView!
    @IBOutlet weak var lblFullname: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var productImgView: FSImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func clearCellData()  {
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupCell(_ ref:DataSnapshot?) {
        
        let idData = (ref!.key).components(separatedBy: ":")
        let productId = idData[0]
        let partnerId = idData[1]
        let valueDic = ref!.value as! NSDictionary
        let conversationId = valueDic["location"] as! String
        
        showPartnerInfo(partnerId, conversationId)
        showProductInfo(productId)
    }
    
    func showPartnerInfo(_ partnerId:String, _ conversationId:String) {
        FSUserManager.sharedInstance.getByIdNoAvatarSingleEvent(uid:partnerId,
            completion: { (partner:FSUser) in
                self.avatarImgView.showLoading()
                self.avatarImgView?.sd_setImage(with: partner.imgUrl, completed: { (image, error, type, url) in
                    self.avatarImgView.hideLoading()
                    if (error != nil || image == nil) {
                        self.avatarImgView.image = UIImage(named: "user_default")
                    }
                })
                self.showLastMessage(partner, conversationId)
        },
            failure: {(errorComment: String) -> Void in
                    
        })
    }
    
    func showProductInfo(_ productId:String) {
        FSProductManager.sharedInstance.getById(uid: productId,
            completion: { (output:FSProduct) in
                let productURL = output.imgUrls![0] as? String
                
                self.productImgView.showLoading()
                self.productImgView?.sd_setImage(with: URL(string: productURL!), completed: { (image, error, type, url) in
                    self.productImgView.hideLoading()
                    if (error != nil || image == nil) {
                        self.productImgView.image = UIImage(named: "product_default")
                    }
                })
        },
            failure: {(errorComment: String) -> Void in
        })
    }
    
    func showLastMessage(_ partner:FSUser, _ conversationId:String) {
        
        Message.downloadLastMessage(forLocation:conversationId,
            completion: { (lastMessage:Message) in
                
                switch lastMessage.type {
                case .text:
                    let message = lastMessage.content as! String
                    self.lblFullname.text = partner.username + ": " + message
                case .location:
                    self.lblFullname.text = "Location"
                default:
                    self.lblFullname.text = "Media"
                }
                
                if lastMessage.timestamp != nil && lastMessage.timestamp != "" {
                    let time = lastMessage.timestamp.dateFromISO8601 as! Date
                    self.lblTime.text = Utilities.convertDateToAbbrevigation(date: time)
                }
                
                if lastMessage.owner == .sender && lastMessage.isRead == false {
                }
        },
            failure: {(errorComment: String) -> Void in
                
        })
    }
    
}
