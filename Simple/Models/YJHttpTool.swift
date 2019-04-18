//
//  YJNetworkManager.swift
//  Simple
//
//  Created by JotingYou on 2019/4/12.
//  Copyright © 2019 YouJoting. All rights reserved.
//

import UIKit
import AFNetworking
import SwiftSoup
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
     返回[status:0,value:0]
     status:0 for failed,1 for success
     */
    func getFundValue(id:String)-> Dictionary<String,String> {
//        获取股票信息
//        let time = Date().timeIntervalSince1970
//        let timeInterval = CLongLong(round(time*1000))
//        print(timeInterval)
//        let url = URL.init(string: "http://fundgz.1234567.com.cn/js/" + id + ".js?rt=" + String(timeInterval))
        
        let url = URL.init(string: "http://fund.eastmoney.com/f10/F10DataApi.aspx?type=lsjz&code="+id)
        do{
            let data = try Data.init(contentsOf:url!)
            let dataStr = String.init(data: data, encoding: .utf8)
            guard let start = dataStr?.range(of: "var apidata={ ")else{
                return["status":"0","valus":"0","updateTime":"0"]
            }
            guard let end = dataStr?.range(of: ";")else{
                return["status":"0","valus":"0","updateTime":"0"]
            }
            let responceStr = dataStr?[start.upperBound..<end.lowerBound]
            let dic = getDictionFor(resonseStr: String(responceStr!))
            let html = dic["content"]
            do {
                let doc:Document = try SwiftSoup.parse(html!)
                
                let updateTimeTD: Element = try doc.select("td").first()!
                let updateTime = try updateTimeTD.text()
                
                let valueTD:Element = try doc.select("td").get(1)
                let value = try valueTD.text()
                
                return["status":"1","value":value,"updateTime":updateTime]
            }catch{
                print("HTML parse error")
            }
        }catch{
            print("Network:Failed to get data")
        }
 
        return["status":"0","valus":"0","updateTime":"0"]
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
    func getDictionFor(resonseStr:String) -> Dictionary<String,String> {
        var dic = Dictionary<String,String>()
        var start = resonseStr.range(of: "content:\"")
        var end = resonseStr.range(of: "\",records:")
        dic["content"] = String(resonseStr[start!.upperBound..<end!.lowerBound])
        
        start = end
        end = resonseStr.range(of: ",pages:")
        dic["records"] = String(resonseStr[start!.upperBound..<end!.lowerBound])
        
        start = end
        end = resonseStr.range(of: ",curpage:")
        dic["pages"] = String(resonseStr[start!.upperBound..<end!.lowerBound])
        
        start = end
        end = resonseStr.range(of: "}")
        dic["curpage"] = String(resonseStr[start!.upperBound..<end!.lowerBound])
        return dic
    }
}
