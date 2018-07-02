//
//  PeopleCell.swift
//  Bityo
//
//  Created by iOS Developer on 1/24/18.
//  Copyright © 2018 Chirag Ganatra. All rights reserved.
//

import UIKit

class PeopleCell: UITableViewCell {
    
    @IBOutlet weak var avatarImgView: FSImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    
    var user:FSUser?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
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
        lblName.text = user?.username
        
        let calendar = Calendar.current
        let curDate = Date()
        let year = calendar.component(.year, from: (user?.time)!)
        let month = calendar.component(.month, from: (user?.time)!)
        lblTime.text =  "Member Since " + String(month) + "/" + String(year)
        
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
