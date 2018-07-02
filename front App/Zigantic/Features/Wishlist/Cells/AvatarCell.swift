//
//  PeopleCell.swift
//  Bityo
//
//  Created by iOS Developer on 1/25/18.
//  Copyright © 2018 Chirag Ganatra. All rights reserved.
//

import UIKit

class AvatarCell: UICollectionViewCell {
    
    @IBOutlet weak var avatarImgView : FSImageView!
    var user:FSUser?
    
    override var isSelected: Bool {
        willSet {
            onSelected(newValue)
        }
    }
    
    func onSelected(_ newValue: Bool) {
        if (newValue == true) {
            avatarImgView.layer.borderColor = themeOrangeColor.cgColor
            avatarImgView.layer.borderWidth = 2.0
        }
        else {
            avatarImgView.layer.borderColor = themeOrangeColor.cgColor
            avatarImgView.layer.borderWidth = 0.0
        }
    }
    
    func setupCell(_ userId:String?) {
        FSUserManager.sharedInstance.getByIdNoAvatar(uid: userId!,
                                                     completion: { (output:FSUser) in
                                                        self.user = output
                                                        self.showUserInfo()
        },
                                                     failure: {(errorComment: String) -> Void in
                                                        
        })
    }
    
    func showUserInfo() {
        
        self.avatarImgView.showLoading()
        self.avatarImgView?.sd_setImage(with: user?.imgUrl, completed: { (image, error, type, url) in
            self.avatarImgView.hideLoading()
            if (image == nil || error != nil) {
                self.avatarImgView.image = UIImage(named: "user_default")
            }
            
            DispatchQueue.main.async {
                self.layoutSubviews()
                self.updateConstraints()
            }
        })
    }
}
