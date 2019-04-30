//
//  Stocks+Method.swift
//  Simple
//
//  Created by JotingYou on 2019/4/27.
//  Copyright © 2019 YouJoting. All rights reserved.
//

import UIKit
import CoreData
extension Stocks {
    static func readFromCoreDate() -> [Stocks]?{
        //        建立一个获取的请求
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Stocks")
    
        //        执行请求
        do {
            let fetchedResults = try YJCache.shared.managedObjectContext.fetch(fetchRequest) as? [Stocks]
            if fetchedResults?.count == 0 {
                return nil
            }
            if let results = fetchedResults {
                return results
            }
    
        } catch{
            print("CoreData Error:读取股票失败")
            return nil
        }
        return nil
    }
    func update(_ stockString:YJStockStringObject){
        name = stockString.name
        id = stockString.id
        code = stockString.code
        name_spell = stockString.name_spell
        type = stockString.type
    }
    func update(_ complition: ((Bool)-> Void)? = nil){

        YJHttpTool.shared.getFundValue(id: id!,complition: {
            [weak self](dic) in
            if dic["status"] == "1"{
                let updateTime = YJCache.shared.dateFormatter.date(from: dic["updateTime"]!)!
                if self?.update_time ?? Date() < updateTime{
                    self?.unit_value = Double(dic["value"]!)!
                    self?.update_time = updateTime
                    complition?(true)
                    return
                }
            }
            complition?(false)
        })
    }

//                return true
//            }else{
//                return false
//            }
//
//        }else{
//            return false
//        }
//    }
    static func insert(_ stockString:YJStockStringObject) -> Stocks {
        let entity = NSEntityDescription.entity(forEntityName: "Stocks", in: YJCache.shared.managedObjectContext)!
        let stock = Stocks.init(entity: entity, insertInto: YJCache.shared.managedObjectContext)
        stock.name = stockString.name
        stock.id = stockString.id
        stock.code = stockString.code
        stock.name_spell = stockString.name_spell
        stock.type = stockString.type
        return stock
    }
    func save(){
        do {
            try YJCache.shared.managedObjectContext.save();
        } catch  {
            fatalError("无法保存")
        }
    }
}
