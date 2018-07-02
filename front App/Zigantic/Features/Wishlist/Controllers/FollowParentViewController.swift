//
//  FollowParentViewController.swift
//  Bityo
//
//  Created by iOS Developer on 1/24/18.
//  Copyright © 2018 Chirag Ganatra. All rights reserved.
//

import UIKit

class FollowParentViewController: UIViewController {
    
    @IBOutlet weak var viewContainer: UIView!
    
    var followingVC : UIViewController!
    var followerVC : UIViewController!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        followingVC = Utilities.viewController("ChildFollowingViewController", onStoryboard: "Follow") as! ChildFollowingViewController
        followerVC = Utilities.viewController("ChildFollowersViewController", onStoryboard: "Follow") as! ChildFollowersViewController
        
        let slidingContainerViewController = SlidingContainerViewController (
            parent: self,
            contentViewControllers: [followingVC, followerVC],
            titles: ["FOLLOWING", "FOLLOWERS"])
        slidingContainerViewController.sliderView.appearance.fixedWidth = true
        slidingContainerViewController.sliderView.appearance.selectorColor = themeOrangeColor
        slidingContainerViewController.sliderView.appearance.backgroundColor = .white
        slidingContainerViewController.sliderView.appearance.selectorHeight = 2.0
        
        viewContainer.addSubview(slidingContainerViewController.view)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func menuTapped(_ sender: Any) {
        self.sideMenuController().openMenu()
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
