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
            fatalError("记录失败")
        }
        return Array<Statistics>()
    }
    
    static func insert(_ lastRecord:Statistics?,_ Holds:[Holds]) -> Statistics {
        
        let entity = NSEntityDescription.entity(forEntityName: "Statistics", in: YJCache.shared.managedObjectContext)
        let record = Statistics.init(entity: entity!, insertInto: YJCache.shared.managedObjectContext)
        record.create_time = Date()
        record.update(lastRecord, Holds)
        return record

    }
    
    func update(_ lastRecord:Statistics?, _ Holds:[Holds]){
        
        setValuesWith(lastRecord,Holds)
//        do {
//            try YJCache.shared.managedObjectContext.save()
//        } catch    let error{
//            print("Update Record failed:Core Date Save Error! \(error)")
//            return false
//        }

    }
    func refreshBasic() {
        YJHttpTool.shared.getBasicRate({[weak self](dic) in
                let now = Double(dic["now"]!)!
                let yesterday = Double(dic["yesterday"]!)!
                self?.basic = now/yesterday - 1
                NotificationCenter.default.post(name: Notification.Name(rawValue: YJConst.recordChangedBasic), object: nil, userInfo: nil)
            }
        
        )
    }

    func setValuesWith(_ lastRecord:Statistics?,_ Holds:[Holds]){
        modified_time = Date()
        total_value = 0
        total_interest = 0
        grouped_rate = 0
        for person in Holds {
            total_value += person.currentProfit!.total_value
            total_interest += person.currentProfit!.profit
        }
        for person in Holds {
            if total_value == 0{
                return
            }
            person.currentProfit!.value_proportion = Float(person.currentProfit!.total_value / total_value)
            grouped_rate += person.currentProfit!.value_proportion * person.currentProfit!.simple
        }
        if lastRecord != nil {
            rate_trend = grouped_rate - lastRecord!.grouped_rate
        }
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: YJConst.recordChangedNotification), object: nil, userInfo: nil)
        
    }
}
