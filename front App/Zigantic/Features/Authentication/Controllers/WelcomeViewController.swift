//
//  WelcomeViewController.swift
//  Bityo
//
//  Created by Chirag Ganatra on 28/11/17.
//  Copyright © 2017 Chirag Ganatra. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import FBSDKShareKit
import SwiftyJSON
//import GoogleSignIn
import FirebaseAuth

class WelcomeViewController: UIViewController, GIDSignInDelegate, GIDSignInUIDelegate {

    @IBOutlet weak var btnLogin: SpringButton!
    @IBOutlet weak var btnRegister: SpringButton!
    
    @IBOutlet weak var introImg1: SpringImageView!
    
    @IBOutlet weak var btnFacebook: FSLoadingButton!
    @IBOutlet weak var facebookView: UIView!
    
    @IBOutlet weak var googleView: UIView!
    @IBOutlet weak var btnGoogle: FSLoadingButton!
    @IBOutlet weak var googleSigninButton: GIDSignInButton!
    
    @IBOutlet weak var btnTerms: UIButton!
    @IBOutlet weak var btnPrivacy: UIButton!
    
    @IBOutlet weak var topConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (UIScreen.main.nativeBounds.height == 2436) {
            topConstraint.constant = -44.0
        }
        else {
            topConstraint.constant = -20.0
        }

        facebookView.layer.cornerRadius = 20.0
        facebookView.layer.masksToBounds = true
        facebookView.isHidden = true
        
        googleView.layer.cornerRadius = 20.0
        googleView.layer.masksToBounds = true
        
