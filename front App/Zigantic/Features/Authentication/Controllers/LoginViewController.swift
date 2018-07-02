//
//  LoginViewController.swift
//  Bityo
//
//  Created by Chirag Ganatra on 28/11/17.
//  Copyright © 2017 Chirag Ganatra. All rights reserved.
//

import UIKit
import Foundation
import FBSDKCoreKit
import FBSDKLoginKit
import FBSDKShareKit
import SwiftyJSON
import FirebaseAuth
import JDStatusBarNotification

class LoginViewController: UIViewController {

    @IBOutlet weak var googleSigninButton: GIDSignInButton!
    @IBOutlet weak var txtEnterPwd: UITextField!
    @IBOutlet weak var txtEnterEmail: UITextField!
    @IBOutlet weak var lblOr: SpringLabel!
    @IBOutlet weak var imgLogo: SpringImageView!
    @IBOutlet weak var btnLogin: SpringButton!
    @IBOutlet weak var btnConnectFB: SpringButton!
    @IBOutlet weak var btnConnectGoogle: SpringButton!
    
    let validator = Validator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        statusBar?.backgroundColor = .white
        validator.registerField(textField: self.txtEnterEmail, rules: [RequiredRule(), EmailRule()])
        validator.registerField(textField: self.txtEnterPwd, rules: [RequiredRule(), PasswordRule()])
        self.txtEnterEmail.tag = 1001
        self.txtEnterPwd.tag = 1002
        self.googleSigninButton.backgroundColor = .clear
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        ShowAnimation()
    }
    
    func signIn() {
        if (FSUserManager.sharedInstance.user == nil) {
            FSUserManager.sharedInstance.user = FSUser()
        }
        FSUserManager.sharedInstance.user?.email = self.txtEnterEmail.text!
        FSUserManager.sharedInstance.user?.password = self.txtEnterPwd.text!

        FSUserManager.sharedInstance.signIn(completion: {(user: FSUser) -> Void in
            FSUserManager.sharedInstance.save()
            DELEGATE.goHomePage(transition: true)
        },
            failure: {(error: String) -> Void in
                JDStatusBarNotification.show(withStatus: error, dismissAfter: 3.0, styleName: JDStatusBarStyleError)
        })
    }
    

    func ShowAnimation()
    {
        
        self.imgLogo.animation = "squeezeDown"
        self.imgLogo.duration = 1.0
        self.imgLogo.delay = 0.3;
        self.imgLogo.damping = 0.8
        self.imgLogo.animate()
        
        self.btnConnectFB.animation = "squeezeUp"
        self.btnConnectFB.duration = 1.0
        self.btnConnectFB.delay = 0.3;
        self.btnConnectFB.damping = 0.8
        self.btnConnectFB.animate()
        
        self.lblOr.animation = "squeezeUp"
        self.lblOr.duration = 1.0
        self.lblOr.delay = 0.3;
        self.lblOr.damping = 0.8
        self.lblOr.animate()

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
    
    @IBAction func loginWithGoogleTapped(_ sender: Any) {
    }
    
    
    @IBAction func loginWithFBTapped(_ sender: Any) {
    }
    
    @IBAction func loginTapped(_ sender: Any) {
        self.view.endEditing(true)
        var cnt = 2000
        var error : String = ""
        
        self.validator.validate { (errors) in
            for (textField, vError) in errors
            {
                if textField.tag < cnt
                {
                    cnt = textField.tag
                    let errorDescription = vError.errorMessage.replacingOccurrences(of:"{INPUT_FIELD}", with: (textField.placeholder!).lowercased())
                    error = errorDescription.uppercaseFirst
                }
            }
            if errors.count > 0
            {
                JDStatusBarNotification.show(withStatus: error, dismissAfter: 3.0, styleName: JDStatusBarStyleError)
            }
            else
            {
                self.signIn()
            }
        }
    }
    
    @IBAction func backTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
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
