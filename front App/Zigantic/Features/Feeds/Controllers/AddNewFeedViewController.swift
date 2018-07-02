
//
//  AddNewFeedViewController.swift
//  Bityo
//
//  Created by Chirag Ganatra on 30/11/17.
//  Copyright © 2017 Chirag Ganatra. All rights reserved.
//

import UIKit
import JDStatusBarNotification
import IQKeyboardManagerSwift
import AVFoundation
//import MobileCoreServices
import Firebase

protocol AddNewFeedViewControllerDelegate
{
    func productDeleted()
}

class AddNewFeedViewController: UIViewController {

    @IBOutlet weak var txtTitle: UITextField!
    @IBOutlet weak var txtLink: UITextView!
    @IBOutlet weak var btnVideo: UIButton!
    @IBOutlet weak var logoImgView: UIImageView!
    @IBOutlet weak var btnLogo: UIButton!
    @IBOutlet weak var lblGameVideo: UILabel!    
    @IBOutlet weak var questionCollection: UICollectionView!
    
    @IBOutlet weak var txtDescription: UITextView!
    @IBOutlet weak var uploadImgView: UIImageView!
    @IBOutlet weak var btnUpload: UIButton!
    @IBOutlet weak var lblUpload: UILabel!
    @IBOutlet weak var btnDown: FSLoadingButton!
    
    var cat = 0
    var isFrom = "feed"
    var product:FSProduct?
    var delegate: AddNewFeedViewControllerDelegate?
    var imagePicker = UIImagePickerController()
    
    var categoryList: [String] = []
    var subcategoryList: [String] = []
    
    let validator = Validator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        imagePicker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!

//        imagePicker.mediaTypes = [kUTTypeImage as String, kUTTypeVideo as String]
        imagePicker.delegate = self
        
        self.validator.registerField(textField: txtTitle, rules: [RequiredRule()])

        self.txtTitle.tag = 1001
        
        btnLogo.backgroundColor = .clear
        btnLogo.layer.masksToBounds = true
        btnLogo.layer.cornerRadius = 19
        btnLogo.layer.borderWidth = 1
        btnLogo.layer.borderColor = placeHolderColor.cgColor

        btnDown.setTitle("Submit", for:.normal)

        if isFrom == "edit"{
            showProductInfo()
        }else{
            if product == nil {
                product = FSProduct()
            }
        }
        // Do any additional setup after loading the view.
        txtTitle.attributedPlaceholder = NSAttributedString(string: "Input Game Name",
                                                             attributes: [NSAttributedStringKey.foregroundColor: placeHolderColor])
        
