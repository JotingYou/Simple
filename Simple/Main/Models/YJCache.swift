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
    var stocks = Array<Stocks>()
    let dateFormatter:DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }()
    var totalRecord:Statistics?
    var lastRecord:Statistics?
    
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
    //MARK: *Recover*
    ///从本地存储中恢复
    static func recovery(){
        //恢复股票信息
        let lastTime = UserDefaults.standard.value(forKey: "updateTime" )
        if lastTime == nil {
            shared.updateTime = Date();
        }else{
            shared.updateTime = lastTime as! Date;
        }

        shared.readStocks();
        
        //读取顾客信息
        shared.readPeople();
        
        
        shared.readRecord()
        
        shared.insertRecord()


    }
    //MARK:- People
    ///读取顾客信息
    func readPeople() {
        people = People.read()
    }
    ///插入顾客信息
    func insertPerson(_ name:String,_ amount:Double,_ stock:Stocks,_ cost:Double,_ buy_date:Date) -> Bool{
        if let person = People.insert(name, amount, stock, cost, buy_date) {
            people.insert(person, at: 0)
            return true
        }
        return false
    }
    //更新顾客信息
    func updatePerson(person:People,name:String,amount:Double,stock:Stocks,cost:Double,buy_date:Date) -> Bool{
        
        return person.update(name, amount, stock, cost, buy_date)
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
    //MARK: REFRESH
    func refreshPeople() -> Bool {
        for person in people {
            person.refreshStock()
        }
        return true
    }


    //MARK:- Stocks
    ///读取股票信息
    private func readStocks(){
        if readStocksFromCoreData() {
            print("Read From CoreData")
        }else if readStocksFromFile(){
            print("Read From File")
        }else{
            stocks = YJHttpTool.shared.getData()
        }
    }
    private func readStocksFromCoreData()->Bool{
        if let results = Stocks.readFromCoreDate() {
            stocks = results
            return true
        }
        return false
    }
    private func readStocksFromFile()->Bool{
        let url = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("fundcode_search.js")
        
        var data = NSData.init(contentsOf: url)
        
        if data == nil {
            let  path = Bundle.main.path(forResource: "fundcode_search", ofType: "js")!
            
            data = NSData.init(contentsOfFile: path)
        }
        
        guard let content = String.init(data: data! as Data, encoding: String.Encoding.utf8)else{
            return false
        }
        guard let startRange = content.range(of: "var r = [")else{
            return false
        }
        guard let endRange = content.range(of: "];") else{
            return false
        }
        let original = content[startRange.upperBound...endRange.lowerBound]
        let stockStrs = original.components(separatedBy: "]")
        for str in stockStrs {
            if str.count > 0{
                let obj = YJStockStringObject.init(str: str)
                insertStock(stockString: obj)
            }
            
        }
        saveStocks()
        return true
    }
    ///将股票信息存储到本地
    private func insertStock(stockString:YJStockStringObject){

        stocks.insert(Stocks.insert(stockString), at: 0)
    }

    private func saveStocks(){
        do {
            try managedObjectContext.save();
        } catch  {
            fatalError("无法保存")
        }
        UserDefaults.standard.setValue(updateTime, forKey: "updateTime");
    }
    //MARK:- Statistics
    private func readRecord(){
        let records = Statistics.read()
        if records.count > 0{
            if YJConst.isSameDay(Date(), records[0].create_time!){
                totalRecord = records[0]
                if records.count > 1{
                    lastRecord = records[1]
                }
            }else{
                lastRecord = records[0]
            }
        }
    }
    private func insertRecord()->Bool{
        if totalRecord != nil {
            if YJConst.isSameDay(totalRecord!.create_time!, Date()){
                print("Create Statistics record failed:has existed a record today")
                return false
            }
            lastRecord = self.totalRecord
        }
        
        guard let record =  Statistics.insert(lastRecord,people) else {
            return false
        }
    
        self.totalRecord = record

        return true
    }
    
    func updateRecord(){
        totalRecord?.update(lastRecord,people)
    }
    
 
    
    
}
