//
//  FSUser.swift
//  Faloos
//
//  Created by Andon

import UIKit
import Foundation
import FirebaseDatabase

class FSUser : NSObject {
    
    var uid = ""
    var avatar = ""
    var fbname = ""
    var username = ""
    var paypalname = ""
    var email = ""
    var type = ""
    var password = ""
    var phone = ""
    var school = ""
    var rating = 0
    var grade = 1
    var unreadNum = 0
    var lat:Float = 0.0
    var lng:Float = 0.0
    var address = ""
    var time:Date? = nil
    var imgUrl:URL?
    var avatarImage:UIImage?
    var friends: [String] = []
    var fbfriends: [String] = []// fb friends names
    var usersFollowingMe: [String] = []
    var usersImFollowing: [String] = []
    var wishes: [String] = []
    var surveys: [String] = []
    var products: [String] = []
    var verifiedLinks: [String] = []

    override init() {
        super.init()
    }
    
    static var collection:DatabaseReference {
        get {
            return Database.database().reference().child(kUsersKey)
        }
    }
    
    init(dataDictionary:NSDictionary) {
        
        if let uidDic = dataDictionary["uid"] as? String {
            self.uid = uidDic
        }
        
        if let emailDic = dataDictionary["email"] as? String {
            self.email = emailDic
        }
        
        if let usernameDic = dataDictionary["username"] as? String {
            self.username = usernameDic
        }
        
        if let paypalString = dataDictionary["paypal"] as? String {
            self.paypalname = paypalString
        }
        
        if let type = dataDictionary["type"] as? String {
            self.type = type
        }
        
        if let schoolName = dataDictionary["school"] as? String {
            self.school = schoolName
        }

        if let timeString = dataDictionary["timestamp"] as? String {
            self.time = timeString.dateFromISO8601
        }
        
        if let dictRating = dataDictionary["rating"] as? Int {
            self.rating = dictRating
        }
        
        if let dictUnreadNum = dataDictionary["unreadNum"] as? Int {
            self.unreadNum = dictUnreadNum
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

        if (dataDictionary["imgUrl"] != nil) {
            imgUrl = URL(string: dataDictionary["imgUrl"]! as! String)
        }
        if (dataDictionary["friends"] != nil)
        {
            let dictFriends = dataDictionary["friends"] as! NSDictionary
            friends = dictFriends.map{"\($1)"}
        }
        
        if let dictUsersFollowingMe = dataDictionary["usersFollowingMe"] as? NSDictionary {
            usersFollowingMe = dictUsersFollowingMe.map{"\($1)"}
        }
        
        if let dictUsersImFollowing = dataDictionary["usersImFollowing"] as? NSDictionary {
            usersImFollowing = dictUsersImFollowing.map{"\($1)"}
        }
        
        if let dictWish = dataDictionary[kWishesKey] as? NSDictionary {
            wishes = dictWish.allKeys as! [String]
        }
        
        if let dictSurveys = dataDictionary["surveys"] as? NSDictionary {
            surveys = dictSurveys.allKeys as! [String]
        }
        
        if let dictProduct = dataDictionary[kProductsKey] as? NSDictionary {
            products = dictProduct.allKeys as! [String]
        }
        
        if let dictVerify = dataDictionary[kVerifyKey] as? NSDictionary {
            verifiedLinks = dictVerify.allKeys as! [String]
        }
        avatarImage = nil
    }
}
