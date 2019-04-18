//
//  YJNetworkManager.swift
//  Simple
//
//  Created by JotingYou on 2019/4/12.
//  Copyright © 2019 YouJoting. All rights reserved.
//

import UIKit
import AFNetworking
class YJHttpTool: NSObject {
    
    static let shared = YJHttpTool()
    
    let httpManager: AFHTTPSessionManager = {
        let manager = AFHTTPSessionManager.init(sessionConfiguration: .default)
        manager.requestSerializer = AFHTTPRequestSerializer()
        manager.responseSerializer = AFHTTPResponseSerializer()
        return manager
    }()
    func getData() -> Array<Stocks> {
        let stocks = Array<Stocks>()
        let para = ["":""]
        
        httpManager.post("http://api.tushare.pro", parameters: para, progress: { (Progress) in
        }, success: { (URLSessionDataTask, Any) in
            
        }) { (URLSessionDataTask, Error) in
            
        }
        return stocks
    }
    func getFundInfo() -> Bool {
        let url = URL.init(string: "http://fund.eastmoney.com/js/fundcode_search.js")
        let request = URLRequest.init(url: url!)
        
        
        let task = httpManager.downloadTask(with: request, progress: nil, destination: { (destUrl, response) -> URL in
            return try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("fundcode_search.js")
        }) { (response, url, error) in
        }
        task.resume()
        return false
    }
}