        let tapFacebookGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapFacebook))
        facebookView.addGestureRecognizer(tapFacebookGesture)
        
        let tapGoogleGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapGoogle))
        googleView.addGestureRecognizer(tapGoogleGesture)
        
        if (FSUserManager.sharedInstance.canRestore()) {
            FSUserManager.sharedInstance.restore(
                completion: { (output:Bool) in
                DELEGATE.goHomePage(transition: true)
            },
                failure: {(errorComment: String) -> Void in
                    self.showAlert(title: appName, message: errorComment)
            })
        }
        statusBar?.backgroundColor = .clear
        // Do any additional setup after loading the view.
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        statusBar?.backgroundColor = .clear
        setNeedsStatusBarAppearanceUpdate()
        UIApplication.shared.statusBarStyle = .lightContent
        if (FSUserManager.sharedInstance.canRestore() == false) {
            ShowAnimation()
        }
        else {
            btnLogin.isHidden = true
            btnRegister.isHidden = true
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func ShowAnimation()
    {        
        self.introImg1.animation = "squeezeDown"
        self.introImg1.duration = 1.0
        self.introImg1.delay = 0.3;
        self.introImg1.damping = 0.8
        self.introImg1.animate()
        
        self.btnRegister.animation = "squeezeUp"
        self.btnRegister.duration = 1.0
        self.btnRegister.delay = 0.3;
        self.btnRegister.damping = 0.8
        self.btnRegister.animate()
        
        self.btnLogin.animation = "squeezeUp"
        self.btnLogin.duration = 1.0
        self.btnLogin.delay = 0.3;
        self.btnLogin.damping = 0.8
        self.btnLogin.animate()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func fbSignIn() {
        FSUserManager.sharedInstance.signInFB(
            completion: { (isSign) in
                if (isSign == true)
                {
                    DELEGATE.goHomePage(transition: true)
                }
                else {
                    self.fbSignUp()
                }
        },
            failure: {(error) in
                self.showAlert(title: appName, message: error)
        })
    }
    
    func fbSignUp() {
        
        FSUserManager.sharedInstance.signUpWithFb(completion: {(user: FSUser) -> Void in
            DELEGATE.goHomePage(transition: true)
        },
            failure: {(error: String) -> Void in
                self.showAlert(title: appName, message: error)
        })
    }
    
    func googleSignUp(_ user:GIDGoogleUser!) {
        FSUserManager.sharedInstance.signUpWithGoogle(user, completion: {(user: FSUser) -> Void in
            DELEGATE.goHomePage(transition: true)
        },
            failure: {(error: String) -> Void in
                self.showAlert(title: appName, message: error)
        })
    }
    
    func sign(inWillDispatch signIn: GIDSignIn!, error: Error!) {
        
        guard error == nil else {
            print("Error while trying to redirect : \(error)")
            self.showAlert(title: appName, message: error.localizedDescription)
            return
        }
        
        print("Successful Redirection")
    }
    
    //MARK: GIDSignIn Delegate
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!)
    {
        if (error == nil) {
            
            self.btnGoogle.showLoading()
            FSUserManager.sharedInstance.signInGoogle(user:user,
                  completion: { (isSign) in
                    self.btnGoogle.hideLoading()
                        if (isSign == true)
                        {
                            DELEGATE.goHomePage(transition: true)
                        }
                        else {
                            self.googleSignUp(user)
                        }
            },
                  failure: {(error) in
                    self.btnGoogle.hideLoading()
                        self.showAlert(title: appName, message: error)
            })
        } else {
            self.btnGoogle.hideLoading()
            self.showAlert(title: appName, message: error.localizedDescription)
            print("ERROR ::\(error.localizedDescription)")
        }
    }
    
    // Finished disconnecting |user| from the app successfully if |error| is |nil|.
    public func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!)
    {
        if (error != nil) {
            self.showAlert(title: appName, message: error.localizedDescription)
        }
    }
    
    @IBAction func loginTapped(_ sender: Any) {
//        let vc = Utilities.viewController("LoginViewController", onStoryboard: "Authentication")
//        self.navigationController?.pushViewController(vc, animated: true)
        let vc = Utilities.viewController("RegisterViewController", onStoryboard: "Authentication") as! RegisterViewController
        vc.registerStatus = "login"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func registerTapped(_ sender: Any) {
        let vc = Utilities.viewController("RegisterViewController", onStoryboard: "Authentication") as! RegisterViewController
        vc.registerStatus = "select"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func connectToFbAndgetFriends()
    {
        print(FBSDK_TARGET_PLATFORM_VERSION)
        
        if (FBSDKAccessToken.current() != nil)
        {
            let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"id,interested_in,gender,birthday,email,age_range,name, first_name, last_name, picture.width(480).height(480)"])
            
            self.btnFacebook.showLoading()
            
            graphRequest.start(completionHandler: { (connection, result, error) -> Void in
                
                self.btnFacebook.hideLoading()

                if ((error) != nil){
                    print("Error: \(error!)")
                    self.showAlert(title: appName, message: (error?.localizedDescription)!)
                }else{
                    DELEGATE.goHomePage(transition: true)
                }
            })
        }else{
            let fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
            
            self.btnFacebook.showLoading()
            
            fbLoginManager.logIn(withReadPermissions: ["email", "public_profile", "user_friends"], from: self, handler: { (result, error) -> Void in
                
                self.btnFacebook.hideLoading()
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
                            self.fbSignIn()
                        }
                    }
                }else{
                    self.showAlert(title: appName, message: (error?.localizedDescription)!)
                    print("Error : \(error.debugDescription)")
                }
            })
        }
    }

    
    func tapFacebook(sender: UITapGestureRecognizer){
        continueFacebook()
    }
    
    func tapGoogle(sender: UITapGestureRecognizer){
        continueGoogle()
    }
    
    func continueFacebook() {
        connectToFbAndgetFriends()
    }
    
    func continueGoogle() {
        btnGoogle.showLoading()
        self.googleAuth()
    }
    
    /** This method start google auth using GoogleSDK */
    func googleAuth() {
        
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().disconnect()
        GIDSignIn.sharedInstance().signOut()
        GIDSignIn.sharedInstance().signIn()
    }

    @IBAction func onFacebook(_ sender: Any) {
        continueFacebook()
    }
    
    @IBAction func onGoogle(_ sender: Any) {
        continueGoogle()
    }
    
    @IBAction func onTerms(_ sender: Any) {
        let vc = Utilities.viewController("TermsViewController", onStoryboard: "Settings") as! TermsViewController
        vc.type = "terms"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func onPrivacy(_ sender: Any) {
        let vc = Utilities.viewController("TermsViewController", onStoryboard: "Settings") as! TermsViewController
        vc.type = "privacy"
        self.navigationController?.pushViewController(vc, animated: true)
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
