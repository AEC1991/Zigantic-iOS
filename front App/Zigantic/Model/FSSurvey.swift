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

class FSSurvey : NSObject {
    
    var uid = ""
    var userId = ""
    var gameId = ""
    var time:Date? = nil
    var questions: [String] = []
    var answers: [String] = []
    var questionStruct:Dictionary<String, String>?
    
    override init() {
        super.init()
    }
    
    static var collection:DatabaseReference {
        get {
            return Database.database().reference().child("surveys")
        }
    }
    
    init(dataDictionary:NSDictionary) {
        
        uid = dataDictionary["uid"] as! String
        if let sellerIdString = dataDictionary["userId"] as? String {
            userId = sellerIdString
        }
        if let gameIdString = dataDictionary["gameId"] as? String {
            gameId = gameIdString
        }
        
        if let timeString = dataDictionary["timestamp"] as? String {
            self.time = timeString.dateFromISO8601
        }
        
        if let dictQuestions = dataDictionary["questions"] as? NSDictionary {
            questions = dictQuestions.allKeys as! [String]
            answers = dictQuestions.allValues as! [String]
        }
    }
}


