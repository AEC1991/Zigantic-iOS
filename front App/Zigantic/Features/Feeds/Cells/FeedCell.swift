//
//  FeedCell.swift
//  Bityo
//
//  Created by iOS Developer on 1/24/18.
//  Copyright © 2018 Chirag Ganatra. All rights reserved.
//

import Foundation
import Firebase

protocol feedCellDelegate {
    func onRemoveFeed(index:Int)
}

class FeedCell : UICollectionViewCell{
    
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var btnDelete: UIButton!
    
    @IBOutlet weak var lblCryptoPrice: UILabel!
    @IBOutlet weak var lblPrice : UILabel!
    @IBOutlet weak var logoImgView: UIImageView!
    @IBOutlet weak var surveyImgView: UIImageView!
    @IBOutlet weak var priceWidthConstraint: NSLayoutConstraint!
    
    var cryptoRate:Double = 0.0
    var delegate: feedCellDelegate?
    var cellIndex: Int?
    
    override func awakeFromNib() {
        
    }
    
    @IBAction func onRemoveTap(_ sender: Any) {
        self.delegate?.onRemoveFeed(index: self.cellIndex!)
    }
    
    func showProductInfo(_ outProduct:FSProduct) {
        lblTitle.text = outProduct.title
        if (FSUserManager.sharedInstance.user?.type == "admin") {
            btnDelete.isHidden = false
        }
        else {
            btnDelete.isHidden = true
        }
        
        if (FSProductManager.sharedInstance.checkInMySurveys(outProduct) == true) {
            surveyImgView.isHidden = false
        }
        else {
            surveyImgView.isHidden = true
        }
        
        if outProduct.contentDescription != nil {
            lblDescription.text = outProduct.contentDescription
        }
        
        if (outProduct.logoUrl != nil) {
            self.logoImgView.showLoading()
            self.logoImgView?.sd_setImage(with: outProduct.logoUrl, completed: { (image, error, type, url) in
                self.logoImgView.hideLoading()
                DispatchQueue.main.async {
                    if (image == nil) {
                        self.logoImgView.image = UIImage(named: "product_default")
                    }

                    self.layoutSubviews()
                    self.updateConstraints()
                }
            })
        }
        else {
            self.logoImgView.image = UIImage(named: "product_default")
        }
    }
    
    func getById(_ productId:String) {
        FSProductManager.sharedInstance.getById(uid: productId,
                 completion: { (output:FSProduct) in
                    self.showProductInfo(output)
        },
                 failure: {(errorComment: String) -> Void in
        })
    }
    
    func setupCell(ref:DataSnapshot?) {
        var data = ref?.value as? NSDictionary
        let outProduct = FSProduct(dataDictionary: data!)
        self.showProductInfo(outProduct)
    }
}
