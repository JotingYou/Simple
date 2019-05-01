//
//  YJNetworkManager.swift
//  Simple
//
//  Created by JotingYou on 2019/4/12.
//  Copyright © 2019 YouJoting. All rights reserved.
//

import UIKit
import SDWebImage
import Alamofire
import SwiftSoup
class YJHttpTool: NSObject {
    
    static let shared = YJHttpTool()
    
    let httpManager: SessionManager = {
        let manager = SessionManager()
        manager.session.configuration.timeoutIntervalForRequest = 10
        return manager
    }()
    
    ///获取沪深300指数收益率
    func getBasicRate(_ complition:((Dictionary<String,String>) -> Void)?) {
        let url = URL(string: "http://hq.sinajs.cn/list=sz399300")!
        httpManager.request(url).responseData(completionHandler:{
            [weak self] (response) in
            if let status = response.response?.statusCode{
                switch(status){
                    case 200:
                        break
                    default:
                        print("error with response status: \(status)")
                        return
                }
            }
            if let data = response.result.value{
                if let str = String.init(gbkData: data){
                    guard let basicDic = self?.getBasicDicFrom(str) else{
                        return
                    }
                    complition?(basicDic)
                }

            }
        })
        
        
    }
    static func setImageFor(_ view:UIImageView,_ id:String?) {
        let url = URL.init(string: "http://j4.dfcfw.com/charts/pic6/" + (id ?? "") + ".png")
        view.sd_setImage(with: url,placeholderImage: UIImage(named: "placeholder"), completed: nil)
    }
    /**
     异步请求基金净值数据
     返回[status:0,value:0]
     status:0 for failed,1 for success
     */
    func getFundValue(id:String,complition:((Dictionary<String,String>) -> Void)?){
        let url = URL.init(string: "http://fund.eastmoney.com/f10/F10DataApi.aspx?type=lsjz&code="+id)!
        httpManager.request(url).responseData {[weak self] (response) in
            if let error = response.error {
                if (error._code == NSURLErrorTimedOut) || (error._code == -1009) {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue:YJConst.internetTimeout), object: nil)
                    print("Time out for value of fund:\(id)")
                    
                }
                complition?(["status":"0","valus":"0","updateTime":"0"])
            }
            if let status = response.response?.statusCode{
                switch (status) {
                case 200:
                    break
                default:
                    print("error:\(status)")
                    complition?(["status":"0","valus":"0","updateTime":"0"])
                    return
                }
            }
            if let data = response.result.value{
                let dataStr = String.init(data: data, encoding: .utf8)
                guard let start = dataStr?.range(of: "var apidata={ ")else{
                    complition?(["status":"0","valus":"0","updateTime":"0"])
                    return
                }
                guard let end = dataStr?.range(of: ";")else{
                    complition?(["status":"0","valus":"0","updateTime":"0"])
                    return
                }
                let responceStr = dataStr?[start.upperBound..<end.lowerBound]
                guard let dic = self?.getFundDicFor(resonseStr: String(responceStr!)) else{
                    fatalError("Http manager has be freed")
                }
                guard let html = dic["content"] else{
                    print("html has no content")
                    complition?(["status":"0","valus":"0","updateTime":"0"])
                    return
                }
                do {
                    let doc:Document = try SwiftSoup.parse(html)
                    //print(doc)
                    guard let updateTimeTD: Element = try doc.select("td").first() else{
                        complition?(["status":"0","valus":"0","updateTime":"0"])
                        return
                    }
                    let updateTime = try updateTimeTD.text()
                    let valueTDs:Elements = try doc.select("td")
                    if valueTDs.size() < 2 {
                        complition?(["status":"0","valus":"0","updateTime":"0"])
                        return
                    }
                    let valueTD = valueTDs.get(1)
                    
                    let value = try valueTD.text()
                    complition?(["status":"1","value":value,"updateTime":updateTime])
                }catch let error{
                    print("HTML parse error:\(error)")
                    complition?(["status":"0","valus":"0","updateTime":"0"])
                    return
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
    func getFundList(_ success:((Bool) -> Void)?=nil,_ failure:((Error)->Void)?=nil){
        let url = URL(string: "http://fund.eastmoney.com/js/fundcode_search.js")
        let request = URLRequest(url: url!)
        let destination:DownloadRequest.DownloadFileDestination = {_,_ in
            return (YJConst.fundFileUrl,[.createIntermediateDirectories,.removePreviousFile])
        }
        httpManager.download(request, to: destination).response { (response) in
            if let error = response.error{
                print("Get fund list failed:\(error)")
                failure?(error)
                return
            }
            var flag = true
            success?(flag)
        }
    }
    func getBasicDicFrom(_ str:String) -> Dictionary<String,String> {
        var dic = Dictionary<String,String>()
        let strs = str.split(separator: ",")
        dic["yesterday"] = String(strs[2])
        dic["now"] = String(strs[3])
        dic["date"] = String(strs[strs.count - 3])
        dic["time"] = String(strs[strs.count - 2])
        return dic
    }
    func getFundDicFor(resonseStr:String) -> Dictionary<String,String> {
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
extension String {
    init?(gbkData: Data) {
        //获取GBK编码, 使用GB18030是因为它向下兼容GBK
        let cfEncoding = CFStringEncodings.GB_18030_2000
        let encoding = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(cfEncoding.rawValue))
        //从GBK编码的Data里初始化NSString, 返回的NSString是UTF-16编码
        if let str = NSString(data: gbkData, encoding: encoding) {
            self = str as String
        } else {
            return nil
        }
    }
}
