//
//  SubCatCell.swift
//  Bityo
//
//  Created by iOS Developer on 1/24/18.
//  Copyright © 2018 Chirag Ganatra. All rights reserved.
//

import Foundation
import UIKit

protocol SubCatCellDelegate {
    // required
    func catClose()
}


class SubCatCell : UICollectionViewCell
{
    
    var delegate:SubCatCellDelegate?
    
    @IBOutlet weak var lblSubCat: UILabel!
    
    override var isSelected: Bool {
        willSet {
            onSelectTapped(newValue)
        }
    }

    func onSelectTapped(_ newValue: Bool) {
        if (newValue == true) {
            lblSubCat.textColor = UIColor.white
        }
        else {
            lblSubCat.textColor = themeOrangeColor
        }
    }

    override func awakeFromNib() {
    }
    
    func tapClose(sender: UITapGestureRecognizer){
        delegate?.catClose()
    }

    @IBAction func onSubCat(_ sender: Any) {
//        btnSubCat.isSelected = !btnSubCat.isSelected
    }
    
    @IBAction func onCatClose(_ sender: Any) {
        delegate?.catClose()
    }
}
