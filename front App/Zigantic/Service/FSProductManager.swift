//
//  FSProductManager.swift
//  Bityo
//
//  Created by iOS Developer on 1/5/18.
//  Copyright © 2018 Chirag Ganatra. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FBSDKCoreKit
import FBSDKLoginKit
import FBSDKShareKit
import TwitterKit

class FSProductManager: NSObject {
    
    let ref = Database.database().reference()
    static let sharedInstance = FSProductManager()
    
    var product: FSProduct?
    var curUploadingImgNo: Int = 0
    var isCollecting:Bool = false
    
    private override init() {
        super.init()
    }
    
    func startUploadImg(withCompletion completion: @escaping (_ errorComment: String?) -> Void) {
        curUploadingImgNo = 0
        product?.imgUrls = NSMutableArray()
        if (product?.uid == nil || product?.uid == "") {
            let key = FSProduct.collection.childByAutoId().key as! String
            product?.uid = key
        }
        
        uploadImages(withCompletion: completion)
    }
    
    func addLogoImage(_ productImg: UIImage, withCompletion completion: @escaping (_ errorComment: String?) -> Void) {
        if (product?.uid == nil || product?.uid == "") {
            let key = FSProduct.collection.childByAutoId().key as! String
            product?.uid = key
        }
        
        let strFileName = "\(product!.uid)" as! String
        Utilities.uploadMedia(image: productImg, ref: "logo/" + strFileName, completion: {(imgUrl) in
            self.product?.logoUrl = imgUrl
            completion(nil)
        },
          failure: {(errorComment: String) -> Void in
            completion(errorComment)
            return
        })
    }
    
    func addProductImage(_ productImg: UIImage, withCompletion completion: @escaping (_ errorComment: String?) -> Void) {
        if (product?.uid == nil || product?.uid == "") {
            let key = FSProduct.collection.childByAutoId().key as! String
            product?.uid = key
        }

        let strFileName = "\(product!.uid)_\(product?.imgUrls?.count)" as! String
        Utilities.uploadMedia(image: productImg, ref: "product/" + strFileName, completion: {(imgUrl) in
            if self.product?.imgUrls == nil {
                self.product?.imgUrls = NSMutableArray()
            }
            self.product?.imgUrls?.add(imgUrl.absoluteString)
            completion(nil)
        },
          failure: {(errorComment: String) -> Void in
            completion(errorComment)
            return
        })
    }
    
    func uploadImages(withCompletion completion: @escaping (_ errorComment: String?) -> Void) {
        let img: UIImage? = product?.images![curUploadingImgNo] as! UIImage
        let strFileName = "\(product!.uid)_\(curUploadingImgNo)" as! String
        
        Utilities.uploadMedia(image: img!, ref: "product/" + strFileName, completion: {(imgUrl) in
            self.product?.imgUrls?.add(imgUrl.absoluteString)
            
            if self.curUploadingImgNo == (self.product?.images?.count)! - 1 {
                self.curUploadingImgNo = 0
                completion(nil)
            }
            else {
                self.curUploadingImgNo += 1
                self.uploadImages(withCompletion: completion)
            }
        },
              failure: {(errorComment: String) -> Void in
                self.curUploadingImgNo = 0
                completion(errorComment)
                return
        })
    }
    
    func getFeeds(completion: (([DataSnapshot]) -> Void)?,
                  failure: ((String) -> Void)?) {
        let f: DatabaseReference? = FSProduct.collection
        let q: DatabaseQuery? = f?.queryOrdered(byChild: "timestamp")
        var posts:[DataSnapshot] = []
        
        isCollecting = true
        q?.observe(.value, with: {(_ snapshot: DataSnapshot) -> Void in
            DispatchQueue.main.async(execute: {
                posts = []
                for item in snapshot.children {
                    posts.insert(item as! DataSnapshot, at: 0)
                }
                self.isCollecting = false
                completion!(posts)
            })
        }) { (error) in
            failure!(error.localizedDescription)
        }
    }
    
    func checkInMyWishes(_ inProduct:FSProduct)->Bool {
        for productId in (FSUserManager.sharedInstance.user?.wishes)!
        {
            let strProductId = productId as? String
            if (inProduct.uid == strProductId)
            {
                return true
            }
        }
        return false
    }
    
