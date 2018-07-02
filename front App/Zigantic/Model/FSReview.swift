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

class FSReview : NSObject {
    
    var uid = ""
    var reviewerId = ""
    var sellerId = ""
    var comment = ""
    var rating:Int = 0
    var time:Date? = nil
    
    override init() {
        super.init()
    }
    
    static var collection:DatabaseReference {
        get {
            return Database.database().reference().child(kReviewsKey)
        }
    }
    
    init(dataDictionary:NSDictionary) {
        
        uid = dataDictionary["uid"] as! String
        sellerId = dataDictionary["sellerId"] as! String
        reviewerId = dataDictionary["reviewerId"] as! String
        
        if let commentString = dataDictionary["comment"] as? String {
            comment = commentString
        }
        if let timeString = dataDictionary["timestamp"] as? String {
            self.time = timeString.dateFromISO8601
        }
        rating = dataDictionary["rating"] as! Int
    }
}


