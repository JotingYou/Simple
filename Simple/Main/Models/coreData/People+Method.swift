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
    static func insert(_ name:String,_ amount:Double,_ stock:Stocks,_ cost:Double,_ buy_date:Date)->People?{
        let entity = NSEntityDescription.entity(forEntityName: "People", in: YJCache.shared.managedObjectContext)!
        let person = People.init(entity: entity, insertInto: YJCache.shared.managedObjectContext)
        person.create_time = Date()
        if person.update(name, amount, stock, cost,buy_date){
            return person
        }else{
            return nil
        }
    }
    //更新顾客信息
    func update(_ name:String,_ amount:Double,_ stock:Stocks,_ cost:Double,_ buy_date:Date) -> Bool{
        
        self.stock = stock
        
        if !stock.update(){
            //TODO: WARNING
        }
        
        setValues(name,amount,stock,cost,buy_date)
        
        do {
            try YJCache.shared.managedObjectContext.save();
        } catch  {
            print("update People failed:CoreData can't save!")
            return false
        }
        return true
    }
    func refreshStock() {
        if stock!.update(){
            setValues(name!, amount,stock!,cost,buy_date!)
        }else{
            //TODO:WARNING
        }
        
        
    }
    func setValues(_ name:String,_ amount:Double,_ stock:Stocks,_ cost:Double,_ buy_date:Date){
        self.stock = stock
        self.name = name;
        self.amount = amount;
        self.cost = cost;
        self.total_value = stock.unit_value * amount
        self.buy_date = buy_date;
        let calendar = Calendar.init(identifier: Calendar.Identifier.gregorian)
        let components = calendar.dateComponents([.day],  from: buy_date, to: Date())
        self.days = Int16(components.day!)
        if self.days>0 {
            self.isValued = true
            self.profit = (stock.unit_value-cost) * Double(amount);
            self.simple = Float((stock.unit_value-cost) / cost);
            self.annualized = self.simple * 365 / Float(self.days);
        }
        setStatistics()
        
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