    func checkInMySurveys(_ inProduct:FSProduct)->Bool {
        for productId in (FSUserManager.sharedInstance.user?.surveys)!
        {
            let strProductId = productId as? String
            if (inProduct.uid == strProductId)
            {
                return true
            }
        }
        return false
    }
    
    func addQuestion(_ inProduct:FSProduct, _ question:String, _ answer:String) {
        let productRef :DatabaseReference = FSProduct.collection.child(inProduct.uid).child("questions")
        let gameValues:[String:Any] = [question: answer]
        productRef.updateChildValues(gameValues)
    }
    
    func addSurveyList(_ inProduct:FSProduct) {
        if let userid = FSUserManager.sharedInstance.user?.uid {
            //add product to user's wish list
            let userRef :DatabaseReference = FSUser.collection.child(userid).child("surveys")
            let postValues:[String:Any] = [inProduct.uid: Date().iso8601]
            userRef.updateChildValues(postValues)
            
            //add user to product's wished list
            let productRef :DatabaseReference = FSProduct.collection.child(inProduct.uid).child("surveys")
            let productValues:[String:Any] = [userid: Date().iso8601]
            productRef.updateChildValues(productValues)
        }
    }

    func addWishList(_ inProduct:FSProduct) {
        if let userid = FSUserManager.sharedInstance.user?.uid {
            //add product to user's wish list
            let userRef :DatabaseReference = FSUser.collection.child(userid).child(kWishesKey)
            let postValues:[String:Any] = [inProduct.uid: Date().iso8601]
            userRef.updateChildValues(postValues)
            
            //add user to product's wished list
            let productRef :DatabaseReference = FSProduct.collection.child(inProduct.uid).child(kWishesKey)
            let productValues:[String:Any] = [userid: Date().iso8601]
            productRef.updateChildValues(productValues)
        }
    }
    
    func removeWishList(_ inProduct:FSProduct, _ inUserId: String) {
        let userRef :DatabaseReference = FSUser.collection.child(inUserId).child(kWishesKey).child(inProduct.uid)
        userRef.removeValue()
    }
    
    func sendOffer(_ inProduct:DataSnapshot!, _ price:Double) {
        if let userid = FSUserManager.sharedInstance.user?.uid {
            let postsRef :DatabaseReference = FSProduct.collection.child(inProduct.key).child("offers")
            let postValues:[String:Any] = [userid: price]
            postsRef.updateChildValues(postValues)
        }
    }
    
