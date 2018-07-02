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

class FSReportItemManager: NSObject {
    
    let ref = Database.database().reference()
    static let sharedInstance = FSReportItemManager()
    
    var report: FSReportItem?
    
    private override init() {
        super.init()
    }
    
    func doReport(inReport:FSReportItem, completion: ((FSReportItem) -> Void)?,
                       failure: ((String) -> Void)?) {
        
        let now = Date().iso8601
        
        if (inReport.uid == nil || inReport.uid == "") {
            let key = FSReportItem.collection.childByAutoId().key as! String
            inReport.uid = key
        }
        
        let data = ["uid": report?.uid,
                    "reporterId": FSUserManager.sharedInstance.user?.uid,
                    "productId" : inReport.productId,
                    "category": inReport.category,
                    "comment": inReport.comment,
                    "timestamp": now
                    ] as [String : Any]
        
        let childUpdates = ["/\(kReportItemsKey)/\(inReport.productId)/\(inReport.uid)": data
        ]
        
        self.ref.updateChildValues(childUpdates,  withCompletionBlock: { (error:Error?, refer:DatabaseReference!) in
            if (error != nil) {
                failure!((error?.localizedDescription)!)
            }
            completion!(inReport)
        })
    }
}



