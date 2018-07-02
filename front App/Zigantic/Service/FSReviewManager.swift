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

class FSReviewManager: NSObject {
    
    let ref = Database.database().reference()
    static let sharedInstance = FSReviewManager()
    
    var review: FSReview?
    
    private override init() {
        super.init()
    }
    
    func getFeeds(completion: (([DataSnapshot]) -> Void)?,
                  failure: ((String) -> Void)?) {
        let f: DatabaseReference? = FSProduct.collection
        let q: DatabaseQuery? = f?.queryOrdered(byChild: "timestamp")
        var posts:[DataSnapshot] = []
        
        q?.observe(.value, with: {(_ snapshot: DataSnapshot) -> Void in
            DispatchQueue.main.async(execute: {
                posts = []
                for item in snapshot.children {
                    posts.insert(item as! DataSnapshot, at: 0)
                }
                completion!(posts)
            })
        }) { (error) in
            failure!(error.localizedDescription)
        }
    }
    
    func getRefById(uid: String, completion: ((DataSnapshot) -> Void)?,
                    failure: ((String) -> Void)?) {
        FSProduct.collection.child(uid).observe(DataEventType.value, with: { (snapshot) in
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
            let outProduct = FSProduct(dataDictionary: data!)
            completion!(outProduct)
        }) { (error) in
            failure!(error.localizedDescription)
        }
    }
    
    func publishReview(completion: ((FSReview) -> Void)?,
                       failure: ((String) -> Void)?) {
        
        let now = Date().iso8601
        
        if (review?.uid == nil || review?.uid == "") {
            let key = FSReview.collection.childByAutoId().key as! String
            review?.uid = key
        }

        let data = ["uid": review?.uid,
                    "reviewerId": FSUserManager.sharedInstance.user?.uid,
                    "selllerId" :review?.sellerId,
                    "comment": review?.comment,
                    "timestamp": now,
                    "rating": review?.rating,
            ] as [String : Any]
        
        let childUpdates = ["/\(kReviewsKey)/\(review?.sellerId)/\(review!.uid)": data
        ]
        
        self.ref.updateChildValues(childUpdates,  withCompletionBlock: { (error:Error?, refer:DatabaseReference!) in
            if (error != nil) {
                failure!((error?.localizedDescription)!)
            }
            completion!(self.review!)
        })
    }
}


