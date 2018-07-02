//
//  EditProfileViewController.swift
//  Bityo
//
//  Created by Chirag Ganatra on 29/11/17.
//  Copyright © 2017 Chirag Ganatra. All rights reserved.
//

import UIKit
import JDStatusBarNotification
import GooglePlaces

class EditProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, GMSAutocompleteViewControllerDelegate {

    @IBOutlet weak var imgProfile: FSImageView!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtFullName: UITextField!
    @IBOutlet weak var txtSchool: UITextField!
    @IBOutlet weak var txtGrade: UITextField!
    
    @IBOutlet weak var txtPaypal: UITextField!
    @IBOutlet weak var paypalView: UIView!    
    @IBOutlet weak var btnDelete: UIButton!
    
    @IBOutlet weak var lblSchool: UILabel!
    @IBOutlet weak var locationView: UIView!
    
    @IBOutlet weak var btnPwd: UIButton!
    @IBOutlet weak var btnUpdate: UIButton!
    @IBOutlet weak var lblTitle: UILabel!
    
    
    
//    @IBOutlet weak var txtPhone: UITextField!
//    @IBOutlet weak var btnLocation: UIButton!
    
    var user:FSUser?
    var avatarChanged: Bool?

    var imagePicker = UIImagePickerController()
    let validator = Validator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.validator.registerField(textField: self.txtFullName, rules: [RequiredRule()])
        imagePicker.delegate = self
        if user == nil {
            user = FSUserManager.sharedInstance.user
        }
        self.avatarChanged = false

        // Do any additional setup after loading the view.
        initUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if user == nil {
            user = FSUserManager.sharedInstance.user
        }
        
        if FSUserManager.sharedInstance.user?.type == "admin" {
            self.btnDelete.isHidden = false
        }
        else {
            self.btnDelete.isHidden = true
        }
        
        if user?.type == "develop" {
            self.lblSchool.text = "Business"
            self.locationView.isHidden = true
            self.paypalView.isHidden = true
        }
        else {
            self.lblSchool.text = "School"
            self.locationView.isHidden = false
            self.paypalView.isHidden = false
        }
        
        if user?.uid == FSUserManager.sharedInstance.user?.uid {
            self.lblTitle.text = "My Account"
            txtEmail.isEnabled = true
            txtFullName.isEnabled = true
            txtSchool.isEnabled = true
            txtGrade.isEnabled = true
            btnUpdate.isHidden = false
            btnPwd.isEnabled = true
        }
        else {
            self.lblTitle.text = "Account Info"
            txtEmail.isEnabled = false
            txtFullName.isEnabled = false
            txtSchool.isEnabled = false
            txtGrade.isEnabled = false
            btnUpdate.isHidden = true
            btnPwd.isEnabled = false
        }
        
