//
//  People+Method.swift
//  Simple
//
//  Created by JotingYou on 2020/3/13.
//  Copyright © 2020 YouJoting. All rights reserved.
//

import UIKit
import CoreData
extension People{
    static func read()->[People]{
        //        步骤二：建立一个获取的请求
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "People")
        //        步骤三：执行请求
        do {
            let fetchedResults = try YJCache.shared.managedObjectContext.fetch(fetchRequest) as? [People]
            if let results = fetchedResults {
                return results
            }
            
        } catch  {
            fatalError("读取People失败")
        }
        return Array<People>()
    }
    static func insert(_ name:String)->People{
        let entity = NSEntityDescription.entity(forEntityName: "People", in: YJCache.shared.managedObjectContext)!
        let person = People.init(entity: entity, insertInto: YJCache.shared.managedObjectContext)
        person.create_time = Date()
        person.setValues(name)
        return person

    }
    func setValues(_ name:String) {
        self.name = name
        self.update_time = Date()
    }
}
