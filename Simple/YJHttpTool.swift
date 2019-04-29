//
//  YJNetworkManager.swift
//  Simple
//
//  Created by JotingYou on 2019/4/12.
//  Copyright © 2019 YouJoting. All rights reserved.
//

import UIKit
import SwiftyJSON
import SDWebImage
import Alamofire
import SwiftSoup
class YJHttpTool: NSObject {
    
    static let shared = YJHttpTool()
    
    let httpManager: SessionManager = {
        let manager = SessionManager()
        return manager
    }()
    
    ///获取沪深300指数收益率
    func getBasicRate(complication:((Float) -> Void)?) {
        let url = URL(string: "http://hq.sinajs.cn/list=sz399300")!
        let headers = SessionManager.defaultHTTPHeaders
        httpManager.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseData { (response) in
            if let status = response.response?.statusCode{
                switch(status){
                    case 200:
                        print("success")
                        break
                    default:
                        print("error with response status: \(status)")
                        return
                }
            }
            if let data = response.result.value{
                let string = String.init(data: data, encoding: .utf8)
                print(string)
            }
        }
        
        
    }
    static func setImageFor(_ view:UIImageView,_ id:String?) {
        let url = URL.init(string: "http://j4.dfcfw.com/charts/pic6/" + (id ?? "") + ".png")
        view.sd_setImage(with: url,placeholderImage: UIImage(named: "placeholder"), completed: nil)
    }
    /**
     请求基金净值数据
     返回[status:0,value:0]
     status:0 for failed,1 for success
     */
    func getFundValue(id:String,complication:((Dictionary<String,String>) -> Void)?){
        let url = URL.init(string: "http://fund.eastmoney.com/f10/F10DataApi.aspx?type=lsjz&code="+id)!
        httpManager.request(url).responseData { (response) in
            if let status = response.response?.statusCode{
                switch (status) {
                case 200:
                    break
                default:
                    print("error:\(status)")
                    return
                }
            }
            if let data = response.result.value{
                let dataStr = String.init(data: data, encoding: .utf8)
                guard let start = dataStr?.range(of: "var apidata={ ")else{
                    //complication?(["status":"0","valus":"0","updateTime":"0"])
                    return
                }
                guard let end = dataStr?.range(of: ";")else{
                    //complication?(["status":"0","valus":"0","updateTime":"0"])
                    return
                }
                let responceStr = dataStr?[start.upperBound..<end.lowerBound]
                let dic = self.getDictionFor(resonseStr: String(responceStr!))
                let html = dic["content"]
                do {
                    let doc:Document = try SwiftSoup.parse(html!)
                    
                    guard let updateTimeTD: Element = try doc.select("td").first() else{
                        return
                    }
                    let updateTime = try updateTimeTD.text()
                    
                    let valueTD:Element = try doc.select("td").get(1)
                    let value = try valueTD.text()
                    complication?(["status":"1","value":value,"updateTime":updateTime])
                }catch{
                    print("HTML parse error")
                }
            }
        }
    }
//    func getFundValue(id:String)-> Dictionary<String,String> {
////        获取股票信息
////        let time = Date().timeIntervalSince1970
////        let timeInterval = CLongLong(round(time*1000))
////        print(timeInterval)
////        let url = URL.init(string: "http://fundgz.1234567.com.cn/js/" + id + ".js?rt=" + String(timeInterval))
//
//        let url = URL.init(string: "http://fund.eastmoney.com/f10/F10DataApi.aspx?type=lsjz&code="+id)
//        do{
//            let data = try Data.init(contentsOf:url!)
//            let dataStr = String.init(data: data, encoding: .utf8)
//            guard let start = dataStr?.range(of: "var apidata={ ")else{
//                return["status":"0","valus":"0","updateTime":"0"]
//            }
//            guard let end = dataStr?.range(of: ";")else{
//                return["status":"0","valus":"0","updateTime":"0"]
//            }
//            let responceStr = dataStr?[start.upperBound..<end.lowerBound]
//            let dic = getDictionFor(resonseStr: String(responceStr!))
//            let html = dic["content"]
//            do {
//                let doc:Document = try SwiftSoup.parse(html!)
//
//                let updateTimeTD: Element = try doc.select("td").first()!
//                let updateTime = try updateTimeTD.text()
//
//                let valueTD:Element = try doc.select("td").get(1)
//                let value = try valueTD.text()
//
//                return["status":"1","value":value,"updateTime":updateTime]
//            }catch{
//                print("HTML parse error")
//            }
//        }catch{
//            print("Network:Failed to get data")
//        }
//
//        return["status":"0","valus":"0","updateTime":"0"]
//    }
    func getFundInfo(success:((Bool) -> Void)?){
        let url = URL(string: "http://fund.eastmoney.com/js/fundcode_search.js")
        let request = URLRequest(url: url!)
        

        let destination:DownloadRequest.DownloadFileDestination = {_,_ in
            return (YJConst.fundFileUrl,[.createIntermediateDirectories,.removePreviousFile])
        }
        httpManager.download(request, to: destination).response { (response) in
            var flag = true
            
            if response.error != nil{
                flag = false
                print(response.error!)
            }
            if success != nil{
                success!(flag)
            }
        }
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