    func getRefById(uid: String, completion: ((DataSnapshot) -> Void)?,
                  failure: ((String) -> Void)?) {
        FSProduct.collection.child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            completion!(snapshot)
        }) { (error) in
            failure!(error.localizedDescription)
        }
    }
    
    open func getById(uid: String, completion: ((FSProduct) -> Void)?,
                              failure: ((String) -> Void)?) {
        FSProduct.collection.child(uid).observe(DataEventType.value, with: { (snapshot) in
            // Get user value
            let data = snapshot.value as? NSDictionary
            if (data == nil) {
                failure!(FSMessage.NETWORK_ERROR)
            }
            else {
                let outProduct = FSProduct(dataDictionary: data!)
                completion!(outProduct)
            }
        }) { (error) in
            failure!(error.localizedDescription)
        }
    }
    
    func removeProductByAdmin(_ inProduct:FSProduct, completion: (() -> Void)?,
                       failure: ((String) -> Void)?) {
        
        //remove it in the user products list
        let userRef :DatabaseReference = FSUser.collection.child(inProduct.sellerId).child(kProductsKey).child(inProduct.uid)
        userRef.removeValue()
        
        //remove it in the products list
        let productRef :DatabaseReference = FSProduct.collection.child(inProduct.uid)
        productRef.removeValue()
        
        //remove surveys related to the project
        if inProduct.surveys != [] {
            for surveyId in inProduct.surveys {
                let surveyRef :DatabaseReference = FSSurvey.collection.child(surveyId)
                surveyRef.removeValue()
            }
        }
        
        completion!()
    }

    func removeProduct(_ inProduct:FSProduct, completion: (() -> Void)?,
                       failure: ((String) -> Void)?) {
        if let userid = FSUserManager.sharedInstance.user?.uid {
            
            //remove the file in the firebase storage
            for i in 0..<(inProduct.imgUrls?.count)! {
                var strFilename = "\(inProduct.imgUrls![i])_\(i)"
                deleteImage(inProduct.imgUrls![i] as! String,
                    completion: { () in
                },
                    failure: {(error) in
                        failure!(error)
                })
            }
            
            //remove it in the user products list
            let userRef :DatabaseReference = FSUser.collection.child(userid).child(kProductsKey).child(inProduct.uid)
            userRef.removeValue()
            
            //remove the product in other user's wish list
            if (inProduct.wishes != nil) {
                for wishUser in inProduct.wishes {
                    removeWishList(inProduct, wishUser)
                }
            }
            
            //remove it in the products list
            let productRef :DatabaseReference = FSProduct.collection.child(inProduct.uid)
            productRef.removeValue()
            completion!()
            
        }
    }
    
    func deleteImage(_ deleteURL: String?, completion: (() -> Void)?,
                       failure: ((String) -> Void)?) {
        let deleteRef = Storage.storage().reference(forURL: deleteURL!)
        
        deleteRef.delete { error in
            if let error = error {
                failure!(error.localizedDescription)
                // Uh-oh, an error occurred!
            } else {
                // File deleted successfully
                completion!()
            }
        }
    }
    
    func nsdataToJSON (data: NSData) -> AnyObject? {
        do {
            return try JSONSerialization.jsonObject(with: data as Data, options: .mutableContainers) as AnyObject
        } catch let myJSONError {
            print(myJSONError)
        }
        return nil
    }
    
    open func shareTwitter(inProduct: FSProduct, shareImage:UIImage, completion: ((String) -> Void)?,
                            failure: ((String) -> Void)?) {
        
        
        var postURL = "https://api.twitter.com/1.1/statuses/update.json?status=" as! String
        postURL = postURL + inProduct.title
        let imgData = UIImageJPEGRepresentation(shareImage, 0.6)
        
        
        TWTRTwitter.sharedInstance().logIn(completion: { (session, error) in
            if (session != nil) {
                let userID = session?.userID
                let twitterClient = TWTRAPIClient.init(userID:userID)
                if twitterClient != nil {
                    twitterClient.uploadMedia(imgData!, contentType: "multipart/form-data", completion: { (mediaID:String, error:NSError) in
                        if (error == nil) {
                            print("image upload success")
                            
                        }
                        else {
                            failure!(FSMessage.NETWORK_ERROR)
                        }
                    } as! TWTRMediaUploadResponseCompletion as! TWTRMediaUploadResponseCompletion)
                }
                else {
                    failure!(FSMessage.NETWORK_ERROR)
                }
                
            } else {
                print("error: \(String(describing: error?.localizedDescription))");
                failure!((error?.localizedDescription)!)
            }
        })
        
        
////        let store = TWTRTwitter.sharedInstance().sessionStore
////        if let store = store.session() {
//
//            let uploadUrl = "https://upload.twitter.com/1.1/media/upload.json"
//            let updateUrl = "https://api.twitter.com/1.1/statuses/update.json"
//            let imageData = UIImagePNGRepresentation(shareImage) as Data?
//            let imageString = imageData?.base64EncodedString(options: NSData.Base64EncodingOptions())
//
//            let client = TWTRAPIClient.init()
//
//            let requestUploadUrl = client.urlRequest(withMethod: "POST", urlString: uploadUrl, parameters: ["media": imageString], error: nil)
//
//            client.sendTwitterRequest(requestUploadUrl) { (urlResponse, data, connectionError) -> Void in
//                if connectionError == nil {
//                    if let mediaDict = self.nsdataToJSON(data: ((data! as NSData) as Data) as Data as NSData as NSData) as? [String : Any] {
//                        let media_id = mediaDict["media_id_string"] as! String
//                        let message = ["status": inProduct.title, "media_ids": media_id]
//
//                        let requestUpdateUrl = client.urlRequest(withMethod: "POST", urlString: updateUrl, parameters: message, error: nil)
//
//                        client.sendTwitterRequest(requestUpdateUrl, completion: { (urlResponse, data, connectionError) -> Void in
//                            if connectionError == nil {
//
//                                if let _ = self.nsdataToJSON(data: ((data! as NSData) as Data) as Data as NSData) as? [String : Any] {
//                                    print("Upload suceess to Twitter")
//
//                                }
//                            }
//
//                        })
//                    }
//                }
//            }
////        }
    }

    open func shareLinkedIn(inProduct: FSProduct, completion: ((String) -> Void)?,
                            failure: ((String) -> Void)?) {
        
        LISDKSessionManager.createSession(withAuth:
            [LISDK_BASIC_PROFILE_PERMISSION,LISDK_W_SHARE_PERMISSION], state: nil, showGoToAppStoreDialog: true, successBlock: {(sucess) in
                let session = LISDKSessionManager.sharedInstance().session
                print("Session ",session!)
                //let url = "https://api.linkedin.com/v1/people/~"
                if LISDKSessionManager.hasValidSession(){
                    let url: String = "https://api.linkedin.com/v1/people/~/shares"
                    
                    let title = inProduct.title as! String
                    let content = inProduct.contentDescription as! String
                    let imgUrl = inProduct.imgUrls![0] as! String
                    
                    let payloadStr: String = "{\"comment\":\"BitYo\",\"content\":{\"title\": \"\(title)\",\"description\": \"\(content)\",\"submitted-url\":\"\(APP_URL)\", \"submitted-image-url\": \"\(imgUrl)\"},\"visibility\":{\"code\":\"anyone\"}}"

                    
//                    let payloadStr: String = "{\"comment\":\"YOUR_APP_LINK_OR_WHATEVER_YOU_WANT_TO_SHARE\",\"visibility\":{\"code\":\"anyone\"}}"
                    
                    let payloadData = payloadStr.data(using: String.Encoding.utf8)
                    
                    LISDKAPIHelper.sharedInstance().postRequest(url, body: payloadData, success: { (response) in
                        print(response!.data)
                        completion!(response!.data)
                    }, error: { (error) in
                        print(error!)
                        failure!((error?.localizedDescription)!)
                    })
                }
        }) {(error) in
            failure!((error?.localizedDescription)!)
        }
    }

    open func shareFacebook(inProduct: FSProduct, sourceVC:UIViewController, completion: ((FSProduct) -> Void)?,
                            failure: ((String) -> Void)?) {
        
        // Create an object
        
        let properties = [
            "fb:app_id": "Fb_id",
            "og:type": "article",
            "og:title": inProduct.title,
            "og:description": inProduct.contentDescription,
            "og:image" : inProduct.imgUrls,
            "og:url" : APP_URL,
            ] as [String : Any]
        
        let object : FBSDKShareOpenGraphObject = FBSDKShareOpenGraphObject.init(properties: properties)
        
        let action : FBSDKShareOpenGraphAction = FBSDKShareOpenGraphAction()
        action.actionType = "news.publishes"
        action.setObject(object, forKey: "article")
        
        let content : FBSDKShareOpenGraphContent = FBSDKShareOpenGraphContent()
        content.action = action
        content.previewPropertyName = "article"
        
        var shareDialog = FBSDKShareDialog()
        
        shareDialog.fromViewController = sourceVC
        shareDialog.shareContent = content;
        shareDialog.show()
        
        if (shareDialog.canShow() == false) {
            failure!("can't show")
        }
        
    }

    func createProduct(completion: ((FSProduct) -> Void)?,
                    failure: ((String) -> Void)?) {
        
        let seller = FSUserManager.sharedInstance.user
        
        let now = Date().iso8601
        let data = ["uid": product?.uid,
                    "sellerId": product?.sellerId,
                    "address": seller?.address,
                    "lat": seller?.lat,
                    "lng": seller?.lng,
                    "title": product?.title,
                    "timestamp": now,
                    "appLink": product?.appLink,
                    "logoUrl": product?.logoUrl?.absoluteString,
                    "videoUrl": product?.videoUrl?.absoluteString,
                    "category": product?.category,
                    "subcategory": product?.subcategory,
                    "contentDescription": product?.contentDescription,
                    "image": product?.imgUrls
            ] as [String : Any]
        
        let childUpdates = ["/\(kProductsKey)/\(product!.uid)": data
        ]
        
        if let userid = seller?.uid {
            let userRef :DatabaseReference = FSUser.collection.child(userid).child(kProductsKey)
            let postValues:[String:Any] = [(product?.uid)!: Date().iso8601]
            userRef.updateChildValues(postValues)
        }
        
        self.ref.updateChildValues(childUpdates,  withCompletionBlock: { (error:Error?, refer:DatabaseReference!) in
            if (error != nil) {
                failure!((error?.localizedDescription)!)
            }
            completion!(self.product!)
        })
    }
}

