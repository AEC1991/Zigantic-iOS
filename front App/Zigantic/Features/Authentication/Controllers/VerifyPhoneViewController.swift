//
//  VerifyPhoneViewController.swift
//  Bityo
//
//  Created by iOS Developer on 1/17/18.
//  Copyright © 2018 Chirag Ganatra. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth

class VerifyPhoneViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var btnSend: FSLoadingButton!
    @IBOutlet weak var headerTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var txtMobile: UITextField!
    var phone:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (UIScreen.main.nativeBounds.height == 2436) {
            headerTopConstraint.constant = -44.0
        }
        else {
            headerTopConstraint.constant = -20.0
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if (self.phone != nil && self.phone != "") {
            self.txtMobile.text = self.phone
        }
    }
    
    @IBAction func onBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        guard let text = textField.text else { return true }
        if (textField == txtMobile) {
            let newLength = text.characters.count + string.characters.count - range.length
            return newLength <= kMaxPhoneLength + 1
        }
        else {
            return true
        }
    }
    
    @IBAction func onSendCode(_ sender: Any) {
        if (txtMobile.text == nil || txtMobile.text == "") {
            self.showAlert(title: appName, message: FSMessage.INPUT_PHONE)
            return
        }
        
        if (txtMobile.text?.contains("+") == false) {
            txtMobile.text = "+" + txtMobile.text!
        }
        
        btnSend.showLoading()
        PhoneAuthProvider.provider().verifyPhoneNumber(txtMobile.text!, uiDelegate: nil) { (verificationID, error) in
            self.btnSend.hideLoading()
            
            if let error = error {
                self.showAlert(title: appName, message: error.localizedDescription)
                return
            }
            // Sign in using the verificationID and the code sent to the user
            UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
            let vc = Utilities.viewController("CodeVerificationController", onStoryboard: "Authentication") as! CodeVerificationController
            vc.phone = self.phone
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
