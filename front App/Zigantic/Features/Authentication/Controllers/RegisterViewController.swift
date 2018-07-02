//
//  RegisterViewController.swift
//  Bityo
//
//  Created by Chirag Ganatra on 28/11/17.
//  Copyright © 2017 Chirag Ganatra. All rights reserved.
//

import UIKit
import JDStatusBarNotification

class RegisterViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var avatarView: UIView!
    @IBOutlet weak var logoImgView: UIImageView!
    @IBOutlet weak var loginView: UIView!
    @IBOutlet weak var usernameView: UIView!
    
    @IBOutlet weak var paypalView: UIView!
    
    @IBOutlet weak var fullnameView: UIView!
    @IBOutlet weak var phoneView: UIView!
    @IBOutlet weak var emailView: UIView!
    @IBOutlet weak var passwordView: UIView!
    @IBOutlet weak var confirmPasswordView: UIView!
    
    @IBOutlet weak var lblSchool: UILabel!
    @IBOutlet weak var lblGrade: UILabel!
    
    @IBOutlet weak var txtConfirmPassword: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPaypal: UITextField!
    @IBOutlet weak var txtUserName: UITextField!
    @IBOutlet weak var txtSchool: UITextField!
    @IBOutlet weak var txtGrade: UITextField!
    
    @IBOutlet weak var txtEmailLogin: UITextField!
    @IBOutlet weak var txtPasswordLogin: UITextField!
    @IBOutlet weak var btnLogIn: UIButton!
    @IBOutlet weak var btnHelp: UIButton!
    
    @IBOutlet weak var countryView: UIView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    @IBOutlet weak var avatarImgView: FSImageView!
    @IBOutlet weak var btnAgree: UIButton!
    @IBOutlet weak var lblAgree: UILabel!
    @IBOutlet weak var btnSignup: FSLoadingButton!
    
    @IBOutlet weak var lblHaveAccount: UILabel!
    @IBOutlet weak var btnSwitchLogin: UIButton!
    
    @IBOutlet weak var backView: UIView!
    
    @IBOutlet weak var userTypeView: UIView!
    @IBOutlet weak var btnSurvey: FSLoadingButton!
    @IBOutlet weak var btnDeveloper: FSLoadingButton!
    
    @IBOutlet weak var lblYearNote: UILabel!
    
    @IBOutlet weak var backgroundTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var agreeBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var paypalBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var schoolTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var emailTopConstraint: NSLayoutConstraint!
    
    let validator  = Validator()
    var user:FSUser?
    var agreeTerms:Bool = false
    var registerStatus:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (user == nil) {
            user = FSUser()
        }

        if (UIScreen.main.nativeBounds.height == 2436) {
            backgroundTopConstraint.constant = -44.0
        }
        else {
            backgroundTopConstraint.constant = -20.0
        }
        avatarImgView.makeCircular()
        btnAgree.isSelected = false
        btnSignup.isEnabled = btnAgree.isSelected
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.hideKeyboard))
        self.view.addGestureRecognizer(tapGesture)
        
        let tapBackGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapBack))
        backView.addGestureRecognizer(tapBackGesture)
        
        lblAgree.textColor = placeHolderColor
        let bundle = "assets.bundle/"
        
        let logAttributes : [NSAttributedStringKey: Any] = [
            NSAttributedStringKey.font : UIFont(name: "AvenirLTStd-Book", size: 17),
            NSAttributedStringKey.foregroundColor : UIColor.white,
            NSAttributedStringKey.underlineStyle : NSUnderlineStyle.styleSingle.rawValue]
        let helpAttributes : [NSAttributedStringKey: Any] = [
            NSAttributedStringKey.font : UIFont(name: "AvenirLTStd-Book", size: 13),
            NSAttributedStringKey.foregroundColor : UIColor.white,
            NSAttributedStringKey.underlineStyle : NSUnderlineStyle.styleSingle.rawValue]

        let loginString = NSMutableAttributedString(string: "Log in",
                                                        attributes: logAttributes)
        let helpString = NSMutableAttributedString(string: "Get Help",
                                                    attributes: helpAttributes)

        btnSwitchLogin.setAttributedTitle(loginString, for: .normal)
        btnHelp.setAttributedTitle(helpString, for: .normal)
        
        txtSchool.attributedPlaceholder = NSAttributedString(string: "Enter school",
                                                               attributes: [NSAttributedStringKey.foregroundColor: placeHolderColor])
        txtUserName.attributedPlaceholder = NSAttributedString(string: "Enter username",
                                                           attributes: [NSAttributedStringKey.foregroundColor: placeHolderColor])
        txtPaypal.attributedPlaceholder = NSAttributedString(string: "Enter paypal username",
                                                               attributes: [NSAttributedStringKey.foregroundColor: placeHolderColor])
        txtEmail.attributedPlaceholder = NSAttributedString(string: "Enter email",
                                                            attributes: [NSAttributedStringKey.foregroundColor: placeHolderColor])
        txtEmailLogin.attributedPlaceholder = NSAttributedString(string: "Enter email",
                                                            attributes: [NSAttributedStringKey.foregroundColor: placeHolderColor])
        txtPassword.attributedPlaceholder = NSAttributedString(string: "Enter password",
                                                            attributes: [NSAttributedStringKey.foregroundColor: placeHolderColor])
        txtPasswordLogin.attributedPlaceholder = NSAttributedString(string: "Enter password",
                                                               attributes: [NSAttributedStringKey.foregroundColor: placeHolderColor])
        txtConfirmPassword.attributedPlaceholder = NSAttributedString(string: "Confirm password",
                                                            attributes: [NSAttributedStringKey.foregroundColor: placeHolderColor])


        self.segmentedControl.layer.cornerRadius = 15.0;
        self.segmentedControl.layer.masksToBounds = true;
        self.segmentedControl.layer.borderColor = placeHolderColor.cgColor
        self.segmentedControl.layer.borderWidth = 1.0
        self.segmentedControl.tintColor = placeHolderColor
        let titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        segmentedControl.setTitleTextAttributes(titleTextAttributes, for: .selected)
        
        statusBar?.backgroundColor = .clear
        
        validator.registerField(textField: self.txtSchool, rules: [RequiredRule()])
        validator.registerField(textField: self.txtUserName, rules: [RequiredRule()])
        validator.registerField(textField: self.txtEmail, rules: [RequiredRule(),EmailRule()])
        validator.registerField(textField: self.txtEmailLogin, rules: [RequiredRule(),EmailRule()])
        validator.registerField(textField: self.txtPassword, rules: [RequiredRule(), PasswordRule()])
        validator.registerField(textField: self.txtPasswordLogin, rules: [RequiredRule(), PasswordRule()])
        validator.registerField(textField: self.txtConfirmPassword, rules: [RequiredRule(), PasswordRule()])

        self.txtUserName.tag = 1001
        self.txtSchool.tag = 1002
        self.txtEmail.tag = 1004
        self.txtPassword.tag = 1005
        self.txtConfirmPassword.tag = 1006
        self.txtEmailLogin.tag = 2001
        self.txtPasswordLogin.tag = 2002

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        switchUI()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        // Try to find next responder
        if let nextField = self.view.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            // Not found, so remove keyboard.
            textField.resignFirstResponder()
        }
        // Do not add a line break
        return false
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let newLength = text.characters.count + string.characters.count - range.length
        if textField == txtGrade {
            return newLength <= 2
        }
        else {
            return true
        }
    }
    
    @IBAction func gradeEditEnded(_ sender: Any) {
        setYearNote()
    }
    
    @IBAction func gradeChanged(_ sender: Any) {
    }
    
    func setYearNote() {
        if txtGrade.text != nil && txtGrade.text != "" {
            let curYear:Int = Int(txtGrade.text!)!
            
            switch curYear {
            case 1:
                lblYearNote.text = "st Year"
                break
            case 2:
                lblYearNote.text = "nd Year"
                break
            case 3:
                lblYearNote.text = "rd Year"
                break
            default:
                lblYearNote.text = "th Year"
                break
            }
        }
    }
    
    func validatePwds() -> Bool{
        
        if txtPassword.text! != txtConfirmPassword.text! {
            
            JDStatusBarNotification.show(withStatus: "Your password and confirmation password do not match.", dismissAfter: 3.0, styleName: JDStatusBarStyleError)
            return false
        }
        return true
    }
    
    func signIn() {
        if (FSUserManager.sharedInstance.user == nil) {
            FSUserManager.sharedInstance.user = FSUser()
        }
        FSUserManager.sharedInstance.user?.email = self.txtEmailLogin.text!
        FSUserManager.sharedInstance.user?.password = self.txtPasswordLogin.text!
        
        btnLogIn.showLoading()
        FSUserManager.sharedInstance.signIn(completion: {(user: FSUser) -> Void in
            self.btnLogIn.hideLoading()
            FSUserManager.sharedInstance.save()
            DELEGATE.goHomePage(transition: true)
        },
            failure: {(error: String) -> Void in
                self.btnLogIn.hideLoading()
                JDStatusBarNotification.show(withStatus: error, dismissAfter: 3.0, styleName: JDStatusBarStyleError)
        })
    }
    
    @IBAction func onTakePhoto(_ sender: Any) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let chooseAction = UIAlertAction(title: "Choose New Photo", style: .default){(action) in
            self.pickFromAlbum()
        }
        let takeAction = UIAlertAction(title: "Take New Photo", style: .default){(action) in
            self.pickFromCamera()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        
        alertController.addAction(chooseAction)
        alertController.addAction(takeAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onSurvey(_ sender: Any) {
        user!.type = "survey"
        self.registerStatus = "signup"
        switchUI()
    }
    
    @IBAction func onDevelop(_ sender: Any) {
        user!.type = "develop"
        self.registerStatus = "signup"
        switchUI()
    }
    
    func checkPhoneVerify() {
        let alertController = UIAlertController(title: "Confirm", message: FSMessage.VERIFY_PHONE, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Do it Now.", style: UIAlertActionStyle.default){(action) in
            let vc = Utilities.viewController("VerifyPhoneViewController", onStoryboard: "Authentication") as! VerifyPhoneViewController
            vc.phone = self.user?.phone
            self.navigationController?.pushViewController(vc, animated: true)
        }
        let cancelAction = UIAlertAction(title: "No Thanks.", style: UIAlertActionStyle.cancel){(action) in
            DELEGATE.goHomePage(transition: true)
        }
        
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func onSignUp() {

        user?.username = self.txtUserName.text!
        user?.email = self.txtEmail.text!
        user?.password = self.txtPassword.text!
        user?.school = self.txtSchool.text!
        user?.grade = Int(self.txtGrade.text!)!
        if (user?.type == "survey" && self.txtPaypal.text != nil) {
            user?.paypalname = self.txtPaypal.text!
        }
        
        FSUserManager.sharedInstance.user = self.user

        btnSignup.showLoading()
        FSUserManager.sharedInstance.signUp(completion: {(user: FSUser) -> Void in
            self.btnSignup.hideLoading()

            FSUserManager.sharedInstance.save()
            if (self.user?.phone != nil && self.user?.phone != "") {
                self.checkPhoneVerify()
            }
            else {
                DELEGATE.goHomePage(transition: true)
            }
        },
        failure: {(error: String) -> Void in
            self.btnSignup.hideLoading()
            self.showAlert(title: appName, message: error)
        })
    }
    
    @IBAction func pickTapped(_ sender: Any) {
        self.txtSchool.resignFirstResponder()
    }
    
    func switchUI() {
        if (self.registerStatus == "login") {
            loginView.isHidden = false
            btnSignup.isHidden = true
            lblHaveAccount.isHidden = true
            btnSwitchLogin.isHidden = true
            scrollView.isHidden = true
            userTypeView.isHidden = true
            segmentedControl.selectedSegmentIndex = 0
        }
        else if (self.registerStatus == "select") {
            loginView.isHidden = true
            scrollView.isHidden = true
            userTypeView.isHidden = false
            lblHaveAccount.isHidden = false
            btnSignup.isHidden = true
            lblHaveAccount.isHidden = true
            btnSwitchLogin.isHidden = true
            segmentedControl.selectedSegmentIndex = 1
        }
        else {
            loginView.isHidden = true
            btnSignup.isHidden = false
            lblHaveAccount.isHidden = false
            btnSwitchLogin.isHidden = false
            scrollView.isHidden = false
            userTypeView.isHidden = true
            segmentedControl.selectedSegmentIndex = 1
            if user?.type == "develop" {
                self.lblSchool.text = "Business"
                self.phoneView.isHidden = true
                self.paypalView.isHidden = true
                self.emailTopConstraint.constant = -53.0
                self.schoolTopConstraint.constant = -53.0
                txtSchool.attributedPlaceholder = NSAttributedString(string: "Enter business",
                                                                     attributes: [NSAttributedStringKey.foregroundColor: placeHolderColor])
            }
            else {
                self.lblSchool.text = "School"
                self.phoneView.isHidden = false
                self.paypalView.isHidden = false
                self.emailTopConstraint.constant = 9.0
                self.schoolTopConstraint.constant = 10.0
                txtSchool.attributedPlaceholder = NSAttributedString(string: "Enter school",
                                                                     attributes: [NSAttributedStringKey.foregroundColor: placeHolderColor])
            }
        }
    }
    
    @IBAction func switchLogin(_ sender: Any) {
        registerStatus = "login"
        switchUI()
    }
    
    @IBAction func onSwitch(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            self.registerStatus = "login"
        }
        else {
            self.registerStatus = "signup"
        }
        switchUI()
    }
    
    func openCountryPicker() {
        let picker = MICountryPicker { (name, code) -> () in
            print(code)
        }
        
        // delegate
        picker.delegate = self
        
        // or closure
        picker.didSelectCountryClosure = { name, code in
//            picker.navigationController?.popViewController(animated: true)
            print(code)
        }
        navigationController?.pushViewController(picker, animated: true)
    }
    
    @objc func hideKeyboard() {
        self.view.endEditing(true)
    }

    
    @IBAction func loginTapped(_ sender: Any) {
        var cnt = 2000
        var error : String = ""
        
        self.validator.validate { (errors) in
            for (textField, vError) in errors
            {
                if textField.tag > cnt
                {
                    cnt = textField.tag
                    let errorDescription = vError.errorMessage.replacingOccurrences(of:"{INPUT_FIELD}", with: (textField.placeholder!).lowercased())
                    error = errorDescription.uppercaseFirst
                }
            }
            if error != ""
            {
                JDStatusBarNotification.show(withStatus: error, dismissAfter: 3.0, styleName: JDStatusBarStyleError)
            }
            else
            {
                self.signIn()
            }
        }
    }
    
    @IBAction func registerTapped(_ sender: Any) {
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
            if error != ""
            {
                JDStatusBarNotification.show(withStatus: error, dismissAfter: 3.0, styleName: JDStatusBarStyleError)
            }
            else
            {
                if validatePwds()
                {
                    self.onSignUp()
                }
            }
        }
    }
    
    func tapBack(sender: UITapGestureRecognizer){
        if registerStatus == "signup" {
            registerStatus = "select"
            switchUI()
        }
        else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func backTapped(_ sender: Any) {
        if registerStatus == "signup" {
            registerStatus = "select"
            switchUI()
        }
        else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func tapCountryView(sender: UITapGestureRecognizer){
        openCountryPicker()
    }
    
    @IBAction func onAgree(_ sender: Any) {
        btnAgree.isSelected = !btnAgree.isSelected
        agreeTerms = btnAgree.isSelected
        btnSignup.isEnabled = btnAgree.isSelected
    }
    
    @IBAction func onHelp(_ sender: Any) {
        var error : String = ""

        self.validator.validate { (errors) in
            for (textField, vError) in errors
            {
                if textField.tag == self.txtEmailLogin.tag
                {
                    let errorDescription = vError.errorMessage.replacingOccurrences(of:"{INPUT_FIELD}", with: (textField.placeholder!).lowercased())
                    error = errorDescription.uppercaseFirst
                }
            }
            if error != ""
            {
                self.showAlert(title: appName, message: error)
            }
            else
            {
                FSUserManager.sharedInstance.sendPasswordResetEmail(email: self.txtEmailLogin.text!, completion: {(result: String) -> Void in
                    self.showAlert(title: appName, message: result)
                },
                    failure: {(error: String) -> Void in
                        self.showAlert(title: appName, message: error)
                })
            }
        }
    }
    
    
    func pickFromAlbum(){
        // UIImagePickerController is a view controller that lets a user pick media from their photo library.
        let imagePickerController = UIImagePickerController()
        
        // Only allow photos to be picked, not taken.
        imagePickerController.sourceType = .photoLibrary
        
        // Make sure ViewController is notified when the user picks an image.
        imagePickerController.delegate = self
        
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func pickFromCamera() {
        // UIImagePickerController is a view controller that lets a user pick media from their photo library.
        let imagePickerController = UIImagePickerController()
        
        // Only allow photos to be picked, not taken.
        imagePickerController.sourceType = .camera
        
        // Make sure ViewController is notified when the user picks an image.
        imagePickerController.delegate = self
        
        present(imagePickerController, animated: true, completion: nil)
    }

    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {
        // The info dictionary contains multiple representations of the image, and this uses the original.
        let selectedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        // Set photoImageView to display the selected image.
        user?.avatarImage = Utilities.resizeImage(selectedImage)
        avatarImgView.image = selectedImage
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // Dismiss the picker if the user canceled.
        dismiss(animated: true, completion: nil)
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

extension RegisterViewController: MICountryPickerDelegate {
    func countryPicker(_ picker: MICountryPicker, didSelectCountryWithName name: String, code: String, flag: UIImage) {
        picker.navigationController?.popViewController(animated: true)
//        txtCountry.text = code
    }
}

