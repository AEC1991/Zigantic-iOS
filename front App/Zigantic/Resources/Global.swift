//
//  Global.swift
//  Bityo
//
//  Created by Chirag Ganatra on 29/11/17.
//  Copyright © 2017 Chirag Ganatra. All rights reserved.
//

import Foundation


//MARK: - Color -

let themeOrangeColor = rgbaToUIColor(red: 255/255, green: 203/255, blue: 33/255, alpha: 1)
let selectedOrangeColor = rgbaToUIColor(red: 247/255, green: 181/255, blue: 21/255, alpha: 1)
let themeLightGrayColor = rgbaToUIColor(red: 247/255, green: 247/255, blue: 247/255, alpha: 1)

let catRedColor = rgbaToUIColor(red: 247/255, green: 64/255, blue: 21/255, alpha: 1)
let catPinkColor = rgbaToUIColor(red: 254/255, green: 101/255, blue: 194/255, alpha: 1)
let catGreenColor = rgbaToUIColor(red: 96/255, green: 206/255, blue: 23/255, alpha: 1)
let catBlueColor = rgbaToUIColor(red: 21/255, green: 143/255, blue: 247/255, alpha: 1)
let catOtherColor = rgbaToUIColor(red: 78/255, green: 102/255, blue: 249/255, alpha: 1)

let themeBoderColor = UIColor(red: 235.0/255.0, green: 240.0/255.0, blue: 235.0/255.0, alpha: 0.5)
let placeHolderColor = UIColor(red: 104.0/255.0, green: 105.0/255.0, blue: 110.0/255.0, alpha: 1.0)

let appName = "Zigantic"

//MARK: - Social IDs and Secrets -

let facebookAppId = "2021647104747581"
let facebookSecret = "f5b89600ec9b30d16c4f2c2f896b9326"
var categoryList = ["Action", "Adventure", "Card", "RPG", "Sports", "Strategy"]
var settingList = ["Redeem Currency", "About Us", "Terms and Conditions", "Privacy Policy", "Rate Our App", "Contact Us", "Logout"]
var teamList = ["Vignav Ramesh, Cofounder", "Rishab Mohan, Cofounder", "  Tej Singh, Cofounder"]
var socialList = ["Facebook", "Twitter", "LinkedIn", "Instagram", "Gmail"]
var socialLink = ["https://www.facebook.com/Zigantic1/", "https://twitter.com/ziganticcompany", "https://www.linkedin.com/company/zigantic", "https://www.instagram.com/zigantic_company/", "zigantic.company@gmail.com"]


//var subcategoryList = ["Cars & Trucks", "Motorcycle", "Car Parts", "Furniture", "Health & Beauty", "Collectibles", "Appliances", "Pet Supplies",
//                       "Cell Phones", "Accessories", "TV", "Computer/Tablets", "Men's", "Women's", "Jewelry"]
var reportList = ["Prohibitied on Offerup", "Offensive or Inappropriate", "Duplicate Post", "Wrong Category", "Looks like a Scam", "I think it's stolen",
                  "Other"
]

class CustomSlide: UISlider {
    
    @IBInspectable var trackHeight: CGFloat = 2
    
    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(origin: bounds.origin, size: CGSize(width : bounds.width, height : trackHeight))
    }
}
extension String {
    
    func trim() -> String {
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)        
    }
    
    var first: String {
        return String(characters.prefix(1))
    }
    var last: String {
        return String(characters.suffix(1))
    }
    
    var uppercaseFirst: String {
        return first.uppercased() + String(characters.dropFirst())
    }
    
}
