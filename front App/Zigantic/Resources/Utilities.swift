//
//  Utilities.swift
//  Bityo
//
//  Created by Chirag Ganatra on 29/11/17.
//  Copyright © 2017 Chirag Ganatra. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import Alamofire
import SwiftyJSON

class Utilities: NSObject {

    class func viewController(_ name: String, onStoryboard storyboardName: String) -> UIViewController {
        let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: name)
    }
    
    class func isValidateEmail(email: String) -> Bool {
        let emailRegEx: String = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{1,25}"
        let emailTest: NSPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }
    
    class func msgBox(title:String?, text:String?, viewController:UIViewController, onOK:((UIAlertAction) -> Void)?) {
        let alertVC = UIAlertController(title: title, message: text, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: onOK)
        okAction.setValue(themeOrangeColor, forKeyPath: "titleTextColor")
        alertVC.addAction(okAction)
        viewController.present(alertVC, animated: true, completion: nil)
    }
    
    class func bottomBorder(view:UIView?) {
        let bottomBorder = CALayer()
        bottomBorder.frame = CGRect(x: 0.0, y: 43.0, width: (view?.frame.size.width)!, height: 1.0)
        bottomBorder.backgroundColor = themeBoderColor.cgColor
        view?.layer.addSublayer(bottomBorder)
    }
    
    class func getDataFromUrl(url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url) { data, response, error in
        completion(data, response, error)
        }.resume()
    }
    
    class func resizeImage(_ image: UIImage) -> UIImage {
        var scale:CGFloat
        var newWidth:CGFloat
        var newHeight:CGFloat
        if (image.size.height > CGFloat(MAX_AVATAR_SIZE))
        {
            scale = CGFloat(MAX_AVATAR_SIZE) / image.size.height
        }
        else {
            scale = 1.0
        }
        newHeight = image.size.height * scale
        newWidth = image.size.width * scale
    
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        let imageData = UIImageJPEGRepresentation(newImage!, 0.5)! as Data
        UIGraphicsEndImageContext()
        return UIImage(data:imageData)!
    }
    
    class func downloadImage(url: URL, completion: ((UIImage) -> Void)?,
        failure: ((String) -> Void)?) {
        Utilities.getDataFromUrl(url: url) { data, response, error in
        guard let data = data, error == nil else {
            failure!((error?.localizedDescription)!)
            return
        }
        print("Download Finished")
        DispatchQueue.main.async() {
            let image = UIImage(data: data)
            if (image != nil)
            {
                completion!(image!)
            }
            else {
                failure!("Download failed!")
            }
        }
        }
    }
    
    class func uploadMedia(image: UIImage, ref: String, completion: ((URL) -> Void)?,
            failure: ((String) -> Void)?) {
        let storageRef = Storage.storage().reference().child(ref)
        if let uploadData = UIImageJPEGRepresentation(image, kJPEGImageQuality) {
            storageRef.putData(uploadData, metadata: nil) { (metadata, error) in
                if error != nil {
                    print("error")
                    failure!((error?.localizedDescription)!)
                }
                else {
                    completion!((metadata?.downloadURL())!)
                    // your uploaded photo url.
                }
            }
        }
    }
    
    class func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    class func convertDateToAbbrevigation(date: Date) -> String
    {
        let calendar = Calendar.current
        let curDate = Date()
        let diffDay = abs(calendar.dateComponents([.day], from: date, to: curDate).day ?? 0)
        let diffHour = abs(calendar.dateComponents([.hour], from: curDate, to: date).hour ?? 0)
        let diffMin = abs(calendar.dateComponents([.minute], from: curDate, to: date).minute ?? 0)
        let diffSec = abs(calendar.dateComponents([.second], from: curDate, to: date).second ?? 0)
        
        if diffDay > 1 {
            return "\(diffDay) days ago"
        } else if diffDay == 1 {
            return "A day ago"
        } else if diffHour > 1 {
            return "\(diffHour) hours ago"
        } else if diffHour == 1 {
            return "An hour ago"
        } else if diffMin > 1 {
            return "\(diffMin) minutes ago"
        } else if diffMin == 1 {
            return "A minute ago"
        } else if diffSec > 1 {
            return "\(diffSec) seconds ago"
        } else if diffSec == 1 {
            return "A second ago"
        }
        else {
            return "Just now"
        }
    }

}
