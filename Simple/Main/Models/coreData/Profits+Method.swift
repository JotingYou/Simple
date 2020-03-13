//
//  Profits+Method.swift
//  Simple
//
//  Created by JotingYou on 2020/3/13.
//  Copyright © 2020 YouJoting. All rights reserved.
//

import UIKit
import CoreData
extension Profits{
    static func read()->[Profits]{
        //        步骤二：建立一个获取的请求
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Profits")
        let sort = NSSortDescriptor.init(key: "updateTime", ascending: false)
        fetchRequest.sortDescriptors = [sort]
        fetchRequest.fetchOffset = 0
        fetchRequest.fetchLimit = 30
        //        步骤三：执行请求
        do {
            let fetchedResults = try YJCache.shared.managedObjectContext.fetch(fetchRequest) as? [Profits]
            if let results = fetchedResults {
                return results
            }
            
        } catch  {
            fatalError("读取收益失败")
        }
        return Array<Profits>()
    }
    static func insert(_ owner:Holds)->Profits{
        let entity = NSEntityDescription.entity(forEntityName: "Profits", in: YJCache.shared.managedObjectContext)!
        let profit = Profits.init(entity: entity, insertInto: YJCache.shared.managedObjectContext)
        profit.createTime = Date()
        profit.setValues(owner)
        return profit

    }
    func setValues(_ owner:Holds) {
        self.holds = owner;
        self.total_value = owner.stock!.unit_value * owner.amount
        let calendar = Calendar.init(identifier: Calendar.Identifier.gregorian)
        let components = calendar.dateComponents([.day],  from: owner.buy_date!, to: Date())
        self.days = Int16(components.day!)
        if self.days>0 {
            self.profit = self.total_value - owner.total_cost
            self.simple = Float(self.profit / owner.total_cost);
            self.annualized = self.simple * 365 / Float(self.days);
        }
        self.updateTime = Date()
    }
}
