//
//  FeedDetailViewController.swift
//  Bityo
//
//  Created by Chirag Ganatra on 29/11/17.
//  Copyright © 2017 Chirag Ganatra. All rights reserved.
//

import UIKit
import Firebase
import JDStatusBarNotification
import DropDown
import TwitterKit
import AVKit
import AVFoundation

class FeedDetailViewController: UIViewController, UITextFieldDelegate, AddNewFeedViewControllerDelegate {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var logoImgView: UIImageView!
    @IBOutlet weak var lblAppLink: UILabel!
    @IBOutlet weak var btnVideo: UIButton!
    @IBOutlet weak var lblHowTo: UILabel!
    
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var gameImgView: UIImageView!
    @IBOutlet weak var questionCollection: UICollectionView!
    
    @IBOutlet weak var lblCategory: UILabel!
    
    @IBOutlet weak var avatarImgView: SpringImageView!
    @IBOutlet weak var lblFullname: UILabel!
    @IBOutlet weak var btnSubmit: FSLoadingButton!
    
    @IBOutlet weak var questionCollectionHeightConstraint: NSLayoutConstraint!
    
    
    var productRef: DataSnapshot!
    var product:FSProduct!
    var survey:FSSurvey!
    var seller:FSUser!
    var isProductRemoved:Bool = false
    var isFrom = "feed"
    var cryptoCurrency = "btc"
    
