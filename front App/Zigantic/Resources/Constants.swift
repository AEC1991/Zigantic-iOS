//
//  Constants.swift
//  Faloos
//
//  Created by Andon

import UIKit

//Rest API
let BASE_URL = "https://blockchain.info"
let CRYPTO_URL = "https://api.cryptonator.com/api"
let APP_URL = "https://itunes.apple.com/app/1276608207"
let TERMS_URL = "https://sprawl-bc781.firebaseapp.com/terms-of-use.html"
let PRIVACY_URL = "https://sprawl-bc781.firebaseapp.com/privacy-policy.html"

let ADMIN_EMAIL = "zigantic.company@gmail.com"
let ADMIN_EMAILS = ["zigantic.a@gmail.com", "zigantic.company@gmail.com", "as259532@gmail.com"]

let MSG_TIMESTAMP_FMT = "dd MMM yyyy @ HH:mm"
let APPLINK_URL = "https://fb.me/369443586826097"
let PREVIEWIMAGE_URL = "https://firebasestorage.googleapis.com/v0/b/faloos-dev.appspot.com/o/appicon%2FiTunesArtwork%402x.png?alt=media&token=5dbf153e-439e-4109-8c46-45025f01a528"

let HEADER_HEIGHT = 25
let CELL_HEIGHT = 78
let FOOTER_HEIGHT = 10
let MAX_AVATAR_SIZE = 252

let kServerFee:Double = 4.0

let kMaxPhoneLength = 11
let kMaxBTCLength = 6 //the length of btc price string
let kJPEGImageQuality:CGFloat = 0.5 // between 0..1
let kMaxConcurrentImageDownloads = 10 // the count of images donloading at the same time
let kUsersKey = "users"
let kProductsKey = "products"
let kSurveysKey = "surveys"
let kCategoriesKey = "categories"
let kPurchasesKey = "purchase"
let kWishesKey = "wishes"
let kVerifyKey = "verified"
let kOffersKey = "offers"
let kMessagesKey = "conversations"
let kReviewsKey = "reviews"
let kReportItemsKey = "reportItems"

let kDateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"

enum STATUS_CODE {
    case success
    case connection_failed
    case invalid_request
    case blank_value
    case update_failed
}

enum MessageType {
    case photo
    case text
    case offer
    case location
}

enum MessageOwner {
    case sender
    case receiver
}

enum FRIEND_STATUS: Int {
    case none = 0
    case selected = 1
    case sent = 2
    case incoming = 3
    case accepted = 4
    case rejected = 5
    case fsFriend = 6
    case fbFriend = 7
    case fsUser = 8
    case transaction = 9
}

struct FSColor {
    static let redColor = UIColor.init(red: 255/256.0, green: 2/256.0, blue: 0, alpha: 1)
    static let pinkColor = UIColor(red: 240.0/255.0, green: 50.0/255.0, blue: 113.0/255.0, alpha: 1.0)
    static let boderColor = UIColor(red: 235.0/255.0, green: 240.0/255.0, blue: 235.0/255.0, alpha: 0.5)
    static let buttonColor = UIColor(red: 1.0/255.0, green: 205.0/255.0, blue: 206.0/255.0, alpha: 1.0)
    static let placeHolderColor = UIColor(red: 11.0/255.0, green: 11.0/255.0, blue: 11.0/255.0, alpha: 0.47)

    static let greenColor = UIColor(red: 76.0/255.0, green: 175.0/255.0, blue: 80.0/255.0, alpha: 1.0)
    static let grayColor = UIColor(red: 158.0/255.0, green: 158.0/255.0, blue: 158.0/255.0, alpha: 1.0)
    static let textColorBlackAlpha = UIColor(red: 0, green: 0, blue: 0, alpha: 0.54)
    static let creditPriceStart = 3.99
    
    static let grayBackgroundColor = UIColor(red: 238.0/255.0, green: 238.0/255.0, blue: 238.0/255.0, alpha: 1.0)
}

struct FSMessage {
    
    static let USERNAME_EXIST = "That username has already taken by another user. Please use another username."
    static let NO_USER = "No user exists in Faloos."
    static let REQUEST_OFFER_PRICE = "Please input offer price."
    static let USER_LOGOUT = "User logged out"
    
    static let SHARE_FACEBOOK_SUCCESS = "Successfully Shared on Facebook."
    static let SHARE_LINKEDIN_SUCCESS = "Successfully Shared on LinkedIN."
    static let SHARE_TWITTER_SUCCESS = "Successfully Shared on Twitter."

    static let ADD_PRODUCT_IMAGE = "Please add your product images. It’ll be shown to consumers."
    static let REQUEST_PRODUCT_IMAGE = "Please add your product images."
    static let PRODUCT_PUBLISH_PROCESS = "We are publishing your product..."
    static let PRODUCT_DELETE = "Are you sure you want to delete this product?"
    static let PRODUCT_NOT_NEGOTIABLE = "This product is not negotiable."
    
    static let OFFER_SENT_CONFIRM = "Offer is sent. Please check your message."
    
    static let IMAGE_DELETE = "Delete the image"
    static let NETWORK_ERROR = "Please check your network connection."

    static let SEND_REQUEST = "Are you sure you want to send this Request?"
    static let SEND_PAYMENT = "Are you sure you want to send this Payment?"
    static let INPUT_PHONE = "Please enter phone number."
    static let VERIFY_PHONE = "Would you like to verify your phone number?"
    
    static let REQUEST_GAME_IMAGE = "Please place the game image."
    
    static let REQUEST_GAME_LINK = "Please add game link."
    static let REQUEST_GAME_DESCRIPTION = "Please write the description about the game."
    
    static let CONFIRM_PAYMENT = "Are you sure you want to accept this Payment?"
    static let CONFIRM_REJECT = "Are you sure you want to reject this Payment?"
    
    static let CONFIRM_RESTART = "This app would need to restart in order for this change to occur."
    static let CONFIRM_CANCEL = "Are you sure you want to cancel?"

    static let INPUT_FULLNAME = "Please enter full name."
    static let INPUT_CARDNUM = "Please enter card number."
    static let INPUT_EXPMONTH = "Please enter expired month."
    static let INPUT_EXPYEAR = "Please enter expired year."

    static let INPUT_USERNAME = "Please enter user name."
    static let INPUT_EMAIL = "Email address is not valid."
    static let EMAIL_INVALID = "Email address is not valid."
    static let VERIFY_EMAIL_SENT = "Verification Email was sent!"
    static let PASSWORD_RESET_EMAIL = "Password Reset Email was sent!"

    static let CARD_INVALID = "Please enter the correct card information"

    static let FRIEND_ACCEPT = "Are you sure you want to accept this user as a friend?"
    static let FRIEND_REJECT = "Are you sure you want to reject this user as a friend?"
    static let FRIEND_CANCEL = "Are you sure you want to cancel this request?"
    static let FRIEND_ADD = "Are you sure you want to add this user as a friend?"
    static let FRIEND_FACEBOOK = " of your Facebook friends are already using Faloos!"
    static let FACEBOOK_INVITE = "Faloos is better with friends! Invite your Facebook friends here."

    static let UPLOADING_AVATAR = "Please wait. On changing profile image now."
    static let CAMERA_NOT_WORK = "Camera is not available."
    static let PHOTOLIBRARY_NOT_WORK = "Photo library is not available."
    
    static let forgotPasswordSuccessTitle = "Password sent"
    static let forgotPasswordSuccessMessage = "A new password is emailed to you. Please check spam/junk folder if you can’t see email in your inbox."
    static let forgotPasswordSuccessButtonTitle = "GOT IT"
}