        if (self.avatarChanged == true){
            self.imgProfile.showLoading()
            DispatchQueue.global().async {
                do {
                    FSUserManager.sharedInstance.uploadAvatar(
                        completion: {() in
                            DispatchQueue.main.async(execute: {() -> Void in
                                self.imgProfile.hideLoading()
                                self.avatarChanged = false
                                self.imgProfile.image = FSUserManager.sharedInstance.user?.avatarImage
                            })
                    },
                        failure: {(errorComment: String) -> Void in
                            DispatchQueue.main.async(execute: {() -> Void in
                                self.imgProfile.hideLoading()
                                self.avatarChanged = false
                                JDStatusBarNotification.show(withStatus: errorComment, dismissAfter: 3.0, styleName: JDStatusBarStyleError)
                            })
                    })
                } catch {
                    self.avatarChanged = false
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initUI() {
        txtFullName.text = user?.username
        txtEmail.text = user?.email
        txtSchool.text = user?.school
        if user?.grade != nil {
            txtGrade.text = String((user?.grade)!)
        }
        
        if user?.paypalname != nil {
            txtPaypal.text = user?.paypalname
        }
        
        if ((user?.avatarImage) != nil)
        {
            imgProfile.image = user?.avatarImage
        }
        else {
            if (user?.imgUrl != nil)
            {
                imgProfile.showLoading()
                Utilities.downloadImage(url: (user?.imgUrl)!, completion: {(avatarImage) in
                    self.imgProfile.hideLoading()
                    FSUserManager.sharedInstance.user?.avatarImage = avatarImage
                    self.imgProfile.image = avatarImage
                },
                    failure: {(errorComment: String) -> Void in
                        self.imgProfile.hideLoading()
                })
            }
            else {
                self.imgProfile.image = UIImage(named: "user_default")
            }
        }
    }
    
    @IBAction func onRemove(_ sender: Any) {
        let menuController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let removeAction = UIAlertAction(title: "Remove this user", style: .destructive) { (action) in
            // remove user
            FSUserManager.sharedInstance.removeUserByAdmin(self.user!, completion: {
                self.navigationController?.popViewController(animated: false)
            }, failure: { (error) in
            })
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        menuController.addAction(cancelAction)
        menuController.addAction(removeAction)
        self.present(menuController, animated: true)
    }
    
    //MARK: - Show Camera -
    func showCam(sender : UIButton)
    {
        guard let viewRect = sender as? UIView else {
            return
        }
        let actionSheetController: UIAlertController = UIAlertController(title: "Please select", message: "", preferredStyle: .actionSheet)
        
        let cancelActionButton = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            print("Cancel")
        }
        actionSheetController.addAction(cancelActionButton)
        
        let saveActionButton = UIAlertAction(title: "Gallery", style: .default)
        { _ in
            
            if UIImagePickerController .isSourceTypeAvailable(.photoLibrary) {
                self.imagePicker.allowsEditing = true
                self.imagePicker.sourceType = .photoLibrary
                self .present(self.imagePicker, animated: true, completion: nil)
                
            } else {
                let NocamAvailalble = "Gallery is not available in your device!"
                self.showAlert(title: appName, message: NocamAvailalble)
            }
        }
        actionSheetController.addAction(saveActionButton)
        
        let deleteActionButton = UIAlertAction(title: "Camera", style: .default)
        { _ in
            
            if UIImagePickerController .isSourceTypeAvailable(.camera) {
                self.imagePicker.allowsEditing = true
                self.imagePicker.sourceType = .camera
                self .present(self.imagePicker, animated: true, completion: nil)
            } else {
                let NocamAvailalble = "Camera not available in your device!"
                self.showAlert(title: appName, message: NocamAvailalble)
            }
            
        }
        actionSheetController.addAction(deleteActionButton)
        
        if let presenter = actionSheetController.popoverPresentationController {
            presenter.sourceView = viewRect;
            presenter.sourceRect = viewRect.bounds;
        }
        self.present(actionSheetController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if (info[UIImagePickerControllerOriginalImage] as? UIImage) != nil {
            
            imgProfile.image = info[UIImagePickerControllerOriginalImage] as? UIImage
            // Set photoImageView to display the selected image.
            FSUserManager.sharedInstance.user?.avatarImage = Utilities.resizeImage(imgProfile.image!)
            self.avatarChanged = true
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func profileTapped(_ sender: UIButton) {
        showCam(sender : sender)
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
                FSUserManager.sharedInstance.user?.username = txtFullName.text!
                FSUserManager.sharedInstance.user?.email = txtEmail.text!
                if (txtSchool.text != nil && txtSchool.text != "") {
                    FSUserManager.sharedInstance.user?.school = txtSchool.text!
                }
                if (txtGrade.text != nil && txtGrade.text != "") {
                    FSUserManager.sharedInstance.user?.grade = Int(txtGrade.text!)!
                }
                
                FSUserManager.sharedInstance.updatePersonalnfo()

                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    @IBAction func backTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func changePassworTapped(_ sender: Any) {
        let vc = Utilities.viewController("ChangePasswordViewController", onStoryboard: "Settings")
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        // Print place info to the console.
        print("Place name: \(place.name)")
        print("Place address: \(place.formattedAddress)")
        print("Place attributions: \(place.attributions)")
        user?.address = place.formattedAddress!
        user?.lat = Float(place.coordinate.latitude)
        user?.lng = Float(place.coordinate.longitude)
//        btnLocation.setTitle(user?.address, for: .normal)
        
        // TODO: Add code to get address components from the selected place.
        
        // Close the autocomplete widget.
        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        
    }
    
    @IBAction func locationTapped(_ sender: Any) {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        
        // Set a filter to return only addresses.
        let filter = GMSAutocompleteFilter()
        filter.type = .address
        autocompleteController.autocompleteFilter = filter
        
        present(autocompleteController, animated: true, completion: nil)
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
