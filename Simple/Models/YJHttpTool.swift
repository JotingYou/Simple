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
    /**
     请求基金净值数据
     返回[status,value]
     status:0 for failed,1 for success
     */
    func getFundValue(id:String)-> [Double] {
//        获取股票信息
//        let time = Date().timeIntervalSince1970
//        let timeInterval = CLongLong(round(time*1000))
//        print(timeInterval)
//        let url = URL.init(string: "http://fundgz.1234567.com.cn/js/" + id + ".js?rt=" + String(timeInterval))
        httpManager.get("http://fund.eastmoney.com/f10/F10DataApi.aspx?type=lsjz&code="+id, parameters: nil, progress:nil,success: { (task, response) in
            guard let data:Data = response as? Data else{
                fatalError("GetFundValue Error:response can't be converted to Data")
            }
            let html = String.init(data: data, encoding: .utf8)



            

        }, failure: { (task, Error) in
            
        })
        
        
        
        return[0,1]
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
