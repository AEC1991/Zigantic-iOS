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

class FSProduct : NSObject {
    
    var uid = ""
    var sellerId = ""
    var title = ""
    var appLink = ""
    var lat:Float = 0.0
    var lng:Float = 0.0
    var address = ""
    var category = ""
    var subcategory = ""
    var contentDescription = ""
    var time:Date? = nil
    var logoUrl:URL?
    var videoUrl:URL?
    var imgUrl:String?
    var imgUrls:NSMutableArray?
    var images:NSMutableArray?
    var questions: [String] = []
    var answers: [String] = []
    var wishes: [String] = []
    var offers: [String] = []
    var surveys: [String] = []
    
    override init() {
        super.init()
    }
    
    static var collection:DatabaseReference {
        get {
            return Database.database().reference().child(kProductsKey)
        }
    }
    
    init(dataDictionary:NSDictionary) {
        
        uid = dataDictionary["uid"] as! String
        if let sellerIdString = dataDictionary["sellerId"] as? String {
            sellerId = sellerIdString
        }
        if let titleString = dataDictionary["title"] as? String {
            title = titleString
        }
        if let timeString = dataDictionary["timestamp"] as? String {
            self.time = timeString.dateFromISO8601
        }
        if let linkString = dataDictionary["appLink"] as? String {
            self.appLink = linkString
        }
        
        if (dataDictionary["logoUrl"] != nil) {
            logoUrl = URL(string: dataDictionary["logoUrl"]! as! String)
        }
        if (dataDictionary["videoUrl"] != nil) {
            videoUrl = URL(string: dataDictionary["videoUrl"]! as! String)
        }
        
        if let dictLat = dataDictionary["lat"] as? Float {
            self.lat = dictLat
        }
        
        if let dictLng = dataDictionary["lng"] as? Float {
            self.lng = dictLng
        }
        
        if let dictAddress = dataDictionary["address"] as? String {
            self.address = dictAddress
        }
        category = dataDictionary["category"] as! String
        subcategory = dataDictionary["subcategory"] as! String
        contentDescription = dataDictionary["contentDescription"] as! String
        imgUrls = dataDictionary["image"] as! NSMutableArray
        
        if let dictQuestions = dataDictionary["questions"] as? NSDictionary {
            questions = dictQuestions.allKeys as! [String]
            answers = dictQuestions.allValues as! [String]
        }

        if let dictWish = dataDictionary[kWishesKey] as? NSDictionary {
            wishes = dictWish.allKeys as! [String]
        }
        
        if let dictSurvey = dataDictionary[kSurveysKey] as? NSDictionary {
            surveys = dictSurvey.allKeys as! [String]
        }
        
        if let dictOffer = dataDictionary[kOffersKey] as? NSDictionary {
            offers = dictOffer.allKeys as! [String]
        }
    }
}

