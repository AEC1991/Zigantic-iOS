//
//  FSUserManager.swift
//  Faloos
//
//  Created by SQUALL on 2017. 10. 17..
//  Copyright © 2017. ThinkSpan. All rights reserved.
//

import UIKit
import Firebase
import FBSDKCoreKit
import FBSDKLoginKit
import FBSDKShareKit
import CoreLocation

class FSUserManager: NSObject {

    let ref = Database.database().reference()
    static let sharedInstance = FSUserManager()
    let defaults = UserDefaults.standard
    
    var user: FSUser?

    private override init() {
        super.init()
    }
    
    func save() {
        defaults.set(user?.uid, forKey: "uid")
    }
    
    func isOnline(){
        FSUser.collection.child((user?.uid)!).child("status").setValue(true)
    }
    
    func isOffline(){
        FSUser.collection.child((user?.uid)!).child("status").setValue(false)
    }
    
    class func observeUserStatus(userId: String, completion: @escaping (Bool) -> Swift.Void) {
        FSUser.collection.child(userId).child("status").queryOrderedByValue().queryEqual(toValue: true).observe(.value) { (data: DataSnapshot) in
            completion(true)
        }
        FSUser.collection.child(userId).child("status").queryOrderedByValue().queryEqual(toValue: false).observe(.value) { (data: DataSnapshot) in
            completion(false)
        }
    }
    
    func getFbInfo()-> String {
        let id = defaults.object(forKey: "fbid") as? String
        if (id == nil)
        {
            return ""
        }
        else {
            user = FSUser()
            user?.uid = (defaults.object(forKey: "fbid") as? String)!
            user?.username = (defaults.object(forKey: "username") as? String)!
            user?.fbname = (defaults.object(forKey: "fbname") as? String)!
            user?.email = (defaults.object(forKey: "email") as? String)!
            user?.phone = (defaults.object(forKey: "phone") as? String)!
            let imgUrlString = defaults.object(forKey: "imgUrl") as? String
            user?.imgUrl = URL(string: imgUrlString!)
            let page = defaults.object(forKey: "page") as? String
            return page!
        }
    }
    
    func restore(completion: ((Bool) -> Void)?,
                 failure: ((String) -> Void)?) {
        
        user = FSUser()
        user?.uid = (defaults.object(forKey: "uid") as? String)!
        self.getByIdNoAvatarSingleEvent(uid: (user?.uid)!,
             completion: { (output:FSUser) in
                self.user = output
                completion!(true)
        },
         failure: {(errorComment: String) -> Void in
            failure!(errorComment)
        })
    }
    
    func canRestore() -> Bool {
        return defaults.object(forKey: "uid") != nil
    }
    
    func createUser(completion: ((FSUser) -> Void)?,
                     failure: ((String) -> Void)?) {
        print(self.user?.imgUrl?.absoluteString)
        let now = Date().iso8601

        let data = ["uid": user?.uid,
                    "username": self.user?.username,
                    "paypal": self.user?.paypalname,
                    "email": self.user?.email,
                    "school": self.user?.school,
                    "type": self.user?.type,
                    "timestamp": now,
                    "grade": self.user?.grade,
                    "imgUrl": self.user?.imgUrl?.absoluteString
            ] as [String : Any]
        
        let childUpdates = ["/users/\(user!.uid)": data
        ]
        
        self.ref.updateChildValues(childUpdates,  withCompletionBlock: { (error:Error?, refer:DatabaseReference!) in
            if (error != nil) {
                failure!((error?.localizedDescription)!)
            }
            completion!(self.user!)
        })
    }
    
