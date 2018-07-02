//
//  FormTxt.swift
//  Pufd
//
//  Created by Chirag Ganatra on 04/10/17.
//  Copyright © 2017 Chirag Ganatra. All rights reserved.
//

import UIKit

class FormTxt: UITextField {
    override func awakeFromNib() {
        self.layoutIfNeeded()
        self.attributedPlaceholder = NSAttributedString(string: self.placeholder!, attributes: [NSAttributedStringKey.foregroundColor : UIColor(red: 1, green: 1, blue: 1, alpha: 0.75)])
        self.backgroundColor = .clear

    }


}
