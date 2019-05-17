//
//  YJCache.swift
//  Simple
//
//  Created by JotingYou on 2019/4/10.
//  Copyright © 2019 YouJoting. All rights reserved.
//

import UIKit
import CoreData
import CocoaLumberjack

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
    

    //MARK: *Recover*
    ///从本地存储中恢复
    static func recovery(){
        //恢复股票信息

        shared.readStocks();
        
        //读取顾客信息
        shared.readPeople();
        
        
        shared.readRecord()
        
        if !shared.insertRecord(){
            shared.updateRecord()
        }

    }
    //MARK:- People
    ///读取顾客信息
    func readPeople() {
        people = People.read()
    }
    ///插入顾客信息
    func insertPerson(_ name:String,_ totalCost:Double,_ stock:Stocks,_ amount:Double,_ buy_date:Date) -> Bool{
        let person = People.insert(name, totalCost, stock, amount, buy_date)
        people.insert(person, at: 0)
        person.refreshStock({(flag) in
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: YJConst.personHasUpdateStock), object: flag)
            
        })
        return save()
    }
    //更新顾客信息
    func updatePerson(_ person:People,_ name:String,_ total_cost:Double,_ stock:Stocks,_ amount:Double,_ buy_date:Date)->Bool{
        person.update(name, total_cost, stock, amount, buy_date)
        person.refreshStock({(flag) in
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: YJConst.personHasUpdateStock), object: flag)
            
        })
        return save()
    }

    //删除顾客信息
    func deletePersonAt(row:Int){
        managedObjectContext.delete(people[row])
        people.remove(at: row)
        saveAndPrint(funcName: #function)
    }
    //MARK: REFRESH
    func refreshPeople(_ complition:(()-> Void)?){
        var num = 0
        for person in people {
            person.refreshStock({[weak self](isUpdated) in
                num += 1
                if num == self?.people.count{
                    self?.saveAndPrint(funcName: #function)
                    complition?()
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
             YJHttpTool.shared.getFundList({ (flag) in
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
            DDLogInfo("Read From CoreData")
            return true
        }
        return false
    }
    open func readStocksFromFile()->Bool{
        
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
        if stocks.count == 0 {
            createStocks(strs: stockStrs)
        }else{
            updateStocks(strs: stockStrs)
        }
        DDLogInfo("Read From File");
        return true
    }
    ///将股票信息存储到本地

    private func insertStock(stockString:YJStockStringObject,_ row:Int = -1){
        if row == -1{
            stocks.append(Stocks.insert(stockString))
        }else{
            stocks.insert(Stocks.insert(stockString), at: row)
        }
    }
    private func createStocks(strs:[String]){
        for str in strs {
            if str.count > 0{
                let obj = YJStockStringObject(str: str)
                insertStock(stockString: obj)
            }
        }
        if !save(){
            DDLogError("\(#function)failed")
        }
    }
    private func updateStocks(strs:[String]){
        autoreleasepool{
            OperationQueue().addOperation {[weak self] in
                var index = 0
                for str in strs {
                    autoreleasepool {
                        if str.count > 0{
                            let obj = YJStockStringObject(str: str)
                            if index < self?.stocks.count ?? 0 {
                                if let stock = self?.stocks[index]{
                                    if stock.id == obj.id {
                                        stock.update(obj)
                                        index += 1
                                    }else if Int(stock.id!)! > Int(obj.id)! {
                                        self?.insertStock(stockString: obj,index)
                                        index += 1
                                    }
                                }
                            }
                        }
                    }
                }
                OperationQueue.main.addOperation {
                    YJProgressHUD.showSuccess(message: "Stock List update finished")
                }
                self?.saveAndPrint(funcName: #function)
            }

        }

    }
    private func saveAndPrint(funcName:String){
        if save(){
            DDLogVerbose("\(funcName) passed")
        }else{
            DDLogError("\(funcName) failed")
        }
    }
    private func save() -> Bool{
        do {
            try managedObjectContext.save();
        } catch let error {
            DDLogError("无法保存:\(error)")
            return false
        }
        return true
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
                DDLogWarn("Create Statistics record failed:has existed a record today")
                return false
            }
            lastRecord = self.totalRecord
        }
        
        let record =  Statistics.insert(lastRecord,people)
        self.totalRecord = record
        return save()
    }
    func refreshRecord(){
        totalRecord?.refreshBasic()
        updateRecord()
    }
    func updateRecord(){
        totalRecord?.update(lastRecord,people)
        saveAndPrint(funcName: #function)
    }
    
 
    
    
}