    func getUsers(completion: (([DataSnapshot]) -> Void)?,
                  failure: ((String) -> Void)?) {
        let f: DatabaseReference? = FSUser.collection
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
    
    func updateLocation(_ userPlace:CLPlacemark) {
        let userAddress = userPlace.locality! + ", " + userPlace.administrativeArea! + ", " + userPlace.country!
        
        let data = ["lat": userPlace.location?.coordinate.latitude,
                    "lng": userPlace.location?.coordinate.longitude,
                    "address": userAddress
            ] as [String : Any]
        FSUser.collection.child((user?.uid)!).updateChildValues(data)
    }

    open func registerFirebaseToken() {
        if let refreshedToken = InstanceID.instanceID().token() {
            let childUpdates = ["pushToken" : refreshedToken] as [String : Any]
            FSUser.collection.child((user?.uid)!).updateChildValues(childUpdates)
        }
    }
    
    open func signIn(completion: ((FSUser) -> Void)?,
                     failure: ((String) -> Void)?) {
        Auth.auth().signIn(withEmail: (user?.email)!, password: (user?.password)!) { (user, error) in
            if (error != nil) {
                failure!((error?.localizedDescription)!)
            }
            else {
                self.user?.uid = (user?.uid)!
                self.getMeUpdate(completion: {(user: FSUser) -> Void in
                    completion!(user)
                }, failure: {(error: String) -> Void in
                    failure!(error)
                })
            }
        }
    }
    
    open func signOut() {
        try! Auth.auth().signOut()
        self.user = nil
        defaults.removeObject(forKey: "uid")
    }

    open func signUp(completion: ((FSUser) -> Void)?,
                     failure: ((String) -> Void)?) {
        
        Auth.auth().createUser(withEmail: (user?.email)!, password: (user?.password)!) { (user, error) in
            if (error != nil) {
                failure!((error?.localizedDescription)!)
                return
            }
            
            if (user?.uid == nil) {
                failure!(FSMessage.NETWORK_ERROR)
                return
            }
            
            self.user?.uid = (user?.uid)!
            
            self.uploadAvatar(
                completion: {() in
                    
                    if ADMIN_EMAILS.contains((self.user?.email)!) == true {
                        self.user?.type = "admin"
                    }
                    
                    self.createUser(completion: {(user: FSUser) -> Void in
                        completion!(user)
                    },
                        failure: {(error: String) -> Void in
                            failure!(error)
                    })
            },
                failure: {(errorComment: String) -> Void in
                    failure!(errorComment)
            })
        }
    }
    
    open func updatePersonalnfo() {
        let childUpdates = ["/users/\(user!.uid)/username": user?.username,
                   "/users/\(user!.uid)/email": user?.email,
                    "/users/\(user!.uid)/address": user?.address,
                    "/users/\(user!.uid)/lat": user?.lat,
                    "/users/\(user!.uid)/lng": user?.lng
            ] as [String : Any]
        ref.updateChildValues(childUpdates)
        return
    }
    
    open func saveUserInfo() {
        
    }
    
    //sign in firebase with google credential
    open func signInGoogle(user:GIDGoogleUser!, completion: ((Bool) -> Void)?,
                       failure: ((String) -> Void)?) {
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                          accessToken: authentication.accessToken)
        
        Auth.auth().signIn(with: credential, completion: { (user, error) in
            if (error != nil)
            {
                failure!((error?.localizedDescription)!)
            }
            else {
                let id = Auth.auth().currentUser?.uid
                let ref = Database.database().reference(withPath: "users")
                ref.child(id!).observeSingleEvent(of: .value, with: {(snapshot) in
                    if snapshot.exists() {
                        //User signs in
                        let value = snapshot.value as? NSDictionary
                        self.user = FSUser(dataDictionary: value!)
                        //save log info
                        self.save()
                        self.verifiedWith(inType: "Google", content: (user?.email)!, completion: { (user) in
                            completion!(true)
                        }, failure: {(error) in
                            failure!(error)
                        })
                    } else {
                        //User is signing UP
                        completion!(false)
                    }
                })
            }
        })
    }

