//
//  YJRecord.swift
//  Simple
//
//  Created by JotingYou on 2019/4/26.
//  Copyright © 2019 YouJoting. All rights reserved.
//

import UIKit
import CoreData

extension Statistics {

    
    static func read() -> Array<Statistics>{
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Statistics")
        let sort = NSSortDescriptor.init(key: "create_time", ascending: false)
        fetchRequest.sortDescriptors = [sort]
        fetchRequest.fetchLimit = 5
        //        步骤三：执行请求
        do {
            let fetchedResults = try  YJCache.shared.managedObjectContext.fetch(fetchRequest) as? [Statistics]
            if let records = fetchedResults {
                return records
            }
            
        } catch  {
            fatalError("读取顾客失败")
        }
        return Array<Statistics>()
    }

    func update()->Bool{
        
        setValuesWith(YJCache.shared.lastRecord,YJCache.shared.people)
        do {
            try YJCache.shared.managedObjectContext.save()
        } catch  {
            print("Update Record failed:Core Date Save Error!")
            return false
        }
        return true
    }
    func removePerson(_ person:People){
        if (self.people?.contains(person) ?? false) {
            setValuesWith(YJCache.shared.lastRecord,YJCache.shared.people)
        }
    }
    func setValuesWith(_ lastRecord:Statistics?,_ people:[People]){
        modified_time = Date()
        total_value = 0
        total_interest = 0
        grouped_rate = 0
        for person in people {
            total_value += person.total_value
            total_interest += person.profit
            if !(self.people?.contains(person) ?? false){
                self.people?.adding(person)
            }
        }
        for person in people {
            person.value_proportion = Float(person.total_value / total_value)
            grouped_rate += person.value_proportion * person.simple
        }
        if lastRecord != nil {
            rate_trend = grouped_rate - lastRecord!.grouped_rate
        }
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: YJConst.recordChangedNotification), object: nil, userInfo: nil)
        
    }
}
