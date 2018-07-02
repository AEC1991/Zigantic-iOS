//
//  PaymentManager.swift
//  Bityo
//
//  Created by iOS Developer on 1/8/18.
//  Copyright © 2018 Chirag Ganatra. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON

class PaymentManager: NSObject {
    static let sharedInstance = PaymentManager()
    
    var manager: SessionManager
    override init() {
        //Trust policy for self-signed Certificate
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = Alamofire.SessionManager.defaultHTTPHeaders
        
        manager = SessionManager(
            configuration: configuration
        )
    }
    
    func convertToCrypto(_ currency:String, _ callback: @escaping (_: STATUS_CODE, _: String)->Void)
    {
        
        var strUrl = URLManager.getConvertToCrypto() as! String
        print("API URL : " + strUrl)
        
        strUrl = strUrl + currency + "-usd"
        
        let headers = [
            "Content-Type": "application/json",
            "Accept": "application/json",
            ]
        
        manager.request(strUrl, method: .get, parameters: nil, encoding: JSONEncoding.prettyPrinted, headers: headers)
            .responseString { response in
                
                print(response.result)
                switch response.result {
                case .success(let data):
                    print(data)
                    let dictData = Utilities.convertToDictionary(text: data)
                    if (dictData == nil) {
                        callback(STATUS_CODE.connection_failed, FSMessage.NETWORK_ERROR)
                        return
                    }
                    print(dictData!["ticker"])
                    let tickerString = dictData!["ticker"] as? [String:Any]?
                    print((tickerString!!["price"])!)

                    callback(STATUS_CODE.success, (tickerString!!["price"])! as! String)
                    break
                    
                case .failure(let error):
                    print("Get currency conversion error: \(error)")
                    callback(STATUS_CODE.connection_failed, error.localizedDescription)
                }
        }
        
    }
    
    func convertToBtc(_ params:[String:Any], _ callback: @escaping (_: STATUS_CODE, _: String)->Void)
    {
        
        var strUrl = URLManager.getConvertToBtc() as! String
        print("API URL : " + strUrl)
        
        strUrl = strUrl + "?currency=\(params["currency"]!)&value=\(params["value"]!)"
        
        let headers = [
            "Content-Type": "application/json",
            "Accept": "application/json",
            ]
        
        manager.request(strUrl, method: .get, parameters: nil, encoding: JSONEncoding.prettyPrinted, headers: headers)
            .responseString { response in
                
                switch response.result {
                case .success(let data):
                    print(data)

                    callback(STATUS_CODE.success, data)
                    break
                    
                case .failure(let error):
                    print("Get currency conversion error: \(error)")
                    callback(STATUS_CODE.connection_failed, error.localizedDescription)
                }
        }
        
    }
}



