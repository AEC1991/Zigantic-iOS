//
//  SurveyCell.swift
//  Zigantic
//
//  Created by iOS Developer on 4/3/18.
//  Copyright © 2018 Chirag Ganatra. All rights reserved.
//

import UIKit

class SurveyCell: UICollectionViewCell {
    
//    @IBOutlet weak var avatarImgView: FSImageView!
    @IBOutlet weak var avatarImgView: FSImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    
    func setupCell(surveyId:String){
        avatarImgView.showLoading()
        FSSurveyManager.sharedInstance.getById(uid: surveyId, completion: { (outSurvey) in
            self.lblTime.text = Utilities.convertDateToAbbrevigation(date: outSurvey.time!)
            FSUserManager.sharedInstance.getById(uid: outSurvey.userId, completion: { (cellUser) in
                self.showUserInfo(cellUser)
            }, failure: { (error) in
                self.avatarImgView.hideLoading()
            })

        }) { (error) in
            self.avatarImgView.hideLoading()
        }
    }
    
    func showUserInfo(_ user:FSUser) {
        self.lblTitle.text = user.username + " submitted a survey"
        self.avatarImgView?.sd_setImage(with: user.imgUrl, completed: { (image, error, type, url) in
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
