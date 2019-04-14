//
//  YJTableViewController.swift
//  Simple
//
//  Created by JotingYou on 2019/4/11.
//  Copyright © 2019 YouJoting. All rights reserved.
//

import UIKit

protocol YJEditViewControllerDelegate:NSObjectProtocol {
    func didFinished();
}

class YJEditViewController: UIViewController,UITextFieldDelegate,UISearchBarDelegate {
    var type = 0//0 for add;1 for edit
    var person:People?
    var indexPath:IndexPath?
    
    weak var delegate:YJEditViewControllerDelegate?
    @IBOutlet weak var nameField: UITextField!
    
    @IBOutlet weak var amountField: UITextField!
    @IBOutlet weak var costField: UITextField!
    @IBOutlet weak var buyField: UITextField!
    
    @IBOutlet weak var fundSearchBar: UISearchBar!
    
    @IBAction func add() {
        let name:String = nameField.text!
        if name.count==0 {
            nameField.becomeFirstResponder()
            return
        }
        guard let amount:Int64 = Int64(amountField.text!)else{
            amountField.becomeFirstResponder()
            return
        }
        guard let fund_number = fundSearchBar.text else{
            fundSearchBar.becomeFirstResponder()
            return
        }
        let value = 100.0//TODO
        guard let cost = Double(costField.text!)else{
            costField.becomeFirstResponder()
            return
        }
        
        let dateFormatter = DateFormatter();
        dateFormatter.dateFormat = "yyyy-MM-dd"
        guard let buy_date:Date = dateFormatter.date(from: buyField.text!)else{
            buyField.becomeFirstResponder()
            return
        }
        if type == 0 {
            //新增顾客
            YJCache.shared.insertPerson(name: name, amount: amount, fund_number: fund_number, value: value, cost: cost, buy_date: buy_date)
        }else{
            //编辑顾客信息
            YJCache.shared.updatePerson(person:person!,name: name, amount: amount, fund_number: fund_number, value: value, cost: cost, buy_date: buy_date)
        }

       self.delegate?.didFinished(); self.navigationController?.popViewController(animated: true)
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.amountField.delegate = self
        self.buyField.delegate = self
        self.costField.delegate = self
        self.nameField.delegate = self
        if type == 1 {
            //填充文本信息
            self.amountField.text = String(person!.amount)
            let dateFormatter = DateFormatter();
            dateFormatter.dateFormat = "yyyy-MM-dd"
            self.buyField.text = dateFormatter.string(from: person!.buy_date!)
            self.costField.text = String(person!.cost)
            self.nameField.text = String(person!.name!)
            self.title = "Edit"
        }else{
            let dateFormatter = DateFormatter();
            dateFormatter.dateFormat = "yyyy-MM-dd"
            self.buyField.text = dateFormatter.string(from: Date())
        }
    }
    // MARK: - TextField delagate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        add()
        return true
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
