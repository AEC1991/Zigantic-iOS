//
//  VerifyEmailViewController.swift
//  Bityo
//
//  Created by iOS Developer on 1/22/18.
//  Copyright © 2018 Chirag Ganatra. All rights reserved.
//

import Foundation
import UIKit

class VerifyEmailViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    @IBAction func onBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }


}
