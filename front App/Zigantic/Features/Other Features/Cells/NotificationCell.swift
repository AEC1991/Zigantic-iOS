//
//  NotificationCell.swift
//  Bityo
//
//  Created by iOS Developer on 2/6/18.
//  Copyright © 2018 Chirag Ganatra. All rights reserved.
//

import UIKit
import FirebaseDatabase

class NotificationCell: UITableViewCell {
    
    @IBOutlet weak var avatarImgView: FSImageView!
    @IBOutlet weak var mailLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func clearCellData()  {
        
    }
    
    func setupCell(_ ref:DataSnapshot?) {
        
        let idData = (ref!.key).components(separatedBy: ":")
        let productId = idData[0]
        let partnerId = idData[1]
        let valueDic = ref!.value as! NSDictionary
        let conversationId = valueDic["location"] as! String
        
        showPartnerInfo(partnerId, conversationId)
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
    
    func showLastMessage(_ partner:FSUser, _ conversationId:String) {
        
        Message.downloadLastMessage(forLocation:conversationId,
            completion: { (lastMessage:Message) in
                
                switch lastMessage.type {
                case .text, .location, .photo:
                    let atSt1 = NSMutableAttributedString(string: partner.username, attributes: [NSAttributedStringKey.font: UIFont (name: "OpenSans-Bold", size: 13)!])
                    
                    let atSt2 = NSAttributedString(string: " has sent you a message!", attributes: [NSAttributedStringKey.font: UIFont (name: "OpenSans", size: 13)!])
                    atSt1.append(atSt2)
                    self.mailLabel.attributedText = atSt1
                    
                case .offer:
                    let atSt1 = NSMutableAttributedString(string: partner.username, attributes: [NSAttributedStringKey.font: UIFont (name: "OpenSans-Bold", size: 13)!])
                    
                    let atSt2 = NSAttributedString(string: " has offered you", attributes: [NSAttributedStringKey.font: UIFont (name: "OpenSans", size: 13)!])
                    atSt1.append(atSt2)
                    self.mailLabel.attributedText = atSt1
                }
                
                if lastMessage.timestamp != nil && lastMessage.timestamp != "" {
                    let time = lastMessage.timestamp.dateFromISO8601 as! Date
                    self.dateLabel.text = Utilities.convertDateToAbbrevigation(date: time)
                }
                
                if lastMessage.owner == .sender && lastMessage.isRead == false {
                }
        },
            failure: {(errorComment: String) -> Void in
        })
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
