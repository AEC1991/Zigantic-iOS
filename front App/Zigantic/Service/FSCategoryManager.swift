//
//  FSCategoryManager.swift
//  Bityo
//
//  Created by iOS Developer on 1/24/18.
//  Copyright © 2018 Chirag Ganatra. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class FSCategoryManager: NSObject {
    
    static let sharedInstance = FSCategoryManager()
    
    var category: FSCategory?
    var categoryList: [String] = []
    
    private override init() {
        super.init()
    }
    
    func getCategories(completion: (([String]) -> Void)?,
                  failure: ((String) -> Void)?) {
        let f: DatabaseReference? = FSCategory.collection
        let q: DatabaseQuery? = f?.queryOrdered(byChild: "timestamp")
        
        categoryList = []
        
        q?.observe(.value, with: {(_ snapshot: DataSnapshot) -> Void in
            DispatchQueue.main.async(execute: {
                self.categoryList = []
                for item in snapshot.children {
                    let itemRef = item as! DataSnapshot
                    self.categoryList.insert(itemRef.key as! String, at: 0)
                }
                completion!(self.categoryList)
            })
        }) { (error) in
            failure!(error.localizedDescription)
        }
    }
    
    func getSubCategories(inCat: String, completion: (([String]) -> Void)?,
                       failure: ((String) -> Void)?) {
        
        let f: DatabaseReference? = FSCategory.collection.child(inCat)
        let q: DatabaseQuery? = f?.queryOrdered(byChild: "timestamp")
        
        var subCategoryList:[String] = []
        
        q?.observe(.value, with: {(_ snapshot: DataSnapshot) -> Void in
            DispatchQueue.main.async(execute: {
                subCategoryList = []
                for item in snapshot.children {
                    let itemRef = item as! DataSnapshot
                    subCategoryList.insert(itemRef.key as! String, at: 0)
                }
                completion!(subCategoryList)
            })
        }) { (error) in
            failure!(error.localizedDescription)
        }
    }
}



