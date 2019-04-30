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
        if let person = People.insert(name, totalCost, stock, amount, buy_date) {
            people.insert(person, at: 0)

            return true
        }
        return false
    }
    //更新顾客信息
    func updatePerson(_ person:People,_ name:String,_ total_cost:Double,_ stock:Stocks,_ amount:Double,_ buy_date:Date)->Bool{
        if person.update(name, total_cost, stock, amount, buy_date){
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
    func refreshPeople(_ complition:(()-> Void)?){
        var num = 0
        for person in people {
            person.refreshStock({[weak self](isUpdated) in
                num += 1
                if num == self?.people.count{
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
            print("Read From CoreData")
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
        print("Read From File");
        return true
    }
    ///将股票信息存储到本地
    private func createStocks(strs:[String]){
            for str in strs {
                if str.count > 0{
                    let obj = YJStockStringObject(str: str)
                    insertStock(stockString: obj)
                }
            }        
            saveStocks()
    }
    private func insertStock(stockString:YJStockStringObject){
        stocks.insert(Stocks.insert(stockString), at: 0)
    }
    private func updateStocks(strs:[String]){
        OperationQueue().addOperation {[weak self] in
            for str in strs {
                if str.count > 0{
                    let obj = YJStockStringObject(str: str)
                    if let stock = self?.stocks.first(where: {$0.id == obj.id}){
                        stock.update(obj)
                        continue
                    }
                    self?.insertStock(stockString: obj)
                }
            }
            OperationQueue.main.addOperation {
                YJProgressHUD.showSuccess(message: "Stock List update finished")
                self?.saveStocks()
            }
        }

    }
    private func saveStocks(){
        do {
            try managedObjectContext.save();
        } catch let error {
            fatalError("无法保存:\(error)")
        }
        
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
    func refreshRecord(){
        totalRecord?.refreshBasic()
        updateRecord()
    }
    func updateRecord(){
        totalRecord?.update(lastRecord,people)
    }
    
 
    
    
}
