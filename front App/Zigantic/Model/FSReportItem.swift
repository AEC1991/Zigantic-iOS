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

class FSReportItem : NSObject {
    
    var uid = ""
    var reporterId = ""
    var productId = ""
    var comment = ""
    var category = ""
    var time:Date? = nil
    
    override init() {
        super.init()
    }
    
    static var collection:DatabaseReference {
        get {
            return Database.database().reference().child(kReportItemsKey)
        }
    }
    
    init(dataDictionary:NSDictionary) {
        
        uid = dataDictionary["uid"] as! String
        productId = dataDictionary["productId"] as! String
        reporterId = dataDictionary["reporterId"] as! String
        
        if let catString = dataDictionary["category"] as? String {
            category = catString
        }
        
        if let commentString = dataDictionary["comment"] as? String {
            comment = commentString
        }
        if let timeString = dataDictionary["timestamp"] as? String {
            self.time = timeString.dateFromISO8601
        }
    }
}



