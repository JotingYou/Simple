//
//  Holds+Method.swift
//  Simple
//
//  Created by JotingYou on 2019/4/27.
//  Copyright © 2019 YouJoting. All rights reserved.
//

import UIKit
import CoreData
extension Holds {
    
    static func read()->[Holds]{
        //        步骤二：建立一个获取的请求
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Holds")
        let sort = NSSortDescriptor.init(key: "create_time", ascending: false)
        fetchRequest.sortDescriptors = [sort]
        fetchRequest.fetchOffset = 0
        fetchRequest.fetchLimit = 30
        //        步骤三：执行请求
        do {
            let fetchedResults = try YJCache.shared.managedObjectContext.fetch(fetchRequest) as? [Holds]
            if let results = fetchedResults {
                return results
            }
            
        } catch  {
            fatalError("读取顾客失败")
        }
        return Array<Holds>()
    }
    static func insert(_ owner:People,_ totalCost:Double,_ stock:Stocks,_ amount:Double,_ buy_date:Date)->Holds{
        let entity = NSEntityDescription.entity(forEntityName: "Holds", in: YJCache.shared.managedObjectContext)!
        let person = Holds.init(entity: entity, insertInto: YJCache.shared.managedObjectContext)
        person.create_time = Date()
        person.setValues(owner, totalCost, stock, amount,buy_date)
        return person

    }
    //更新顾客信息
    func update(_ owner:People,_ totalCost:Double,_ stock:Stocks,_ amount:Double,_ buy_date:Date){
        setValues(owner, totalCost, stock, amount,buy_date)
    }
    func refreshProfit(){
        if self.currentProfit == nil || !(YJConst.isSameDay(Date(), self.currentProfit!.createTime!)){
            let profit = Profits.insert(self)
            self.currentProfit = profit
            self.addToProfits(profit)
        }
        self.currentProfit?.setValues(self)

    }
    func refreshStock(_ enforce:Bool? = false,_ complition:((Bool)-> Void)? = nil){
        stock!.update { [weak self](isUpdated) in
            if !isUpdated && !(enforce ?? false) {complition?(false);return}
            if let person = self {
                person.refreshProfit();
                complition?(true)
            }

        }
        
        
    }
    func setValues(_ owner:People,_ totalCost:Double,_ stock:Stocks,_ amount:Double,_ buy_date:Date){
        self.stock = stock
        self.owner = owner;
        self.total_cost = totalCost;
        self.amount = amount
        self.cost = totalCost / amount
        self.buy_date = buy_date
        self.refreshProfit()
        if self.currentProfit!.days > 0 {
            self.isValued = true
        }
        //setStatistics()
        
    }
    func setStatistics() {
         if let record = statistics?.first(where:{
            YJConst.isSameDay(($0 as! Statistics).create_time!, Date())}) as? Statistics{
            record.update(nil, [self])
        }
        let record = Statistics.insert(nil, [self])
        statistics?.adding(record)        

    }
}
