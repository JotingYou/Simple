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
    var record:Statistics?
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
        if shared.checkUpdate() {
            shared.update();
        }else{
            shared.readStocks();
        }
        
        //读取顾客信息
        shared.readPeople();
        
        
        shared.readRecord()
        
        shared.insertRecord()


    }
    //MARK:- People
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
            }
            
        } catch  {
            fatalError("读取顾客失败")
        }
        
    }
    ///插入顾客信息
    func insertPerson(name:String,amount:Double,stock:Stocks,cost:Double,buy_date:Date) -> Bool{
        let entity = NSEntityDescription.entity(forEntityName: "People", in: managedObjectContext)!
        let person = People.init(entity: entity, insertInto: managedObjectContext)
        person.create_time = Date()
        people.insert(person, at: 0)
        return updatePerson(person: person, name: name, amount: amount, stock: stock, cost: cost, buy_date: buy_date)
    }
    //更新顾客信息
    func updatePerson(person:People,name:String,amount:Double,stock:Stocks,cost:Double,buy_date:Date) -> Bool{
        
        person.stock = stock
        
        if !updateValueForStock(stock: stock){
            //TODO: WARNING
        }
        
        setValuesFor(person: person, name: name, amount: amount,stock: stock, cost: cost, buy_date: buy_date)
        
        do {
            try managedObjectContext.save();
        } catch  {
            print("update People failed:CoreData can't save!")
            return false
        }
        return true
    }
    func updateValueForStock(stock:Stocks)->Bool{
        let dic = YJHttpTool.shared.getFundValue(id: stock.id!)
        if dic["status"] == "1"{
            let updateTime = dateFormatter.date(from: dic["updateTime"]!)!
            if stock.update_time! < updateTime{
                stock.unit_value = Double(dic["value"]!)!
                stock.update_time = updateTime
                return true
            }else{
                return false
            }
            
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
    func refreshPeople() -> Bool {
        for person in people {
            refresh(person: person)
        }
        return true
    }
    func refresh(person:People) {
        if updateValueForStock(stock: person.stock!){
            setValuesFor(person: person, name: person.name!, amount: person.amount, stock: person.stock!, cost: person.cost, buy_date: person.buy_date!)
        }else{
            //TODO:WARNING
        }
        
        
    }
    func setValuesFor(person:People,name:String,amount:Double,stock:Stocks,cost:Double,buy_date:Date){
        person.stock = stock
        person.name = name;
        person.amount = amount;
        person.cost = cost;
        person.total_value = stock.unit_value * amount
        person.buy_date = buy_date;
        let calendar = Calendar.init(identifier: Calendar.Identifier.gregorian)
        let components = calendar.dateComponents([.day],  from: buy_date, to: Date())
        person.days = Int16(components.day!)
        if person.days>0 {
            person.isValued = true
            person.profit = (stock.unit_value-cost) * Double(amount);
            person.simple = Float((stock.unit_value-cost) / cost);
            person.annualized = person.simple * 365 / Float(person.days);
        }
        
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
        //        建立一个获取的请求
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Stocks")
        
        //        执行请求
        do {
            let fetchedResults = try managedObjectContext.fetch(fetchRequest) as? [Stocks]
            if fetchedResults?.count == 0 {
                return false
            }
            if let results = fetchedResults {
                stocks = results
            }
            
        } catch  {
            print("CoreData Error:读取股票失败")
            return false
        }
        
        return true
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
        let entity = NSEntityDescription.entity(forEntityName: "Stocks", in: managedObjectContext)!
        let stock = Stocks.init(entity: entity, insertInto: managedObjectContext)
        stock.name = stockString.name
        stock.id = stockString.id
        stock.code = stockString.code
        stock.name_spell = stockString.name_spell
        stock.type = stockString.type
        stocks.insert(stock, at: 0)
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
                record = records[0]
                if records.count > 1{
                    lastRecord = records[1]
                }
            }else{
                lastRecord = records[0]
            }
        }
    }
    private func insertRecord()->Bool{
        if record != nil {
            if YJConst.isSameDay(record!.create_time!, Date()){
                print("Create Statistics record failed:has existed a record today")
                return false
            }
        }
        
        let entity = NSEntityDescription.entity(forEntityName: "Statistics", in: managedObjectContext)
        let record = Statistics.init(entity: entity!, insertInto: managedObjectContext)
        record.create_time = Date()

        
        if  self.record != nil {
            lastRecord = self.record
        }
        self.record = record
        
        if record.update() {
            return false
        }
        
        return true
    }
    
    func refreshRecord() -> Bool{
        return record?.update() ?? false
    }
    
 
    
    
}