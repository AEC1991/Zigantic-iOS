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

class FSNotification {
    var senderId:String
    var senderName: String
    var timestamp: String
    var content:String
    var chatId:String
    
    init(senderId: String, senderName: String, timestamp: String, content:String, chatId:String) {
        self.senderId = senderId
        self.senderName = senderName
        self.timestamp = timestamp
        self.content = content
        self.chatId = chatId
    }
}

class Message {
    
    //MARK: Properties
    var owner: MessageOwner
    var type: MessageType
    var content: Any
    var timestamp: String
    var timeString: String
    var isRead: Bool
    var image: UIImage?
    var toID: String?
    var fromID: String?
    var conversationID: String = ""
    var uID: String = ""
    var offerStatus: String = ""
    
    static var collection:DatabaseReference {
        get {
            return Database.database().reference().child(kMessagesKey)
        }
    }
    
    class func downloadAllMessages(productId: String, toID: String, completion: ((Message) -> Void)?,
                              failure: ((String) -> Void)?) {
        
        let myRef = productId + ":" + toID

        if let currentUserID = FSUserManager.sharedInstance.user?.uid {
            FSUser.collection.child(currentUserID).child(kMessagesKey).child(myRef).observe(.value, with: { (snapshot) in
                if snapshot.exists() {
                    let data = snapshot.value as! [String: String]
                    let location = data["location"]!
                    Message.collection.child(location).observe(.childAdded, with: { (snap) in
                        if snap.exists() {
                            let receivedMessage = snap.value as! [String: Any]
                            let messageType = receivedMessage["type"] as! String
                            var type = MessageType.text
                            
                            switch messageType {
                            case "photo":
                                type = .photo
                            case "location":
                                type = .location
                            case "offer":
                                type = .offer
                            case "text":
                                type = .text
                            default: break
                            }
                            
                            var outMsg:Message
                            print(receivedMessage)
                            let fromID = receivedMessage["fromID"] as! String
                            let content = receivedMessage["content"] as! String
                            let timestamp = receivedMessage["timestamp"] as! String

                            if fromID == currentUserID {
                                outMsg = Message.init(type: type, content: content, owner: .receiver, timestamp: timestamp, isRead: true)
                            }
                            else {
                                outMsg = Message.init(type: type, content: content, owner: .sender, timestamp: timestamp, isRead: true)
                            }

                            let toID = receivedMessage["toID"] as! String
                            outMsg.conversationID = location
                            outMsg.uID = snap.key
                            outMsg.fromID = fromID
                            outMsg.toID = toID
                            
                            if receivedMessage["offerStatus"] != nil {
                                outMsg.offerStatus = receivedMessage["offerStatus"] as! String
                            }
                            else {
                                outMsg.offerStatus = ""
                            }
                            completion!(outMsg)
                        }
                    })
                }
            })
        }
    }
    
    func downloadImage(indexpathRow: Int, completion: @escaping (Bool, Int) -> Swift.Void)  {
        if self.type == .photo {
            let imageLink = self.content as! String
            let imageURL = URL.init(string: imageLink)
            URLSession.shared.dataTask(with: imageURL!, completionHandler: { (data, response, error) in
                if error == nil {
                    self.image = UIImage.init(data: data!)
                    completion(true, indexpathRow)
                }
            }).resume()
        }
    }
    
    class func updateMessage(readMsg: Message) {
        let values = ["type": "offer", "content": readMsg.content, "offerStatus": readMsg.offerStatus, "fromID": readMsg.fromID, "toID": readMsg.toID, "timestamp": readMsg.timestamp, "isRead": true]

        Message.collection.child(readMsg.conversationID).child(readMsg.uID).updateChildValues(values)
    }
    
    class func markMessagesRead(readMsg: Message)  {
        Message.collection.child(readMsg.conversationID).child(readMsg.uID).updateChildValues(["isRead":true])
        var badge:Int =  UIApplication.shared.applicationIconBadgeNumber - 1
        if badge < 0 {
            badge = 0
        }
        FSUserManager.sharedInstance.setUnReadNum(num: badge)
        UIApplication.shared.applicationIconBadgeNumber = badge
    }
    
