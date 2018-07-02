//
//  SettingCell.swift
//  Zigantic
//
//  Created by iOS Developer on 3/20/18.
//  Copyright © 2018 Chirag Ganatra. All rights reserved.
//

import UIKit

class SettingCell: UICollectionViewCell {
    
    @IBOutlet weak var outView: UIView!
    @IBOutlet weak var iconImgView: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    
    override func awakeFromNib() {
        self.outView.layer.borderWidth = 1
        self.outView.layer.borderColor = UIColor(red:144/255, green:144/255, blue:144/255, alpha: 0.3).cgColor
    }
}
