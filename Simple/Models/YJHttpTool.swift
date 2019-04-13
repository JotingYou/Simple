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
    let httpManager: AFHTTPSessionManager = {
        let manager = AFHTTPSessionManager()
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
}
