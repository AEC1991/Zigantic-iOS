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

class CodeVerificationController: UIViewController, UITextFieldDelegate {

    @IBOutlet var codeTextFields: [UITextField]!
    @IBOutlet weak var codeSendButton: FSLoadingButton!
    @IBOutlet weak var resendButton: UIButton!
    @IBOutlet weak var lblPhone: UILabel!
    
    @IBOutlet weak var headerTopConstraint: NSLayoutConstraint!
    var phone:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (UIScreen.main.nativeBounds.height == 2436) {
            headerTopConstraint.constant = -44.0
        }
        else {
            headerTopConstraint.constant = -20.0
        }
        let ressendAttributes : [NSAttributedStringKey: Any] = [
            NSAttributedStringKey.font : UIFont(name: "AvenirLTStd-Book", size: 15),
            NSAttributedStringKey.foregroundColor : themeOrangeColor,
            NSAttributedStringKey.underlineStyle : NSUnderlineStyle.styleSingle.rawValue]
        
        let resendString = NSMutableAttributedString(string: "Resend",
                                                    attributes: ressendAttributes)
        
        resendButton.setAttributedTitle(resendString, for: .normal)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        if (phone != nil && phone != "") {
            lblPhone.text = phone
        }
    }
    
    @IBAction func onBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func enteredCodeCharacter(_ sender: UITextField) {
        // update field UI
        let filled = !(sender.text?.isEmpty ?? true)
        UIView.animate(withDuration: 0.3) {
            sender.backgroundColor = filled ? themeOrangeColor : .clear
        }
        
        // update the verify button
        let allFilled = !codeTextFields.contains { ($0.text?.isEmpty ?? true) }
        UIView.animate(withDuration: 0.3) { [unowned self] in
            self.codeSendButton.isEnabled = allFilled
            self.codeSendButton.backgroundColor = allFilled ? themeOrangeColor : .lightGray
        }
        
        // transfer responder to next field
        sender.resignFirstResponder()
        codeTextFields.first { $0.text?.isEmpty ?? true }?.becomeFirstResponder()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let newLength = text.characters.count + string.characters.count - range.length
        return newLength < 2
    }

    @IBAction func onVerify(_ sender: Any) {
        let verificationID = UserDefaults.standard.string(forKey: "authVerificationID")
        let code = codeTextFields.reduce("") { $0 + ($1.text ?? "") }
        
        let credential = PhoneAuthProvider.provider().credential(
            withVerificationID: verificationID!,
            verificationCode: code)
        
        Auth.auth().signIn(with: credential) { (user, error) in
            if let error = error {
                self.showAlert(title: appName, message: error.localizedDescription)
                return
            }
            
            // User is signed in
            FSUserManager.sharedInstance.verifiedWith(inType: "Phone", content: self.phone!,
                  completion: { (outuser) in
                        DELEGATE.goHomePage(transition: true)
            },
                  failure: {(error) in
                    self.showAlert(title: appName, message: error)
            })
        }
    }
    
    @IBAction func onResend(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