    class func unReadMessagesCount(forUserID: String , completion: @escaping (Int) -> Swift.Void) {
        var count : Int = 0
        if let currentUserID = Auth.auth().currentUser?.uid {
            Database.database().reference().child("users").child(currentUserID).child("conversations").child(forUserID).observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.exists() {
                    let data = snapshot.value as! [String: String]
                    let location = data["location"]!
                    Database.database().reference().child("conversations").child(location).observeSingleEvent(of: .value, with: { (snap) in
                        if snap.exists() {
                            for item in snap.children {
                                let receivedMessage = (item as! DataSnapshot).value as! [String: Any]
                                let fromID = receivedMessage["fromID"] as! String
                                if fromID != currentUserID {
                                    //Database.database().reference().child("conversations").child(location).child((item as! DataSnapshot).key).child("isRead").setValue(true)
                                    Database.database().reference().child("conversations").child(location).child((item as! DataSnapshot).key).child("isRead").queryOrderedByValue().queryEqual(toValue: false).observe(.value) { (data: DataSnapshot) in
                                        count = count + 1
                                    }
                                }
                            }
                            completion(count)
                        }
                    })
                }
            })
        }
    }
   
    class func downloadLastMessage(forLocation: String, completion: ((Message) -> Void)?,
                             failure: ((String) -> Void)?) {
        if let currentUserID = FSUserManager.sharedInstance.user?.uid {
            Message.collection.child(forLocation).observe(.value, with: { (snapshot) in
                if snapshot.exists() {
                    for snap in snapshot.children {
                        let receivedMessage = (snap as! DataSnapshot).value as! [String: Any]
                        
                        let content = receivedMessage["content"]!
                        let timestamp = receivedMessage["timestamp"] as! String
                        let messageType = receivedMessage["type"] as! String
                        let fromID = receivedMessage["fromID"] as! String
                        let isRead = receivedMessage["isRead"] as! Bool
                        var type = MessageType.text
                        switch messageType {
                        case "text":
                            type = .text
                        case "photo":
                            type = .photo
                        case "location":
                            type = .location
                        default: break
                        }
                        var outMsg:Message

                        if currentUserID == fromID {
                            outMsg = Message.init(type: type, content: content, owner: .receiver, timestamp: timestamp, isRead: isRead)
                        } else {
                            outMsg = Message.init(type: type, content: content, owner: .sender, timestamp: timestamp, isRead: isRead)
                        }
                        completion!(outMsg)
                    }
                }
            })
            { (error) in
                failure!(error.localizedDescription)
            }

        }
    }

    class func send(message: Message, toID: String, productID: String, completion: @escaping (Bool) -> Swift.Void)  {
        if let currentUserID = FSUserManager.sharedInstance.user?.uid {
            switch message.type {
            case .location:
                let values = ["type": "location", "content": message.content, "fromID": currentUserID, "toID": toID, "productID": productID, "timestamp": message.timestamp, "isRead": false]
                Message.uploadMessage(withValues: values, toID: toID, productID: productID, completion: { (status) in
                    completion(status)
                })
            case .photo:
                let imageData = UIImageJPEGRepresentation((message.content as! UIImage), 0.5)
                let child = UUID().uuidString
                Storage.storage().reference().child("messagePics").child(child).putData(imageData!, metadata: nil, completion: { (metadata, error) in
                    if error == nil {
                        let path = metadata?.downloadURL()?.absoluteString
                        let values = ["type": "photo", "content": path!, "fromID": currentUserID, "toID": toID, "productID": productID, "timestamp": message.timestamp, "isRead": false] as [String : Any]
                        Message.uploadMessage(withValues: values, toID: toID, productID: productID, completion: { (status) in
                            completion(status)
                        })
                    }
                })
            case .text:
                let values = ["type": "text", "content": message.content, "fromID": currentUserID, "toID": toID, "productID": productID, "timestamp": message.timestamp, "isRead": false]
                Message.uploadMessage(withValues: values, toID: toID, productID: productID, completion: { (status) in
                    completion(status)
                })
            case .offer:
                let values = ["type": "offer", "content": message.content, "offerStatus":message.offerStatus, "fromID": currentUserID, "toID": toID, "productID": productID, "timestamp": message.timestamp, "isRead": false]
                Message.uploadMessage(withValues: values, toID: toID, productID: productID, completion: { (status) in
                    completion(status)
                })
            }
        }
    }
    
    class func uploadMessage(withValues: [String: Any], toID: String, productID: String, completion: @escaping (Bool) -> Swift.Void) {
        
        if let currentUserID = FSUserManager.sharedInstance.user?.uid {
            let myRef = productID + ":" + toID
            let partnerRef = productID + ":" + currentUserID

            FSUser.collection.child(currentUserID).child(kMessagesKey).child(myRef).observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.exists() {
                    let data = snapshot.value as! [String: String]
                    let location = data["location"]!
                    Database.database().reference().child(kMessagesKey).child(location).childByAutoId().setValue(withValues, withCompletionBlock: { (error, _) in
                        if error == nil {
                            completion(true)
                        } else {
                            completion(false)
                        }
                    })
                } else {
                    Database.database().reference().child(kMessagesKey).childByAutoId().childByAutoId().setValue(withValues, withCompletionBlock: { (error, reference) in
                        let nodeData = ["location": reference.parent!.key
                                    ]
                        
                        FSUser.collection.child(currentUserID).child(kMessagesKey).child(myRef).updateChildValues(nodeData)
                        FSUser.collection.child(toID).child(kMessagesKey).child(partnerRef).updateChildValues(nodeData)
                        completion(true)
                    })
                }
            })
        }
    }
    
    //MARK: Inits
    init(type: MessageType, content: Any, owner: MessageOwner, timestamp: String, isRead: Bool) {
        self.type = type
        self.content = content
        self.owner = owner
        self.timestamp = timestamp
        self.isRead = isRead
        
        if (timestamp != nil && timestamp != "") {
            let time = timestamp.dateFromISO8601 as! Date
            
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.dateFormat = "h:mm a"
            formatter.amSymbol = "am"
            formatter.pmSymbol = "pm"
            
            self.timeString = formatter.string(from: time)
        }
        else {
            self.timeString = ""
        }
    }
}
