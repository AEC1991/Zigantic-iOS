//
//  FSImageView.swift
//  Faloos
//
//  Created by SQUALL on 2017. 11. 15..
//  Copyright © 2017. ThinkSpan. All rights reserved.
//

import Foundation
import UIKit

class FSImageView: UIImageView {
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = FSColor.grayColor
        self.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        let xCenterConstraint = NSLayoutConstraint(item: self, attribute: .centerX, relatedBy: .equal, toItem: activityIndicator, attribute: .centerX, multiplier: 1, constant: 0)
        let yCenterConstraint = NSLayoutConstraint(item: self, attribute: .centerY, relatedBy: .equal, toItem: activityIndicator, attribute: .centerY, multiplier: 1, constant: 0)
        self.addConstraints([xCenterConstraint, yCenterConstraint])
        return activityIndicator
    }()
    
    override func showLoading() {
        activityIndicator.startAnimating()
    }
    
    override func hideLoading() {
        activityIndicator.stopAnimating()
    }    
}
