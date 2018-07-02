//
//  catCell.swift
//  Bityo
//
//  Created by iOS Developer on 1/24/18.
//  Copyright © 2018 Chirag Ganatra. All rights reserved.
//

import Foundation

protocol catCellDelegate {
    func selectCat(index:Int)
    func deselectCat()
}


class catCell : UICollectionViewCell
{
    @IBOutlet weak var lblCat : UILabel!
    
    var catImgName: String = ""
    var selectedStatus = false
    var delegate: catCellDelegate?
    var cellIndex: Int?
    
    override var isSelected: Bool {
        willSet {
            onSelected(newValue)
        }
    }
    
    func onSelected(_ newValue: Bool) {
        if (selectedStatus == false && newValue == true) {
            selectedStatus = true
            
            lblCat.textColor = themeOrangeColor
            delegate?.selectCat(index: self.cellIndex!)
        }
        else if (selectedStatus == true && newValue == true) {
            selectedStatus = false
            lblCat.textColor = themeOrangeColor
            self.delegate?.deselectCat()
        }
        else {
            print("other one selected")
            selectedStatus = false
            lblCat.textColor = UIColor.white
        }
    }
    
    override func awakeFromNib() {
    }
}