    //sign in firebase with facebook credential
    open func signInFB(completion: ((Bool) -> Void)?,
                       failure: ((String) -> Void)?) {
        
        let accessToken = FBSDKAccessToken.current()
        guard let accessTokenString = accessToken?.tokenString else {return}
        let credentials = FacebookAuthProvider.credential(withAccessToken: accessTokenString)
        
        Auth.auth().signIn(with: credentials, completion: { (user, error) in
            if (error != nil)
            {
                failure!((error?.localizedDescription)!)
            }
            else {
                    let id = Auth.auth().currentUser?.uid
                    FSUser.collection.child(id!).observeSingleEvent(of: .value, with: {(snapshot) in
                        if snapshot.exists() {
                            //User signs in
                            let value = snapshot.value as? NSDictionary
                            self.user = FSUser(dataDictionary: value!)
                            //save log info
                            self.save()
                            self.verifiedWith(inType: "Facebook", content: (user?.email)!, completion: { (user) in
                                completion!(true)
                            }, failure: {(error) in
                                failure!(error)
                            })
                        } else {
                            //User is signing UP
                            completion!(false)
                        }
                    })
            }
        })
    }
    
    open func changePassword(_ oldPass:String, _ newPass:String, completion: ((FSUser) -> Void)?,
                             failure: ((String) -> Void)?) {
        
        let user = Auth.auth().currentUser
        let credential = EmailAuthProvider.credential(withEmail: (user?.email)!, password: oldPass)
        
        user?.reauthenticate(with: credential, completion: { (error) in
            if error != nil{
                failure!((error?.localizedDescription)!)
            }
            else{
                //change to new password
                Auth.auth().currentUser?.updatePassword(to: newPass) { (error) in
                    if error != nil{
                        failure!((error?.localizedDescription)!)
                    }
                    else {
                        completion!(self.user!)
                    }
                }
            }
        })
    }
    
    open func connectGoogle(_ gUser:GIDGoogleUser!, completion: ((FSUser) -> Void)?,
                               failure: ((String) -> Void)?) {
        
        let data = [
            "google": gUser.profile.email
            ] as [String : Any]
        
        FSUser.collection.child((user?.uid)!).updateChildValues(data, withCompletionBlock: { (error:Error?, refer:DatabaseReference!) in
            if (error != nil) {
                failure!((error?.localizedDescription)!)
                return
            }
            else {
                completion!(self.user!)
            }
        })
    }

    open func signUpWithGoogle(_ gUser:GIDGoogleUser!, completion: ((FSUser) -> Void)?,
                           failure: ((String) -> Void)?) {
        
        user = FSUser()
        
        // Perform any operations on signed in user here.
        user?.uid = gUser.userID              // For client-side use only!
        user?.username = gUser.profile.name
        user?.email = gUser.profile.email
        user?.imgUrl = gUser.profile.imageURL(withDimension: 1024)
        
        if ADMIN_EMAILS.contains((user?.email)!) == true {
            user?.type = "admin"
        }
        else {
            user?.type = "survey"
        }

        self.createUser(completion: {(user: FSUser) -> Void in
            self.save()
            self.verifiedWith(inType: "Google", content: user.email, completion: { (user) in
                completion!(user)
            }, failure: {(error) in
                failure!(error)
            })
        },
            failure: {(error: String) -> Void in
                failure!(error)
        })
    }
    
    open func signUpWithFb(completion: ((FSUser) -> Void)?,
                           failure: ((String) -> Void)?) {
        let currentUser = Auth.auth().currentUser
        user = FSUser()
        user?.uid = (currentUser?.uid)!
        if ((currentUser?.displayName) != nil)
        {
            user?.username = (currentUser?.displayName)!
            user?.fbname = (user?.username)!
        }
        if ((currentUser?.email) != nil)
        {
            user?.email = (currentUser?.email)!
        }
        if ((currentUser?.photoURL) != nil)
        {
            user?.imgUrl = currentUser?.photoURL            
        }
        
        self.createUser(completion: {(user: FSUser) -> Void in
            self.verifiedWith(inType: "Facebook", content: user.email, completion: { (user) in
                completion!(user)
            }, failure: {(error) in
                failure!(error)
            })
        },
            failure: {(error: String) -> Void in
                failure!(error)
        })
    }
    
