//  MIT License

//  Copyright (c) 2017 Satish Babariya

//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:

//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.

//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import Foundation
import UIKit
import Firebase

class Conversation {
    
    //MARK: Properties
    let user: FSUser
    let product: FSProduct
    var lastMessage: Message
    
    static var collection:DatabaseReference {
        get {
            return Database.database().reference().child(kMessagesKey)
        }
    }
    
    //MARK: Methods
    class func showConversations(completion: (([DataSnapshot]) -> Void)?,
                                 failure: ((String) -> Void)?) {
        if let currentUserID = FSUserManager.sharedInstance.user?.uid {
            
            FSUser.collection.child(currentUserID).child(kMessagesKey).observe(.value, with: {(_ snapshot: DataSnapshot) -> Void in
                DispatchQueue.main.async(execute: {
                    var items:[DataSnapshot] = []
                    for item in snapshot.children {
                        items.insert(item as! DataSnapshot, at: 0)
                    }
                    completion!(items)
                })
            })
            { (error) in
                failure!(error.localizedDescription)
            }
        }
    }
    
    class func deleteConversationRoom(refId: String) {
        if let currentUserID = FSUserManager.sharedInstance.user?.uid {
            FSUser.collection.child(currentUserID).child(kMessagesKey).child(refId).removeValue()
        }
    }
    
    //MARK: Inits
    init(user: FSUser, product: FSProduct, lastMessage: Message) {
        self.user = user
        self.product = product
        self.lastMessage = lastMessage
    }
    
}
