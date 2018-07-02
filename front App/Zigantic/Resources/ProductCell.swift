//
//  ProductCell.swift
//  Bityo
//
//  Created by iOS Developer on 1/10/18.
//  Copyright © 2018 Chirag Ganatra. All rights reserved.
//

import Foundation
import UIKit

class ProductCell: UITableViewCell {
    
    @IBOutlet weak var productImgView: SpringImageView!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var wishBtn: UIButton!
    
    var product:FSProduct?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func setupCell(_ productId:String?) {
        FSProductManager.sharedInstance.getById(uid: productId!,
            completion: { (output:FSProduct) in
                self.product = output
                self.showProductInfo()
        },
             failure: {(errorComment: String) -> Void in
                print(errorComment)
        })
    }
    
    func showProductInfo() {
        
        
        lblTitle.text = product?.title
        lblLocation.text = product?.address
        
        self.productImgView.showLoading()
        self.productImgView?.sd_setImage(with: URL(string:product?.imgUrls?[0] as! String), completed: { (image, error, type, url) in
            self.productImgView.hideLoading()
            DispatchQueue.main.async {
                self.layoutSubviews()
                self.updateConstraints()
            }
        })
    }
}

