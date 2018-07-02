//
//  UserCell.swift
//  Zigantic
//
//  Created by iOS Developer on 4/3/18.
//  Copyright © 2018 Chirag Ganatra. All rights reserved.
//

import UIKit
import Firebase

class UserCell: UICollectionViewCell {
    
    @IBOutlet weak var avatarImgView: FSImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblTime: UILabel!    
    @IBOutlet weak var lblType: UILabel!
    
    func setupCell(ref:DataSnapshot?) {
        var data = ref?.value as? NSDictionary
        let outUser = FSUser(dataDictionary: data!)
        self.showUserInfo(outUser)
    }
    
    private func showUserInfo(_ outUser:FSUser) {
        self.lblTitle.text = outUser.username
        self.lblTime.text = "Sign up " + Utilities.convertDateToAbbrevigation(date: outUser.time!)
        if outUser.type == "admin" {
            self.lblType.text = "Administrator"
        }
        else if outUser.type == "develop" {
            self.lblType.text = "Developer"
        }
        else {
            self.lblType.text = "Survey User"
        }
        
        self.avatarImgView.showLoading()
        self.avatarImgView?.sd_setImage(with: outUser.imgUrl, completed: { (image, error, type, url) in
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
