//
//  FSProduct.swift
//  Bityo
//
//  Created by iOS Developer on 1/5/18.
//  Copyright © 2018 Chirag Ganatra. All rights reserved.
//

import UIKit
import Foundation
import FirebaseDatabase

class FSCategory : NSObject {
    
    override init() {
        super.init()
    }
    
    static var collection:DatabaseReference {
        get {
            return Database.database().reference().child(kCategoriesKey)
        }
    }
}



