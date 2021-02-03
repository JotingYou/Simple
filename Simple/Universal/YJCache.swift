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
    
    var holds = Array<Holds>();
    lazy var saledHolds = Holds.readSaled()
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
        shared.readHolds();
        
        
        shared.readRecord()
        
        if !shared.insertRecord(){
            shared.updateRecord()
        }

    }
    //MARK:- Holds
    ///读取顾客信息
    func readHolds() {
        holds = Holds.read()
    }
    ///插入顾客信息
    func insertHolds(_ name:String,_ totalCost:Double,_ stock:Stocks,_ amount:Double,_ buy_date:Date) -> Bool{
        let person = People.insert(name)
        let hold = Holds.insert(person, totalCost, stock, amount, buy_date)
        holds.insert(hold, at: 0)
        hold.refreshStock(false,{(flag) in
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: YJConst.personHasUpdateStock), object: flag)
            
        })
        return save()
    }
    //更新顾客信息
    func updateHolds(_ hold:Holds,_ name:String,_ total_cost:Double,_ stock:Stocks,_ amount:Double,_ buy_date:Date)->Bool{
        hold.owner?.name = name;
        hold.update(hold.owner!, total_cost, stock, amount, buy_date)
        hold.refreshStock(false,{(flag) in
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: YJConst.personHasUpdateStock), object: flag)
            
        })
        return save()
    }
    //卖出持有股票
    func saleHoldsAt(row:Int){
        //managedObjectContext.delete(holds[row])
        let hold = holds[row]
        hold.is_saled = true
        holds.remove(at: row)
        if !saledHolds.contains(hold) {
            saledHolds.insert(hold, at: 0)
        }
        saveAndPrint(funcName: #function)
    }
    //删除持有信息
    func deleteHoldsAt(hold:Holds){
        //managedObjectContext.delete(holds[row])
        hold.is_deleted = true
        if let row = saledHolds.index(of: hold){
            saledHolds.remove(at: row)
        }

        if let row = holds.index(of: hold){
            holds.remove(at: row)
        }
        saveAndPrint(funcName: #function)
    }
    //MARK: REFRESH
    func refreshHolds(enforce:Bool?,_ complition:(()-> Void)?){
        var num = 0
        for person in holds {
            person.refreshStock(enforce ?? false,{[weak self](isUpdated) in
                num += 1
                if num == self?.holds.count{
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
            DDLogDebug("\(YJConst.localFundPath)")
            data = NSData.init(contentsOfFile: YJConst.localFundPath)
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
        deleteRepeatStock()
        if !save(){
            DDLogError("\(#function)failed")
        }
    }
    private func updateStocks(strs:[String]){
        autoreleasepool{
            OperationQueue().addOperation {[weak self] in
                guard let wself = self else{
                    DDLogWarn("\(#function) failed:YJChache has been deinit!")
                    return
                }
                var i = 0
                var j = 0
                while( j < strs.count ){
                    autoreleasepool {
                        let str = strs[j]
                        if str.count > 0{
                            let obj = YJStockStringObject(str: str)
                            if i < wself.stocks.count{
                                if let stock = self?.stocks[i]{
                                    if stock.id == obj.id {
                                        //已存在数据，更新
                                        stock.update(obj)
                                        i += 1
                                        j += 1
                                    }else if Int(stock.id!)! > Int(obj.id)! {
                                        //新数据，插入
                                        self?.insertStock(stockString: obj,i)
                                        i += 1
                                        j += 1
                                    }else{
                                        //缺少数据，跳过
                                        i += 1
                                    }
                                }
                            }else{
                                //新数据，插入
                                wself.insertStock(stockString: obj,i)
                                i += 1
                                j += 1
                            }
                        }else{
                            j += 1
                        }
                    }
                }
                wself.deleteRepeatStock()
                OperationQueue.main.addOperation {
                    YJProgressHUD.showSuccess(message: "Stock List update finished")
                }
                self?.saveAndPrint(funcName: #function)
            }

        }

    }
    private func deleteRepeatStock(){
        var i = 0
        while i < stocks.count {
            for j in i+1..<stocks.count{
                if stocks[i].id == stocks[j].id{
                    DDLogWarn("Stock:\(stocks[j].id!) has been deleted")
                    managedObjectContext.delete(stocks[j])
                    stocks.remove(at: j)
                }else{
                    break
                }
            }
            i += 1
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
        
        let record =  Statistics.insert(lastRecord,holds)
        self.totalRecord = record
        return save()
    }
    func refreshRecord(){
        totalRecord?.refreshBasic()
        updateRecord()
    }
    func updateRecord(){
        totalRecord?.update(lastRecord,holds)
        saveAndPrint(funcName: #function)
    }
    
 
    
    
}
