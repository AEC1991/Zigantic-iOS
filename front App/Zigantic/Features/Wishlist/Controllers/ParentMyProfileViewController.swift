//
//  ParentMyProfileViewController.swift
//  Bityo
//
//  Created by Chirag Ganatra on 30/11/17.
//  Copyright © 2017 Chirag Ganatra. All rights reserved.
//

import UIKit

class ParentMyProfileViewController: UIViewController, SlidingContainerViewControllerDelegate {
    
    @IBOutlet weak var btnNav: UIButton!
    @IBOutlet weak var containerView: UIView!
    
    var user : FSUser?
    var detailsVC : ChildProfileDetailsViewController!
    var storeVC : ChildStoreViewController!
    var reviewsVC : ChildReviewsViewController!
    var isFrom = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        detailsVC = Utilities.viewController("ChildProfileDetailsViewController", onStoryboard: "Wishlist") as! ChildProfileDetailsViewController
        storeVC = Utilities.viewController("ChildStoreViewController", onStoryboard: "Wishlist") as! ChildStoreViewController
        reviewsVC = Utilities.viewController("ChildReviewsViewController", onStoryboard: "Wishlist") as! ChildReviewsViewController
        
        if (isFrom != "FeedDetails") {
            self.user = FSUserManager.sharedInstance.user
        }
        
        detailsVC.user = self.user
        storeVC.user = self.user
        reviewsVC.user = self.user

        let slidingContainerViewController = SlidingContainerViewController (
            parent: self,
            contentViewControllers: [detailsVC, storeVC, reviewsVC],
            titles: ["Details", "Store", "Reviews"])
        slidingContainerViewController.sliderView.appearance.fixedWidth = true
        slidingContainerViewController.sliderView.appearance.selectorColor = themeOrangeColor
        
        slidingContainerViewController.sliderView.appearance.backgroundColor = .white
        slidingContainerViewController.sliderView.appearance.selectorHeight = 2.0
        containerView.addSubview(slidingContainerViewController.view)
        
        if UIDevice().userInterfaceIdiom == .phone && UIScreen.main.nativeBounds.height == 2436 {
            //iPhone X
        }else{
            reviewsVC.downConst.constant = 64
            storeVC.downConst.constant = 64
        }
        // Do any additional setup after loading the view.
        if isFrom == "FeedDetails" && user?.uid != FSUserManager.sharedInstance.user?.uid{
            btnNav.setImage(#imageLiteral(resourceName: "back_arrow_nav"), for: .normal)
            detailsVC.constTwoButtonHeight.constant = 40
            detailsVC.btnMsg.isHidden = false
            detailsVC.btnFollow.isHidden = false
        }else{
            detailsVC.constTwoButtonHeight.constant = 0
            detailsVC.btnMsg.isHidden = true
            detailsVC.btnFollow.isHidden = true
        }
    }
    
    func slidingContainerViewControllerDidMoveToViewController(_ slidingContainerViewController: SlidingContainerViewController, viewController: UIViewController, atIndex: Int) {
    }
    
    func slidingContainerViewControllerDidHideSliderView(_ slidingContainerViewController: SlidingContainerViewController) {
        
    }
    
    func slidingContainerViewControllerDidShowSliderView(_ slidingContainerViewController: SlidingContainerViewController) {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func menuTapped(_ sender: Any) {
        if isFrom == "FeedDetails"{
            self.navigationController?.popViewController(animated: true)
        }else{
            sideMenuController().openMenu()
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