    let validator = Validator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapHowGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapVideo))
        lblHowTo.addGestureRecognizer(tapHowGesture)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        var user = FSUserManager.sharedInstance.user
        if user?.type == "develop" {
            btnSubmit.isHidden = true
        }
        else if user?.type == "admin" {
            btnSubmit.setTitle("Go to Survey List", for: .normal)
            btnSubmit.isHidden = false
        }
        else {
            btnSubmit.isHidden = false
        }
        
        UIApplication.shared.statusBarStyle = .default
        print(productRef.key)
        
        showProductInfo()
    }
    
    private func setSurvey(_ product:FSProduct) {
        if survey == nil {
            survey = FSSurvey()
        }
        if (survey?.uid == nil || survey?.uid == "") {
            let key = FSSurvey.collection.childByAutoId().key as! String
            survey?.uid = key
        }
        
        survey?.gameId = product.uid
        survey?.userId = (FSUserManager.sharedInstance.user?.uid)!
        setQuestion()
        FSSurveyManager.sharedInstance.survey = survey
    }
    
    private func setQuestion() {
        var surQuestions:[String] = []
        var surAnswers:[String] = []

        for index in 0...product.answers.count - 1 {
            let indexPath = IndexPath(item: index, section: 0)
            let cell = questionCollection!.cellForItem(at: indexPath) as! QuestionCell
            let question = cell.lblQuestion.text as? String
            let answer = cell.txtAnswer.text as? String

            if question != nil && answer != nil {
                surQuestions.append(question!)
                surAnswers.append(answer!)
            }
        }
        survey.questionStruct = Dictionary(uniqueKeysWithValues: zip(surQuestions, surAnswers))
    }
    
    @IBAction func onSubmit(_ sender: Any) {
        if FSUserManager.sharedInstance.user?.type == "admin" {
            self.performSegue(withIdentifier: "show.survey", sender: nil)
        }
        else {
            self.btnSubmit.showLoading()
            self.setSurvey(product)
            FSSurveyManager.sharedInstance.addSurveyList(survey)
            
            FSSurveyManager.sharedInstance.submitSurvey(
                completion: { (survey) in
                    self.btnSubmit.hideLoading()
                    let vc = Utilities.viewController("AddPhotoViewController", onStoryboard: "Feeds") as! AddPhotoViewController
                    vc.isFrom = self.isFrom
                    self.navigationController?.pushViewController(vc, animated: true)
            },
                failure: {(error) in
                    self.btnSubmit.hideLoading()
                    self.showAlert(title: appName, message: error)
            })
        }
    }
    
    func onPlayVideo() {
        if product.videoUrl == nil {
            return
        }
        let player = AVPlayer(url: product.videoUrl!)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        self.present(playerViewController, animated: true) {
            playerViewController.player!.play()
        }
    }
    
    @IBAction func playVideo(_ sender: Any) {
        onPlayVideo()
    }
    
    func productDeleted() {
        self.isProductRemoved = true
        self.navigationController?.popViewController(animated: false)
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        //your code
        return true
    }
    
    func tapVideo(sender: UITapGestureRecognizer){
        onPlayVideo()
    }
    
    func shareFacebook() {
        
    }
    
    func showProductInfo() {
        var data = self.productRef?.value as? NSDictionary
        self.product = FSProduct(dataDictionary: data!)
        
        let ratio:CGFloat = CGFloat(0.3) * CGFloat(product.answers.count)
        
        questionCollectionHeightConstraint = questionCollectionHeightConstraint.setMultiplier(multiplier: ratio)
        questionCollectionHeightConstraint.constant = 30.0
        
        lblTitle.text = product.title
        if product.contentDescription != nil {
            lblDescription.text = product.contentDescription
        }
        if product.appLink != nil {
            lblAppLink.text = product.appLink
        }
        
        if (product.logoUrl != nil) {
            self.logoImgView.showLoading()
            self.logoImgView?.sd_setImage(with: product.logoUrl, completed: { (image, error, type, url) in
                self.logoImgView.hideLoading()
                DispatchQueue.main.async {
                    if (image == nil) {
                        self.logoImgView.image = UIImage(named: "product_default")
                    }
                }
            })
        }
        else {
            self.logoImgView.image = UIImage(named: "product_default")
        }
        
        if (product.imgUrls != nil) {
            self.gameImgView.showLoading()
            self.gameImgView?.sd_setImage(with: URL(string:product.imgUrls?[0] as! String), completed: { (image, error, type, url) in
                print(error?.localizedDescription)
                self.gameImgView.hideLoading()
                DispatchQueue.main.async {
                    if (image == nil) {
                        self.gameImgView.image = UIImage(named: "product_default")
                    }
                }
            })
        }
        else {
            self.gameImgView.image = UIImage(named: "product_default")
        }
    }
    
    override func showAlert(title:String ,message:String) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: UIAlertControllerStyle.alert)
        
        let cancelAction = UIAlertAction(title: "OK",
                                         style: .cancel, handler: nil)
        
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func profileTapped(_ sender: Any) {
        let vc = Utilities.viewController("ParentMyProfileViewController", onStoryboard: "Wishlist") as! ParentMyProfileViewController
        vc.isFrom = "FeedDetails"
        vc.user = self.seller
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func backTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func starTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if (sender.isSelected == true) {
            FSProductManager.sharedInstance.addWishList(product)
        }
        else {
            FSProductManager.sharedInstance.removeWishList(product, (FSUserManager.sharedInstance.user?.uid)!)
        }
    }
    
    @IBAction func onFollow(_ sender: Any) {
        if (FSUserManager.sharedInstance.checkImFollowing(seller!) == true) {
            FSUserManager.sharedInstance.removeFollowingUser(inUser: seller!)
        }
        else {
            FSUserManager.sharedInstance.addFollowingUser(inUser: seller!)
        }
    }
    
    @IBAction func onMessage(_ sender: Any) {
        let vc = Utilities.viewController("MessagesViewController", onStoryboard: "Chat") as! MessagesViewController
        vc.product = self.product
        vc.partner = self.seller
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func onReport(_ sender: Any) {
        self.performSegue(withIdentifier: "show.report", sender: self.product)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let surveyList = segue.destination as? SurveyListVC {
            surveyList.product = self.product
        }
    }
}

extension FeedDetailViewController : UICollectionViewDataSource, UICollectionViewDelegate{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return product.questions.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "QuestionCell", for: indexPath) as! QuestionCell
        let question:String = "Game Application Question " + String(indexPath.row + 1)
        cell.lblQuestion.text = self.product.questions[indexPath.row]
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}

extension NSLayoutConstraint {
    /**
     Change multiplier constraint
     
     - parameter multiplier: CGFloat
     - returns: NSLayoutConstraint
     */
    func setMultiplier(multiplier:CGFloat) -> NSLayoutConstraint {
        
        NSLayoutConstraint.deactivate([self])
        
        let newConstraint = NSLayoutConstraint(
            item: firstItem,
            attribute: firstAttribute,
            relatedBy: relation,
            toItem: secondItem,
            attribute: secondAttribute,
            multiplier: multiplier,
            constant: constant)
        
        newConstraint.priority = priority
        newConstraint.shouldBeArchived = self.shouldBeArchived
        newConstraint.identifier = self.identifier
        
        NSLayoutConstraint.activate([newConstraint])
        return newConstraint
    }
}




