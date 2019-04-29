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

//        YJHttpTool.shared.getBasicRate { (rate) in
//            print(rate)
//        }

    }
    //MARK:- People
    ///读取顾客信息
    func readPeople() {
        people = People.read()
    }
    ///插入顾客信息
    func insertPerson(_ name:String,_ totalCost:Double,_ stock:Stocks,_ amount:Double,_ buy_date:Date) -> Bool{
        if let person = People.insert(name, totalCost, stock, amount, buy_date) {
            people.insert(person, at: 0)
            person.refreshStock()
            return true
        }
        return false
    }
    //更新顾客信息
    func updatePerson(_ person:People,_ name:String,_ total_cost:Double,_ stock:Stocks,_ amount:Double,_ buy_date:Date)->Bool{
        if person.update(name, total_cost, stock, amount, buy_date){
            person.refreshStock()
            return true
        }else{
            return false
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
    //MARK: REFRESH
    func refreshPeople(_ complication:(()-> Void)?){
        var num = 0
        for person in people {
            person.refreshStock({[weak self](isUpdated) in
                num += 1
                if num == self?.people.count{
                    complication?()
                }
            })
        }
    }


    //MARK:- Stocks
    ///读取股票信息
    private func readStocks(){
        if readStocksFromCoreData() {
        }else if readStocksFromFile(){
        }else{
             YJHttpTool.shared.getFundInfo(success: { (flag) in
                if(flag){
                    if self.readStocksFromFile() {
                        return
                    }
                }
                fatalError("Read Stocks failed")
                
            })
        }
    }
    private func readStocksFromCoreData()->Bool{
        if let results = Stocks.readFromCoreDate() {
            stocks = results
            print("Read From CoreData")
            return true
        }
        return false
    }
    private func readStocksFromFile()->Bool{
        
        var data = NSData.init(contentsOf: YJConst.fundFileUrl)
        
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
        print("Read From File")
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
