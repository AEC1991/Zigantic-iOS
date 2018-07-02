//
//  SettingsViewController.swift
//  Bityo
//
//  Created by Chirag Ganatra on 29/11/17.
//  Copyright © 2017 Chirag Ganatra. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import FBSDKShareKit
import StoreKit
import Firebase
import MessageUI

class SettingsViewController: UIViewController, GIDSignInDelegate, GIDSignInUIDelegate  {
    
    var user:FSUser?
    
    @IBOutlet weak var lblGoogle: UILabel!
    @IBOutlet weak var lblEmail: UILabel!
    @IBOutlet weak var lblPhone: UILabel!
    @IBOutlet weak var lblFacebook: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        user = FSUserManager.sharedInstance.user!
        // Do any additional setup after loading the view.
        setupUI()
        Auth.auth().addStateDidChangeListener { (auth, user) in
            // ...
            print("auth changed")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupUI() {
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self

        if (user?.verifiedLinks != nil) {
            for link in (user?.verifiedLinks)! {
                if (link == "Facebook") {
                    lblFacebook.text = "Facebook Connected"
                }
                else if (link == "Google") {
                    lblGoogle.text = "Google Connected"
                }
                else if (link == "Email") {
                    lblEmail.text = self.user?.email
                }
                else if (link == "Phone") {
                    lblPhone.text = "Phone Connected"
                }
            }
        }
        else {
            lblGoogle.text = "Google Confirm"
            lblEmail.text = "Email Confirm"
            lblPhone.text = "Phone Confirm"
            lblFacebook.text = "Connect Facebook"
        }
    }
    
    @IBAction func confirmGoogleTapped(_ sender: Any) {
        googleAuth()
    }
    
    /** This method start google auth using GoogleSDK */
    func googleAuth() {
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().disconnect()
        GIDSignIn.sharedInstance().signOut()
        GIDSignIn.sharedInstance().signIn()
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor gUser: GIDGoogleUser!, withError error: Error!) {
        if (error == nil) {
            FSUserManager.sharedInstance.verifiedWith(inType: "Google", content: gUser.profile.email,
                  completion: { (outuser) in
                    self.user = outuser
                    self.setupUI()
            },
                  failure: {(error) in
                    self.showAlert(title: appName, message: error)
            })
        } else {
            self.showAlert(title: appName, message: error.localizedDescription)
            print("ERROR ::\(error.localizedDescription)")
        }
    }

    @IBAction func confirmEmailTapped(_ sender: Any) {
        
        FSUserManager.sharedInstance.sendVerificationEmail(completion: {(result: String) -> Void in
            self.showAlert(title: appName, message: result)
        },
            failure: {(error: String) -> Void in
                self.showAlert(title: appName, message: error)
        })
    }
    
    @IBAction func confirmPhoneTapped(_ sender: Any) {
        let vc = Utilities.viewController("VerifyPhoneViewController", onStoryboard: "Authentication") as! VerifyPhoneViewController
        vc.phone = self.user?.phone
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func confirmFacebookTapped(_ sender: Any) {
        let fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
        
        fbLoginManager.logIn(withReadPermissions: ["email","public_profile","user_friends"], from: self, handler: { (result, error) -> Void in
            if (error == nil){
                let fbloginresult : FBSDKLoginManagerLoginResult = result!
                
                print("\(fbloginresult.debugDescription)")
                
                if ((error) != nil){
                    print("Facebook Login Failed")
                    self.showAlert(title: appName, message: (error?.localizedDescription)!)
                }else if (result?.isCancelled)!{
                    print("Result: \(result!)")
                }else{
                    if(fbloginresult.grantedPermissions.contains("email")){
                        FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email"]).start(completionHandler: { (connection, result, error) -> Void in
                            if (error != nil) {
                                self.showAlert(title: appName, message: (error?.localizedDescription)!)
                            }
                            else {
                                let email = (result as AnyObject).value(forKey: "email") as! String
                                FSUserManager.sharedInstance.verifiedWith(inType: "Facebook", content: email,
                                      completion: { (outuser) in
                                        self.user = outuser
                                        self.setupUI()
                                },
                                      failure: {(error) in
                                        self.showAlert(title: appName, message: error)
                                })
                            }
                        })
                    }
                }
            }else{
                self.showAlert(title: appName, message: (error?.localizedDescription)!)
                print("Error : \(error.debugDescription)")
            }
        })
    }
    
    @IBAction func EditProfileTapped(_ sender: Any) {
        let vc = Utilities.viewController("EditProfileViewController", onStoryboard: "Settings")
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func helpSupportTapped(_ sender: Any) {
        // 2. send email with report
        if (MFMailComposeViewController.canSendMail()) {
            let email = MFMailComposeViewController()
            email.setSubject("BitYo Support")
            email.mailComposeDelegate = self
            email.setToRecipients([ADMIN_EMAIL])
            self.present(email, animated: true, completion: nil)
        } else {
            let body = "BitYo Support"
            let encodedBody = body.addingPercentEncoding(withAllowedCharacters:.urlHostAllowed) ?? ""
            
            if let mailurl = URL(string:"mailto:\(ADMIN_EMAIL)?subject=\(encodedBody)") {
                UIApplication.shared.openURL(mailurl)
            }
        }
    }
    
    @IBAction func shareBityoTapped(_ sender: Any) {
        let firstActivityItem = "Download BitYo Today!"
        let secondActivityItem : NSURL = NSURL(string: APP_URL)!
        // If you want to put an image
        let image : UIImage = UIImage(named: "shareicon")!
        
        let activityViewController : UIActivityViewController = UIActivityViewController(
            activityItems: [image, firstActivityItem, secondActivityItem], applicationActivities: nil)
        
        // Anything you want to exclude
        activityViewController.excludedActivityTypes = [
            UIActivityType.postToWeibo,
            UIActivityType.print,
            UIActivityType.assignToContact,
            UIActivityType.saveToCameraRoll,
            UIActivityType.addToReadingList,
            UIActivityType.postToFlickr,
            UIActivityType.postToVimeo,
            UIActivityType.postToTencentWeibo
        ]
        
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    @IBAction func rateUsTapped(_ sender: Any) {
        if #available(iOS 10.3, *) {
            SKStoreReviewController.requestReview()
        } else {
            // Fallback on earlier versions
        }
    }
    
    @IBAction func menuTapped(_ sender: Any) {
        self.sideMenuController().openMenu()
    }
    
    @IBAction func logoutTapped(_ sender: Any) {
       FSUserManager.sharedInstance.logout()
       DELEGATE.goLoginPage(transition: true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}

extension SettingsViewController : MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}

