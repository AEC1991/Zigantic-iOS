//
//  AddPhotoViewController.swift
//  Bityo
//
//  Created by Chirag Ganatra on 30/11/17.
//  Copyright © 2017 Chirag Ganatra. All rights reserved.
//

import UIKit
import JDStatusBarNotification

class AddPhotoViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var outView: UIView!
    @IBOutlet weak var btnPublish: FSLoadingButton!
    
    var imagePicker = UIImagePickerController()
    var items : [UIImage] = []
    var product:FSProduct?
    var isFrom = "feed"
    var imageAdded: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        self.imageAdded = false
        product = FSProductManager.sharedInstance.product
        // Do any additional setup after loading the view.
        self.outView.layer.borderWidth = 1
        self.outView.layer.borderColor = UIColor(red:144/255, green:144/255, blue:144/255, alpha: 0.3).cgColor
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if (self.isFrom == "edit") {
            btnPublish.setTitle("Update", for: .normal)
        }
        else {
            btnPublish.setTitle("Publish", for: .normal)
        }
    }
    
    //MARK: - Show Camera -
    func showCam()
    {
        let actionSheetController: UIAlertController = UIAlertController(title: "Please select", message: "", preferredStyle: .actionSheet)
        
        let cancelActionButton = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            print("Cancel")
        }
        actionSheetController.addAction(cancelActionButton)
        
        let saveActionButton = UIAlertAction(title: "Photo Gallary", style: .default)
        { _ in
            
            if UIImagePickerController .isSourceTypeAvailable(.photoLibrary) {
                self.imagePicker.allowsEditing = true
                self.imagePicker.sourceType = .photoLibrary
                self .present(self.imagePicker, animated: true, completion: nil)
                
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
    
    @IBAction func backTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func nextTapped(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func onBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func createProduct() {
        FSProductManager.sharedInstance.startUploadImg(withCompletion: {(_ error: String?) -> Void in
            
            FSProductManager.sharedInstance.createProduct(
                completion: { (product) in
                    self.btnPublish.hideLoading()
                    self.navigationController?.popToRootViewController(animated: true)
            },
                failure: {(error) in
                    self.btnPublish.hideLoading()
                    self.showAlert(title: appName, message: error)
            })
        })
    }
    
    func updateProduct() {
        FSProductManager.sharedInstance.createProduct(
            completion: { (product) in
                self.btnPublish.hideLoading()
                self.navigationController?.popToRootViewController(animated: true)
        },
            failure: {(error) in
                self.btnPublish.hideLoading()
                self.showAlert(title: appName, message: error)
        })
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
class PhotoCell : UICollectionViewCell{
    
    @IBOutlet weak var imgView: FSImageView!
    
    override func awakeFromNib() {
    }
    
    func setupCell(_ imgUrl:URL?) {
        self.imgView.showLoading()
        self.imgView?.sd_setImage(with: imgUrl, completed: { (image, error, type, url) in
            self.imgView.hideLoading()
            DispatchQueue.main.async {
                self.layoutSubviews()
                self.updateConstraints()
            }
        })
    }
}

extension UIViewController
{
    func showAlert(title:String ,message:String) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: UIAlertControllerStyle.alert)
        
        let cancelAction = UIAlertAction(title: "OK",
                                         style: .cancel, handler: nil)
        
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func showAlertwithHandler(title:String ,message:String, okAction : @escaping ()->()) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: UIAlertControllerStyle.alert)
        
        let cancelAction = UIAlertAction(title: "OK", style: .default) { (alert) in
            okAction()
        }
        
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func showAlertwithHandlercancel(title:String ,message:String, okAction : @escaping ()->()) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: UIAlertControllerStyle.alert)
        
        let cancelAction = UIAlertAction(title: "OK", style: .default) { (alert) in
            okAction()
        }
        let cancelAction1 = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        
        alert.addAction(cancelAction)
        alert.addAction(cancelAction1)
        self.present(alert, animated: true, completion: nil)
    }
}

