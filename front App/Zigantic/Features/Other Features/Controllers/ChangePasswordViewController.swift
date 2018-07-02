//
//  ChangePasswordViewController.swift
//  Bityo
//
//  Created by Chirag Ganatra on 29/11/17.
//  Copyright © 2017 Chirag Ganatra. All rights reserved.
//

import UIKit
import JDStatusBarNotification

class ChangePasswordViewController: UIViewController {

    @IBOutlet weak var txtOldPwd: UITextField!
    @IBOutlet weak var txtNewPwd: UITextField!
    @IBOutlet weak var txtCoonfirmPwd: UITextField!
    
    let validator  = Validator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        validator.registerField(textField: self.txtOldPwd, rules: [RequiredRule(), PasswordRule()])
        validator.registerField(textField: self.txtNewPwd, rules: [RequiredRule(), PasswordRule()])
        validator.registerField(textField: self.txtCoonfirmPwd, rules: [RequiredRule(), PasswordRule()])
        
        txtOldPwd.attributedPlaceholder = NSAttributedString(string: "Enter old password",
                                                               attributes: [NSAttributedStringKey.foregroundColor: placeHolderColor])
        txtNewPwd.attributedPlaceholder = NSAttributedString(string: "Enter new password",
                                                             attributes: [NSAttributedStringKey.foregroundColor: placeHolderColor])
        txtCoonfirmPwd.attributedPlaceholder = NSAttributedString(string: "Confirm password",
                                                             attributes: [NSAttributedStringKey.foregroundColor: placeHolderColor])
        
        self.txtOldPwd.tag = 1001
        self.txtNewPwd.tag = 1002
        self.txtCoonfirmPwd.tag = 1003

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func validatePwds() -> Bool{
        
        if txtNewPwd.text! != txtCoonfirmPwd.text! {
            JDStatusBarNotification.show(withStatus: "Your password and confirmation password do not match.", dismissAfter: 3.0, styleName: JDStatusBarStyleError)
            return false
        }
        return true
    }

    @IBAction func updateTapped(_ sender: Any) {
        
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
                if validatePwds(){
                    
                    FSUserManager.sharedInstance.changePassword(txtOldPwd.text!, txtNewPwd.text!,
                          completion: {(user: FSUser) -> Void in
                            self.navigationController?.popViewController(animated: true)
                            
                    },
                          failure: {(error: String) -> Void in
                            JDStatusBarNotification.show(withStatus:error, dismissAfter: 3.0, styleName: JDStatusBarStyleError)
                    })
                    
                }
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
