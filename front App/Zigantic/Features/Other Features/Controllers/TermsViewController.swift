//
//  PrivacyViewController.swift
//  Zigantic
//
//  Created by iOS Developer on 4/1/18.
//  Copyright © 2018 Chirag Ganatra. All rights reserved.
//

import UIKit
import WebKit

class TermsViewController: UIViewController{
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    
    var wkWebView:WKWebView!
    var type:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        let tapTermsGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapTerms))
//        backView.addGestureRecognizer(tapTermsGesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        addWebView()
        if type == "terms" {
            lblTitle.text = "Terms & Conditions"
        }
        else {
            lblTitle.text = "Privacy Policy"
        }
    }
    
    @IBAction func onBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func tapTerms(sender: UITapGestureRecognizer){
        self.navigationController?.popViewController(animated: true)
    }

    func addWebView() {
        wkWebView = WKWebView(frame:contentView.frame)
        wkWebView.isOpaque = false
        wkWebView.backgroundColor = UIColor.clear
        contentView.addSubview(wkWebView)
        constrainView(view: wkWebView, toView: contentView)
        
//        let request = URLRequest(url: URL(string:TERMS_URL)!)
        var urlString = PRIVACY_URL
        if self.type == "terms" {
            urlString = TERMS_URL
        }
        
        let request = URLRequest(url: URL(string:urlString)!)

        wkWebView.load(request)
    }
    
    func constrainView(view:UIView, toView contentView:UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        view.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
    }
}



