//
//  People+Method.swift
//  Simple
//
//  Created by JotingYou on 2019/4/27.
//  Copyright © 2019 YouJoting. All rights reserved.
//

import UIKit
import CoreData
extension People {
    static func read()->[People]{
        //        步骤二：建立一个获取的请求
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "People")
        let sort = NSSortDescriptor.init(key: "create_time", ascending: false)
        fetchRequest.sortDescriptors = [sort]
        fetchRequest.fetchOffset = 0
        fetchRequest.fetchLimit = 30
        //        步骤三：执行请求
        do {
            let fetchedResults = try YJCache.shared.managedObjectContext.fetch(fetchRequest) as? [People]
            if let results = fetchedResults {
                return results
            }
            
        } catch  {
            fatalError("读取顾客失败")
        }
        return Array<People>()
    }
    static func insert(_ name:String,_ totalCost:Double,_ stock:Stocks,_ amount:Double,_ buy_date:Date)->People?{
        let entity = NSEntityDescription.entity(forEntityName: "People", in: YJCache.shared.managedObjectContext)!
        let person = People.init(entity: entity, insertInto: YJCache.shared.managedObjectContext)
        person.create_time = Date()
        if person.update(name, totalCost, stock, amount,buy_date){
            return person
        }else{
            return nil
        }
    }
    //更新顾客信息
    func update(_ name:String,_ totalCost:Double,_ stock:Stocks,_ amount:Double,_ buy_date:Date)->Bool{
        
        self.stock = stock
        setValues(name,totalCost,stock,amount,buy_date)
        do {
            try YJCache.shared.managedObjectContext.save();
        } catch  {
            print("update People failed:CoreData can't save!")
            return false
        }
        
        return true
    }

    func refreshStock(_ complication:((Bool)-> Void)? = nil){
        stock!.update { [weak self](isUpdated) in
            if !isUpdated {complication?(false);return}
            guard let person = self else{
                return
            }
            person.setValues(person.name!, person.total_cost,person.stock!,person.amount,person.buy_date!)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: YJConst.personHasUpdateStock), object: self)
            complication?(true)
        }
        
        
    }
    func setValues(_ name:String,_ totalCost:Double,_ stock:Stocks,_ amount:Double,_ buy_date:Date){
        self.stock = stock
        self.name = name;
        self.total_cost = totalCost;
        self.amount = amount
        self.cost = totalCost / amount
        self.total_value = stock.unit_value * amount
        self.buy_date = buy_date;
        let calendar = Calendar.init(identifier: Calendar.Identifier.gregorian)
        let components = calendar.dateComponents([.day],  from: buy_date, to: Date())
        self.days = Int16(components.day!)
        if self.days>0 {
            self.isValued = true
            self.profit = self.total_value - self.total_cost
            self.simple = Float(self.profit / self.total_cost);
            self.annualized = self.simple * 365 / Float(self.days);
        }
        //setStatistics()
        
    }
    func setStatistics() {
        let records = statistics?.filter({ return YJConst.isSameDay(($0 as! Statistics).create_time!, Date())
        })
        if let record:Statistics = records?.first as? Statistics {
            
            if record.update(nil, [self]){
                return
            }
        }
        if let record = Statistics.insert(nil, [self]){
            statistics?.adding(record)
        }

    }
}
