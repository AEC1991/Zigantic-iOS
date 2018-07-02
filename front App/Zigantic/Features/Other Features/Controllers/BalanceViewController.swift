//
//  SettingsViewController.swift
//  Bityo
//
//  Created by Chirag Ganatra on 29/11/17.
//  Copyright © 2017 Chirag Ganatra. All rights reserved.
//

import UIKit
import StoreKit
import MessageUI

class BalanceViewController: UIViewController{
    
    
    @IBOutlet weak var lblCurrency: UIButton!
    
    @IBOutlet weak var lblCryptoBalance: UILabel!
    
    @IBOutlet weak var lblDollarBalance: UILabel!
    
    @IBOutlet weak var btnCryptoAddress: UIButton!
    
    @IBOutlet weak var btnCopy: UIButton!
    
    @IBOutlet weak var btnDeposit: UIButton!
    @IBOutlet weak var btnWithdraw: UIButton!
    
    @IBOutlet weak var withdrawView: UIView!
    
    @IBOutlet weak var headerTopConstraint: NSLayoutConstraint!
    
    var user:FSUser?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        user = FSUserManager.sharedInstance.user!
        // Do any additional setup after loading the view.
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .default
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupUI() {
        if (UIScreen.main.nativeBounds.height == 2436) {
            headerTopConstraint.constant = -24.0
        }
        else {
            headerTopConstraint.constant = -20.0
        }
        self.withdrawView.isHidden = true
    }
    
    @IBAction func onTapCurrentAddress(_ sender: Any) {
    }
    
    @IBAction func onTapCopy(_ sender: Any) {
    }
    
    @IBAction func onDeposit(_ sender: Any) {
        self.performSegue(withIdentifier: "show.deposit", sender: nil)
    }
    
    @IBAction func showWithdraw(_ sender: Any) {
        UIView.animate(withDuration: 0.4, animations: {
            self.view.layoutIfNeeded()
        }) { (success) in
            self.withdrawView.isHidden = false
        }
    }
    
    @IBAction func onWithdraw(_ sender: Any) {
        UIView.animate(withDuration: 0.4, animations: {
            self.view.layoutIfNeeded()
        }) { (success) in
            self.withdrawView.isHidden = true
        }
    }

    @IBAction func menuTapped(_ sender: Any) {
        self.sideMenuController().openMenu()
    }
    
}

