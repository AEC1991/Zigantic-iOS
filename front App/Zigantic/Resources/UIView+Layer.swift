//
//  UIView+Layer.swift
//  Faloos
//
//  Created by SQUALL on 2017. 11. 07..
//  Copyright © 2017. ThinkSpan. All rights reserved.
//

import UIKit

extension UIView {
    func makeCircular() {
        layer.cornerRadius = bounds.width / 2
        contentMode = UIViewContentMode.scaleAspectFill
        clipsToBounds = true
    }
}
