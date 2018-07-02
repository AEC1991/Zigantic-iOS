//
//  VerifyPhoneViewController.swift
//  Bityo
//
//  Created by iOS Developer on 1/17/18.
//  Copyright © 2018 Chirag Ganatra. All rights reserved.
//

import Foundation
import UIKit

class ReportItemViewController: UIViewController{
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var productImgView: FSImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSeller: UILabel!
    @IBOutlet weak var txtComment: UITextView!
    @IBOutlet weak var headerTopConstraint: NSLayoutConstraint!
    
    var product:FSProduct!
    var seller:FSUser!
    var report:FSReportItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (UIScreen.main.nativeBounds.height == 2436) {
            headerTopConstraint.constant = -44.0
        }
        else {
            headerTopConstraint.constant = -20.0
        }
        report = FSReportItem()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        showProductInfo()
        getSellerInfo()
    }
    
    func showProductInfo() {
        let imgUrl = self.product.imgUrls![0] as? String
        self.productImgView.showLoading()
        
        self.productImgView?.sd_setImage(with: URL(string: imgUrl!), completed: { (image, error, type, url) in
            self.productImgView.hideLoading()
        })
        
        lblTitle.text = product.title
    }
    
    func getSellerInfo() {
        FSUserManager.sharedInstance.getByIdNoAvatar(uid: (self.product?.sellerId)!,
                 completion: { (output:FSUser) in
                    self.seller = output
                    self.lblSeller.text = "Sold by " + self.seller.username
        },
                 failure: {(errorComment: String) -> Void in
                    self.showAlert(title: appName, message: errorComment)
        })
    }

    @IBAction func onBack(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onClose(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onSubmit(_ sender: Any) {
        
        report.productId = product.uid
        report.comment = txtComment.text
        
        FSReportItemManager.sharedInstance.doReport(inReport:report,
            completion: { (output:FSReportItem) in
                self.dismiss(animated: true, completion: nil)
        },
            failure: {(errorComment: String) -> Void in
                self.showAlert(title: appName, message: errorComment)
        })
    }
}

extension ReportItemViewController:UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reportList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reportCell", for: indexPath) as! ReportCell
        cell.lblReport.text = reportList[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 35
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 35.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        report.category =  reportList[indexPath.row]
    }
}

class ReportCell:UITableViewCell {
    
    @IBOutlet weak var lblReport: UILabel!
    
    override func awakeFromNib() {
    }
}