        let tapLogoGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapLogo))
        logoImgView.addGestureRecognizer(tapLogoGesture)
        let tapUploadGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapUploadImage))
        uploadImgView.addGestureRecognizer(tapUploadGesture)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.product?.uid == ""{
            product?.sellerId = (FSUserManager.sharedInstance.user?.uid)!
            FSProductManager.sharedInstance.product = product
        }
        IQKeyboardManager.sharedManager().enableAutoToolbar = true
        UIApplication.shared.statusBarStyle = .default
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        IQKeyboardManager.sharedManager().enableAutoToolbar = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tapLogo(sender: UITapGestureRecognizer){
        isFrom = "Logo"
        showCam()
    }

    func tapUploadImage(sender: UITapGestureRecognizer){
        isFrom = "Upload Image"
        showCam()
    }
    
    func showProductInfo() {
        txtTitle.text = product?.title
        txtDescription.text = product?.contentDescription
    }
    
    @IBAction func onSelectVideo(_ sender: Any) {
        isFrom = "Video"
        showCam()
    }
    
    @IBAction func nagotialteTapped(_ sender: UIButton) {
        self.view.endEditing(true)
        sender.isSelected = !sender.isSelected
    }
    
    @IBAction func onBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func deleteTapped(_ sender: Any) {
        self.showConfirm(msg:FSMessage.PRODUCT_DELETE, confirm:{() in
            FSProductManager.sharedInstance.removeProduct(self.product!,
                completion: {() in
                    self.navigationController?.popViewController(animated: true)
                    self.delegate?.productDeleted()
            },
                failure: {(errorComment: String) -> Void in
                    JDStatusBarNotification.show(withStatus: errorComment, dismissAfter: 3.0, styleName: JDStatusBarStyleError)
            })
        })
    }
    
    @IBAction func onSelectUploadImage(_ sender: Any) {
        isFrom = "Upload Image"
        showCam()
    }
    
    func showConfirm(msg:String?, confirm:@escaping (() -> ()))
    {
        let alertController = UIAlertController(title: "Confirm", message: msg, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "DELETE", style: UIAlertActionStyle.destructive){(action) in
            confirm()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func onInputLogo(_ sender: Any) {
        isFrom = "Logo"
        showCam()
    }

    @IBAction func showCategoryTapped(_ sender: Any) {
        self.view.endEditing(true)
        self.cat = 0
        
        self.categoryList = []
        FSCategoryManager.sharedInstance.getCategories(completion: {(outCategories: [String]) -> Void in
            self.categoryList = outCategories
            self.showPopUp()
        }
            , failure: { (errorComment) in
                self.showAlert(title: appName, message: errorComment)
        })
    }
    
    @IBAction func backTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func setGameInfo() {
        if (product == nil) {
            product = FSProduct()
        }
        product?.sellerId = (FSUserManager.sharedInstance.user?.uid)!
        
        product?.title = txtTitle.text!
        product?.contentDescription = txtDescription.text!
        product?.appLink = txtLink.text
        
        FSProductManager.sharedInstance.product = product
    }
    
    private func setQuestion() {
        for index in 0...9 {
            let indexPath = IndexPath(item: index, section: 0)
            let cell = questionCollection!.cellForItem(at: indexPath) as! QuestionCell
            let question = cell.txtQuestion.text as? String
            let answer = cell.txtAnswer.text as? String
            if question != nil && answer != nil {
                FSProductManager.sharedInstance.addQuestion(product!, question!, answer!)
            }
        }
    }
    
    @IBAction func sellPriceChange(_ sender: UITextField) {
        if sender.text == nil || sender.text == "" {
            return
        }
    }
    
    func showCam()
    {
        let actionSheetController: UIAlertController = UIAlertController(title: nil, message:nil, preferredStyle: .actionSheet)
        let cancelActionButton = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            print("Cancel")
        }
        actionSheetController.addAction(cancelActionButton)
        
        let saveActionButton = UIAlertAction(title: "Photo Gallery", style: .default)
        { _ in
            
            if UIImagePickerController .isSourceTypeAvailable(.photoLibrary) {
                self.imagePicker.allowsEditing = true
                self.imagePicker.sourceType = .photoLibrary
                self.present(self.imagePicker, animated: true, completion: nil)
                
            } else {
                let NocamAvailalble = "PhotoGallery not available in your device!"
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
        self.present(actionSheetController, animated: true, completion: nil)
    }
    
    func createProduct() {
        FSProductManager.sharedInstance.startUploadImg(withCompletion: {(_ error: String?) -> Void in
            
            FSProductManager.sharedInstance.createProduct(
                completion: { (product) in
                    self.btnDown.hideLoading()
                    self.setQuestion()
                    let vc = Utilities.viewController("AddPhotoViewController", onStoryboard: "Feeds") as! AddPhotoViewController
                    vc.isFrom = self.isFrom
                    
                    self.navigationController?.pushViewController(vc, animated: true)
            },
                failure: {(error) in
                    self.btnDown.hideLoading()
                    self.showAlert(title: appName, message: error)
            })
        })
    }

    @IBAction func nextTapped(_ sender: Any) {
        
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
            else if product?.images == nil {
                JDStatusBarNotification.show(withStatus: FSMessage.REQUEST_GAME_IMAGE, dismissAfter: 3.0, styleName: JDStatusBarStyleError)
            }
            else if txtLink.text == "" || txtLink.text == nil {
                JDStatusBarNotification.show(withStatus: FSMessage.REQUEST_GAME_LINK, dismissAfter: 3.0, styleName: JDStatusBarStyleError)
            }
            else if txtDescription.text == "" || txtDescription.text == nil {
                JDStatusBarNotification.show(withStatus: FSMessage.REQUEST_GAME_DESCRIPTION, dismissAfter: 3.0, styleName: JDStatusBarStyleError)
            }
            else
            {
                setGameInfo()
                self.btnDown.showLoading()
                createProduct()
            }
        }
    }
    
    @IBAction func closeTapped(_ sender: Any) {
        hidePopup()
    }
    
    func showPopUp(){
        
        UIView.animate(withDuration: 0.4, animations: {
            self.view.layoutIfNeeded()
        }) { (success) in
            
        }
    }
    
    func hidePopup(){
        
        UIView.animate(withDuration: 0.4, animations: {
            self.view.layoutIfNeeded()
        }) { (success) in
        }
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

extension AddNewFeedViewController : UICollectionViewDataSource, UICollectionViewDelegate{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "QuestionCell", for: indexPath) as! QuestionCell
        let question:String = "Game Application Question " + String(indexPath.row + 1)
        cell.txtQuestion.attributedPlaceholder = NSAttributedString(string: question,
                                                                    attributes: [NSAttributedStringKey.foregroundColor: UIColor.white])
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}

extension AddNewFeedViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let videoUrl = info[UIImagePickerControllerMediaURL] as? URL {
            handleVideoSelectedForUrl(url: videoUrl)
        }
        else {
            let chosenImage = info[UIImagePickerControllerEditedImage] as? UIImage
            if isFrom == "Upload Image" {
                self.uploadImgView.image = chosenImage
                self.lblUpload.isHidden = true
                self.btnUpload.isHidden = true
                if(product?.images == nil) {
                    product?.images = NSMutableArray()
                }
                product?.images?.add(chosenImage)
            }
            else if isFrom == "Logo" {
                self.logoImgView.image = chosenImage
                self.btnLogo.isHidden = true
                self.logoImgView.isHidden = false
                FSProductManager.sharedInstance.addLogoImage(chosenImage!, withCompletion: {(_ error: String?) -> Void in
                    if (error != nil) {
                        self.showAlert(title: appName, message: error!)
                    }
                    else {
                        self.product = FSProductManager.sharedInstance.product
                    }
                })
            }
        }
        dismiss(animated: true, completion: nil)
    }
    
    private func handleVideoSelectedForUrl(url:URL) {
        let strFileName = "video/\(product!.uid).mov" as! String

        let uploadTask = Storage.storage().reference().child(strFileName).putFile(from: url, metadata: nil, completion: { (metadata, error) in
            if error != nil {
                self.showAlert(title: appName, message: (error?.localizedDescription)!)
                self.btnDown.isEnabled = true
                return
            }
            if let storageUrl = metadata?.downloadURL()?.absoluteString {
                self.product?.videoUrl = metadata?.downloadURL()
                if let thumbnailImage = self.thumbnailImageForVideoUrl(videoUrl: url) {
                    // we can show thumbnailImage here
//                    self.uploadImgView.image = thumbnailImage
                }
            }
        })
        uploadTask.observe(.progress) { (snapshot) in
            if let progress = snapshot.progress {
                self.lblGameVideo.text = "Game Video is uploading..."
                self.btnDown.isEnabled = false
            }
        }
        uploadTask.observe(.success) { (snapshot) in
            self.lblGameVideo.text = "How to do this?"
            self.btnDown.isEnabled = true
        }
    }
    
    private func thumbnailImageForVideoUrl(videoUrl:URL) -> UIImage? {
        let asset = AVAsset(url:videoUrl)
        let imgGenerator = AVAssetImageGenerator(asset:asset)
        do {
            let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(0, 1), actualTime: nil)
            let uiImage = UIImage(cgImage: cgImage)
            return uiImage
        }
        catch let error {
            print(error.localizedDescription)
        }
        return nil
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

class categoryCell : UITableViewCell{
    
    @IBOutlet weak var lblName : UILabel!
    override func awakeFromNib() {
        
    }
}
