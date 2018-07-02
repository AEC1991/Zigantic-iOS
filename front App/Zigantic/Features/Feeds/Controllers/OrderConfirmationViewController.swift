//
//  OrderConfirmationViewController.swift
//  Bityo
//
//  Created by Chirag Ganatra on 04/12/17.
//  Copyright © 2017 Chirag Ganatra. All rights reserved.
//

import UIKit

class OrderConfirmationViewController: UIViewController {
    
    
    @IBOutlet weak var productImgView: SpringImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSeller: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    
    var product: FSProduct?
    var seller: FSUser?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        showProductInfo()
        getSellerInfo()
    }
    
    func showProductInfo() {
        lblTitle.text = product?.title
        self.productImgView.showLoading()
        self.productImgView?.sd_setImage(with: URL(string:product?.imgUrls?[0] as! String), completed: { (image, error, type, url) in
            self.productImgView.hideLoading()
        })
    }
    
    func getSellerInfo() {
        FSUserManager.sharedInstance.getByIdNoAvatar(uid: (product?.sellerId)!,
                                                     completion: { (output:FSUser) in
                                                        self.seller = output
                                                        self.showSellerInfo()
        },
                                                     failure: {(errorComment: String) -> Void in
        })
    }
    
    func showSellerInfo() {
        lblSeller.text = "seller : " + (seller?.username)!
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func backTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func doneTapped(_ sender: Any) {
        
        self.navigationController?.popToRootViewController(animated: true)
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
