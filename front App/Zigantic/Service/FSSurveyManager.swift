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

class FSSurveyManager: NSObject {
    
    let ref = Database.database().reference()
    static let sharedInstance = FSSurveyManager()
    
    var survey: FSSurvey?
    var curUploadingImgNo: Int = 0
    var isCollecting:Bool = false
    
    private override init() {
        super.init()
    }
    
    func getFeeds(completion: (([DataSnapshot]) -> Void)?,
                  failure: ((String) -> Void)?) {
        let f: DatabaseReference? = FSSurvey.collection
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
    
    func checkInMySurveys(_ inProduct:FSSurvey)->Bool {
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
        let productRef :DatabaseReference = FSSurvey.collection.child(inProduct.uid).child("questions")
        let gameValues:[String:Any] = [question: answer]
        productRef.updateChildValues(gameValues)
    }
    
    func addSurveyList(_ inSurvey:FSSurvey) {
        if let userid = FSUserManager.sharedInstance.user?.uid {
            //add product to user's wish list
            let userRef :DatabaseReference = FSUser.collection.child(userid).child("surveys")
            let postValues:[String:Any] = [inSurvey.gameId: Date().iso8601]
            userRef.updateChildValues(postValues)
            
            //add user to product's wished list
            let productRef :DatabaseReference = FSProduct.collection.child(inSurvey.gameId).child("surveys")
            let productValues:[String:Any] = [inSurvey.uid: Date().iso8601]
            productRef.updateChildValues(productValues)
        }
    }
    
    func getRefById(uid: String, completion: ((DataSnapshot) -> Void)?,
                    failure: ((String) -> Void)?) {
        FSSurvey.collection.child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            completion!(snapshot)
        }) { (error) in
            failure!(error.localizedDescription)
        }
    }
    
    open func getById(uid: String, completion: ((FSSurvey) -> Void)?,
                      failure: ((String) -> Void)?) {
        FSSurvey.collection.child(uid).observe(DataEventType.value, with: { (snapshot) in
            // Get user value
            let data = snapshot.value as? NSDictionary
            if (data == nil) {
                failure!(FSMessage.NETWORK_ERROR)
            }
            else {
                let outProduct = FSSurvey(dataDictionary: data!)
                completion!(outProduct)
            }
        }) { (error) in
            failure!(error.localizedDescription)
        }
    }
    
    func removeSurveyByAdmin(_ inSurvey:FSSurvey, completion: (() -> Void)?,
                             failure: ((String) -> Void)?) {
        //remove survey from the user
        let userRef :DatabaseReference = FSUser.collection.child(inSurvey.userId).child("surveys").child(inSurvey.uid)
        userRef.removeValue()
        
        //remove it in the products list
        let productRef :DatabaseReference = FSProduct.collection.child(inSurvey.gameId).child("surveys").child(inSurvey.uid)
        productRef.removeValue()
        
        //remove surveys in the survey list
        let surveyRef:DatabaseReference = FSSurvey.collection.child(inSurvey.uid)
        surveyRef.removeValue()
        
        completion!()
    }

    func removeSurvey(_ inProduct:FSSurvey, completion: (() -> Void)?,
                       failure: ((String) -> Void)?) {
        if let userid = FSUserManager.sharedInstance.user?.uid {
            
            //remove it in the user products list
            let userRef :DatabaseReference = FSUser.collection.child(userid).child("surveys").child(inProduct.uid)
            userRef.removeValue()
            
            //remove it in the products list
            let productRef :DatabaseReference = FSSurvey.collection.child(inProduct.uid)
            productRef.removeValue()
            completion!()
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
    
    func submitSurvey(completion: ((FSSurvey) -> Void)?,
                       failure: ((String) -> Void)?) {
        
        let seller = FSUserManager.sharedInstance.user
        
        let now = Date().iso8601
        let data = ["uid": survey?.uid,
                    "userId": survey?.userId,
                    "timestamp": now,
                    "gameId": survey?.gameId,
                    "questions": survey?.questionStruct
            ] as [String : Any]
        
        let childUpdates = ["/\(kSurveysKey)/\(survey!.uid)": data
        ]
        
        self.ref.updateChildValues(childUpdates,  withCompletionBlock: { (error:Error?, refer:DatabaseReference!) in
            if (error != nil) {
                failure!((error?.localizedDescription)!)
            }
            completion!(self.survey!)
        })
    }
}


