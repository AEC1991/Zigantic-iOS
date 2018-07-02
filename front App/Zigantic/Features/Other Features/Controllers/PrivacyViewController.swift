//
//  PrivacyViewController.swift
//  Zigantic
//
//  Created by iOS Developer on 4/1/18.
//

import UIKit
import WebKit

class PrivacyViewController: UIViewController, WKNavigationDelegate{
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var contentView: UIView!
    var wkWebView:WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapPrivacyGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapPrivacy))
        backView.addGestureRecognizer(tapPrivacyGesture)
        addWebView()
    }
    
    @IBAction func onBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("Finished navigating to url \(webView.url)")
    }
    
    func addWebView() {
        wkWebView = WKWebView(frame:contentView.frame)
        wkWebView.navigationDelegate = self
        contentView.addSubview(wkWebView)
        constrainView(view: wkWebView, toView: contentView)
        
        let request = URLRequest(url: URL(string:TERMS_URL)!)
        wkWebView.load(request)
    }
    
    func tapPrivacy(sender: UITapGestureRecognizer){
        self.navigationController?.popViewController(animated: true)
    }
    
    func constrainView(view:UIView, toView contentView:UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        view.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
    }
}


