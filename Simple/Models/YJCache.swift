//
//  YJCache.swift
//  Simple
//
//  Created by JotingYou on 2019/4/10.
//  Copyright © 2019 YouJoting. All rights reserved.
//

import UIKit
import CoreData
class YJCache: NSObject {
    var stocks = Array<Stocks>();
    var people = Array<People>();
    var updateTime = Date()
    static let shared = YJCache();
    let managedObjectContext:NSManagedObjectContext = {
        let container = NSPersistentContainer(name: "Save")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error {

                fatalError("Unresolved error, \((error as NSError).userInfo)")
            }
        })
        return container.viewContext
    }()
//    lazy var stocks_entity: NSEntityDescription = {
//        let appDelegate = UIApplication.shared.delegate as! AppDelegate
//        let managedObjectContext = appDelegate.persistentContainer.viewContext
//        return NSEntityDescription.entity(forEntityName: "Stocks", in: managedObjectContext)!
//        }()
//    lazy var people_entity: NSEntityDescription = {
//        let appDelegate = UIApplication.shared.delegate as! AppDelegate
//        let managedObjectContext = appDelegate.persistentContainer.viewContext
//        return NSEntityDescription.entity(forEntityName: "People", in: managedObjectContext)!
//    }()
    

    ///更新数据
    public func update(){
        //检查更新
        if !checkUpdate() {return}
        //从API获取数据

        //更新数组
        stocks.removeAll();

        //更新时间
        updateTime = Date();
        //存储
        saveStocks();
    }
    ///检查是否需要更新
    public func checkUpdate()->Bool{
        return false;
    }
    //MARK: *Read*
    ///从本地存储中恢复
    static func recovery(){
        //读取顾客信息
        shared.readPeople();
        //恢复股票信息
        let lastTime = UserDefaults.standard.value(forKey: "updateTime" )
        if lastTime == nil {
            shared.updateTime = Date();
        }else{
            shared.updateTime = lastTime as! Date;
        }
        
        if shared.checkUpdate() {
            shared.update();
        }else{
            shared.readStocks();
        }

    }
    ///恢复股票信息
    private func readStocks(){
        //        步骤二：建立一个获取的请求
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Stocks")
        
        //        步骤三：执行请求
        do {
            let fetchedResults = try managedObjectContext.fetch(fetchRequest) as? [Stocks]
            if let results = fetchedResults {
                stocks = results
            }
            
        } catch  {
            fatalError("读取股票失败")
        }
    }
    ///读取顾客信息
    private func readPeople(){
        //        步骤二：建立一个获取的请求
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "People")
        let sort = NSSortDescriptor.init(key: "create_time", ascending: false)
        fetchRequest.sortDescriptors = [sort]
        fetchRequest.fetchOffset = 0
        fetchRequest.fetchLimit = 30
        //        步骤三：执行请求
        do {
            let fetchedResults = try managedObjectContext.fetch(fetchRequest) as? [People]
            if let results = fetchedResults {
                people = results
                for person in people{
                    refresh(person: person)
                }
            }
            
        } catch  {
            fatalError("读取顾客失败")
        }
        
    }
    //MARK: *Save*
    ///将股票信息存储到本地
    private func saveStocks(){
        do {
            try managedObjectContext.save();
        } catch  {
            fatalError("无法保存")
        }
        UserDefaults.standard.setValue(updateTime, forKey: "updateTime");
    }
    ///插入顾客信息
    func insertPerson(name:String,amount:Int64,fund_number:String,value:Double,cost:Double,buy_date:Date){
        let entity = NSEntityDescription.entity(forEntityName: "People", in: managedObjectContext)!
        let person = People.init(entity: entity, insertInto: managedObjectContext)
        person.create_time = Date()
        people.insert(person, at: 0)
        updatePerson(person: person, name: name, amount: amount, fund_number: fund_number, value: value, cost: cost, buy_date: buy_date)
    }
    //更新顾客信息
    func updatePerson(person:People,name:String,amount:Int64,fund_number:String,value:Double,cost:Double,buy_date:Date){
        setValuesFor(person: person, name: name, amount: amount, fund_number: fund_number, value: value, cost: cost, buy_date: buy_date)
        do {
            try managedObjectContext.save();
        } catch  {
            fatalError("无法更新")
        }
    }
    //删除顾客信息
    func deletePersonAt(row:Int){        
        managedObjectContext.delete(people[row])
        people.remove(at: row)
        do {
            try managedObjectContext.save();
        } catch  {
            fatalError("无法删除")
        }
    }
    //MARK: ***Set***
    func refresh(person:People) {
        setValuesFor(person: person, name: person.name!, amount: person.amount, fund_number: person.fund_number!, value: person.value, cost: person.cost, buy_date: person.buy_date!)
    }
    func setValuesFor(person:People,name:String,amount:Int64,fund_number:String,value:Double,cost:Double,buy_date:Date){
        person.name = name;
        person.amount = amount;
        person.fund_number = fund_number;
        person.value = value;
        person.cost = cost;
        person.buy_date = buy_date;
        let calendar = Calendar.init(identifier: Calendar.Identifier.gregorian)
        let components = calendar.dateComponents([.day],  from: buy_date, to: Date())
        person.days = Int16(components.day!)
        if person.days>0 {
            person.isValued = true
            person.profit = (value-cost) * Double(amount);
            person.simple = Float((value-cost) / cost);
            person.annualized = person.simple * 365 / Float(person.days);
        }
        
    }
}