    open func getByIdNoAvatar(uid: String, completion: ((FSUser) -> Void)?,
                      failure: ((String) -> Void)?) {
        
        FSUser.collection.child(uid).observe(DataEventType.value, with: { (snapshot) in
            // Get user value
            let data = snapshot.value as? NSDictionary
            if (data == nil) {
                failure!(FSMessage.NETWORK_ERROR)
                return
            }
            
            let outputuser = FSUser(dataDictionary: data!)
            outputuser.avatarImage = self.user?.avatarImage
            completion!(outputuser)
        }) { (error) in
            failure!(error.localizedDescription)
        }
    }
    
    open func getByIdNoAvatarSingleEvent(uid: String, completion: ((FSUser) -> Void)?,
                              failure: ((String) -> Void)?) {
        FSUser.collection.child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let data = snapshot.value as? NSDictionary
            if (data == nil) {
                failure!(FSMessage.NETWORK_ERROR)
                return
            }

            let outputuser = FSUser(dataDictionary: data!)
            completion!(outputuser)
        }) { (error) in
            failure!(error.localizedDescription)
        }
    }    

    open func getById(uid: String, completion: ((FSUser) -> Void)?,
                      failure: ((String) -> Void)?) {
        
        FSUser.collection.child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let data = snapshot.value as? NSDictionary
            let outputuser = FSUser(dataDictionary: data!)
            
            Utilities.downloadImage(url: (outputuser.imgUrl)!, completion: {(avatarImage) in
                outputuser.avatarImage = avatarImage
                completion!(outputuser)
            },
            failure: {(errorComment: String) -> Void in
                failure!(errorComment)
            }
            )
        }) { (error) in
            failure!(error.localizedDescription)
        }
    }
    
    open func getMeUpdate(completion: ((FSUser) -> Void)?,
                          failure: ((String) -> Void)?) {
        
        if (user == nil) {
            failure!(FSMessage.USER_LOGOUT)
            return
        }
        
        FSUser.collection.child((user?.uid)!).observeSingleEvent(of: .value, with: { (snapshot) in
            if (snapshot == nil) {
                failure!(FSMessage.NETWORK_ERROR)
            }
            else {
                // Get user value
                let data = snapshot.value as? NSDictionary
                if data == nil {
                    failure!("Your account is removed or not exist!")
                }
                else {
                    let outputuser = FSUser(dataDictionary: data!)
                    outputuser.avatarImage = self.user?.avatarImage
                    self.user = outputuser
                    completion!(self.user!)
                }
            }
        })
    }
    
    open func getMeUpdateChange(completion: ((FSUser) -> Void)?,
                          failure: ((String) -> Void)?) {
        
        if (user == nil) {
            failure!(FSMessage.USER_LOGOUT)
            return
        }
        FSUser.collection.child((user?.uid)!).observe(DataEventType.value, with: { (snapshot) in
            if (snapshot == nil) {
                failure!(FSMessage.NETWORK_ERROR)
            }
            else {
                // Get user value
                let data = snapshot.value as? NSDictionary
                let outputuser = FSUser(dataDictionary: data!)
                outputuser.avatarImage = self.user?.avatarImage
                self.user = outputuser
                completion!(self.user!)
            }
        })
    }
    
    open func getByName(name: String, completion: (([FSUser]) -> Void)?,
                            failure: ((String) -> Void)?) {

        FSUser.collection.observeSingleEvent(of: .value, with: { (snapshot) in
            var resultUsers: [FSUser] = []
            if (snapshot.exists())
            {
                resultUsers.removeAll()
                for child in snapshot.children {
                    let snap = child as! DataSnapshot
                    var data = snap.value as! NSDictionary
                    var username = data["username"] as! String
                    var fullname = data["fullname"] as! String
                    if (username.range(of:name) != nil || fullname.range(of:name) != nil)
                    {
                        resultUsers.append(FSUser(dataDictionary: data))
                    }
                }
                print("result count %d", resultUsers.count)
            }
            completion!(resultUsers)
            
        })
    }
    
    open func getByUsername(username: String, completion: ((FSUser) -> Void)?,
                      failure: ((String) -> Void)?) {
        
        ref.child("users").queryOrdered(byChild:  "username").queryEqual(toValue: username).observeSingleEvent(of: .value, with: { (snapshot) in
            
            var data = snapshot.value as? NSDictionary
            var output = data?.allValues[0] as? NSDictionary
            
            if (output == nil)
            {
                failure!(FSMessage.NO_USER)
                return
            }
            let outputuser = FSUser(dataDictionary: output!)
            
            Utilities.downloadImage(url: (outputuser.imgUrl)!, completion: {(avatarImage) in
                outputuser.avatarImage = avatarImage
                completion!(outputuser)
            },
            failure: {(errorComment: String) -> Void in
                failure!(errorComment)
            }
            )
        })
    }
    
    open func getByFullname(fullname: String, completion: ((FSUser) -> Void)?,
                            failure: ((String) -> Void)?) {
        
        ref.child("users").queryOrdered(byChild:  "fullname").queryEqual(toValue: fullname).observeSingleEvent(of: .value, with: { (snapshot) in
            
            var data = snapshot.value as? NSDictionary
            var output = data?.allValues[0] as? NSDictionary
            
            if (output == nil)
            {
                failure!(FSMessage.NO_USER)
                return
            }
            let outputuser = FSUser(dataDictionary: output!)
            
            Utilities.downloadImage(url: (outputuser.imgUrl)!, completion: {(avatarImage) in
                outputuser.avatarImage = avatarImage
                completion!(outputuser)
            },
                failure: {(errorComment: String) -> Void in
                    failure!(errorComment)
            })
        })
    }
    
    open func sendVerificationEmail(completion: ((String) -> Void)?,
                                    failure: ((String) -> Void)?) {
        
        if (Auth.auth().currentUser?.isEmailVerified == true) {
            print("email verified")
        }
        else {
            print("email unverified")
        }
        
        let inUser = Auth.auth().currentUser
        Auth.auth().currentUser?.sendEmailVerification(completion: { error in
            if (error != nil) {
                // Error occurred. Inspect error.code and handle error.
                failure!((error?.localizedDescription)!)
                return
            }
            // Email verification sent.
            completion!(FSMessage.VERIFY_EMAIL_SENT)
        })
    }
    
    open func sendPasswordResetEmail(email:String, completion: ((String) -> Void)?,
                                     failure: ((String) -> Void)?)  {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if (error != nil) {
                failure!((error?.localizedDescription)!)
                return
            }
            else {
                completion!(FSMessage.PASSWORD_RESET_EMAIL)
            }
        }
    }
    
    open func verifiedWith(inType:String, content:String, completion: ((FSUser) -> Void)?,
                           failure: ((String) -> Void)?) {
        
        let myRef :DatabaseReference = FSUser.collection.child((self.user?.uid)!).child("verified")
        var postValues:[String:Any]
        if inType == "Google" {
            postValues = ["Google":content,
                          "Email":content
            ]
        }
        else if inType == "Facebook" {
            postValues = ["Facebook":content,
                          "Email":content
            ]
        }
        else {
            postValues = [inType:content]
        }
        
        myRef.updateChildValues(postValues, withCompletionBlock: { (error:Error?, refer:DatabaseReference!) in
            if (error != nil) {
                failure!((error?.localizedDescription)!)
                return
            }
            else {
                completion!(self.user!)
            }
        })
    }
    
    open func setUnReadNum(num: Int){
        FSUser.collection.child((user?.uid)!).updateChildValues(["unreadNum": num])
    }
    
    open func addFollowingUser(inUser: FSUser) {
        
        let myRef :DatabaseReference = FSUser.collection.child((user?.uid)!).child("usersImFollowing")
        let postValues:[String:Any] = [inUser.uid: inUser.uid]
        myRef.updateChildValues(postValues)
        
        let userRef :DatabaseReference = FSUser.collection.child(inUser.uid).child("usersFollowingMe")
        let userValues:[String:Any] = [user!.uid: user!.uid]
        userRef.updateChildValues(userValues)
    }
    
    open func removeFollowingUser(inUser: FSUser) {
        let myRef :DatabaseReference = FSUser.collection.child((user?.uid)!).child("usersImFollowing")
        myRef.child(inUser.uid).removeValue()
        let userRef :DatabaseReference = FSUser.collection.child(inUser.uid).child("usersFollowingMe")
        userRef.child((user?.uid)!).removeValue()
    }

    open func checkImFollowing(_ inUser:FSUser)->Bool {
        
        for followId in (user?.usersImFollowing)!
        {
            let strFollowId = followId as? String
            if (inUser.uid == strFollowId)
            {
                return true
            }
        }
        return false
    }

    open func getByFbname(fbname: String, completion: ((FSUser) -> Void)?,
                            failure: ((String) -> Void)?) {
        
        ref.child("users").queryOrdered(byChild:  "fbname").queryEqual(toValue: fbname).observeSingleEvent(of: .value, with: { (snapshot) in
            
            var data = snapshot.value as? NSDictionary
            var output = data?.allValues[0] as? NSDictionary
            
            if (output == nil)
            {
                failure!(FSMessage.NO_USER)
                return
            }
            let outputuser = FSUser(dataDictionary: output!)
            
            Utilities.downloadImage(url: (outputuser.imgUrl)!, completion: {(avatarImage) in
                outputuser.avatarImage = avatarImage
                completion!(outputuser)
            },
                failure: {(errorComment: String) -> Void in
                    failure!(errorComment)
            }
            )
        })
    }
    
    open func changeAvatar(imgUrl: String) {
        
        let data = [
                    "imgUrl": imgUrl
            ] as [String : Any]

        FSUser.collection.child((user?.uid)!).updateChildValues(data)
        return
    }
    
    open func uploadAvatar(completion: (()->Void)?,
                           failure: ((String) -> Void)?) {
        if (self.user?.avatarImage != nil) {
            Utilities.uploadMedia(image: (self.user?.avatarImage)!, ref: "avatar/" + (user?.uid)!, completion: {(imgUrl) in
                print("change avatar")
                self.user?.imgUrl = imgUrl
                self.changeAvatar(imgUrl: imgUrl.absoluteString)
                completion!()
            },
                                  failure: {(errorComment: String) -> Void in
                                    print(errorComment)
                                    failure!(errorComment)
            })
        }
        else {
            completion!()
        }
    }
    
    func removeUserByAdmin(_ inUser:FSUser, completion: (() -> Void)?,
                             failure: ((String) -> Void)?) {
        //remove product by the user
        if inUser.products != [] {
            for perProductID in inUser.products {
                let productRef :DatabaseReference = FSProduct.collection.child(perProductID)
                productRef.removeValue()
            }
        }
        
        //remove survey by the user
        if inUser.surveys != [] {
            for perSurveyID in inUser.surveys {
                let surveyRef :DatabaseReference = FSSurvey.collection.child(perSurveyID)
                surveyRef.removeValue()
            }
        }
        
        //remove user
        let userRef :DatabaseReference = FSUser.collection.child(inUser.uid)
        userRef.removeValue()
        
        completion!()
    }
    

    open func logout() {
        try! Auth.auth().signOut()
        
        let loginManager = FBSDKLoginManager()
        loginManager.logOut()
        FBSDKAccessToken.setCurrent(nil)

        self.user = nil
        
        defaults.removeObject(forKey: "uid")
        defaults.removeObject(forKey: "username")
        defaults.removeObject(forKey: "fullname")
        defaults.removeObject(forKey: "email")
        defaults.removeObject(forKey: "phone")
        defaults.removeObject(forKey: "imgUrl")
    }
}
