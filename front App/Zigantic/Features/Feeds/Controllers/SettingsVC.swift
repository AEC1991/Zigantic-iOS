//
//  FilterViewController.swift
//  Bityo
//
//  Created by Chirag Ganatra on 29/11/17.
//  Copyright © 2017 Chirag Ganatra. All rights reserved.
//

import UIKit
import StoreKit
import JDStatusBarNotification

class SettingsVC: UIViewController {
    
    @IBOutlet weak var settingCollection: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    override func viewWillDisappear(_ animated: Bool) {
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

extension SettingsVC:UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return settingList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SettingCell", for: indexPath) as! SettingCell
        switch indexPath.row {
        case 0:
            cell.iconImgView.image = UIImage(named:"redeem")
            break
        case 1:
            cell.iconImgView.image = UIImage(named:"aboutus")
            break
        case 2:
            cell.iconImgView.image = UIImage(named:"terms")
            break
        case 3:
            cell.iconImgView.image = UIImage(named:"terms")
            break
        case 4:
            cell.iconImgView.image = UIImage(named:"rating_star_off")
            break
        case 5:
            cell.iconImgView.image = UIImage(named:"share")
            break
        case 6:
            cell.iconImgView.image = UIImage(named:"signout")
            break
        default:
            break
        }

        cell.lblTitle.text = settingList[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            JDStatusBarNotification.show(withStatus: "Coming soon!!!", dismissAfter: 3.0, styleName: JDStatusBarStyleError)
            break
        case 1:
            let vc = Utilities.viewController("AboutUsViewController", onStoryboard: "Feeds") as! AboutUsViewController
            self.navigationController?.pushViewController(vc, animated: true)
            break
        case 2:
            let vc = Utilities.viewController("TermsViewController", onStoryboard: "Settings") as! TermsViewController
            vc.type = "terms"
            self.navigationController?.pushViewController(vc, animated: true)
            break
        case 3:
            let vc = Utilities.viewController("TermsViewController", onStoryboard: "Settings") as! TermsViewController
            vc.type = "privacy"
            self.navigationController?.pushViewController(vc, animated: true)
            break
        case 4:
            if #available(iOS 10.3, *) {
                SKStoreReviewController.requestReview()
            } else {
                // Fallback on earlier versions
            }
            break
        case 5:
            let vc = Utilities.viewController("ContactUsVC", onStoryboard: "Feeds") as! ContactUsVC
            self.navigationController?.pushViewController(vc, animated: true)
            break
            break
        case 6:
            FSUserManager.sharedInstance.logout()
            DELEGATE.goLoginPage(transition: true)
            break
        default:
            break
        }
    }
}


