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

class YJEditViewController: UIViewController,UITextFieldDelegate,UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource {

    
    var type = 0//0 for add;1 for edit
    var person:People?
    var indexPath:IndexPath?
    
    weak var delegate:YJEditViewControllerDelegate?
    var isSearching = false
    var searchResults = Array<Stocks>()
    
    @IBOutlet weak var displayView: UITableView!
    @IBOutlet weak var nameField: UITextField!
    
    @IBOutlet weak var amountField: UITextField!
    @IBOutlet weak var costField: UITextField!
    @IBOutlet weak var buyField: UITextField!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    
    @IBAction func add() {
        let name:String = nameField.text!
        if name.count==0 {
            nameField.becomeFirstResponder()
            return
        }
        guard let amount:Double = Double(amountField.text!)else{
            amountField.becomeFirstResponder()
            return
        }
        let fund_number = searchBar.text!
        filterContentForSearchText(fund_number)
        if searchResults.count == 0 {
            searchBar.becomeFirstResponder()
            return 
        }
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
            YJCache.shared.insertPerson(name: name, amount: amount, fund_number: fund_number,  cost: cost, buy_date: buy_date)
        }else{
            //编辑顾客信息
            YJCache.shared.updatePerson(person:person!,name: name, amount: amount, fund_number: fund_number,  cost: cost, buy_date: buy_date)
        }

       self.delegate?.didFinished(); self.navigationController?.popViewController(animated: true)
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setFields()
        setSearchBar()
    }
    // MARK: - Set Views
    func setFields(){
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
            searchBar.text = person?.fund_number
        }else{
            let dateFormatter = DateFormatter();
            dateFormatter.dateFormat = "yyyy-MM-dd"
            self.buyField.text = dateFormatter.string(from: Date())
        }
    }
    func setSearchBar() {
        searchBar.delegate = self
        searchBar.searchBarStyle = .minimal
        //searchBar.scopeButtonTitles = ["Number","Name"]
        searchBar.scopeBarBackgroundImage = UIImage()
    }
    func setDidplayView(){
        displayView.isHidden = true
    }
    // MARK: - Search delegate
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchBar.text!, scope: selectedScope)
    }
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
        //searchBar.showsScopeBar = true
        displayView.isHidden = false
        isSearching = true
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        searchBar.endEditing(true)
        displayView.isHidden = true
    }
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        isSearching = false
        //searchBar.showsScopeBar = false
        searchBar.setShowsCancelButton(false, animated: true)
    }
    func isFiltering() -> Bool {
        return isSearching && !searchBarIsEmpty()
    }
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchBar.text?.isEmpty ?? true
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterContentForSearchText(searchText,scope: searchBar.selectedScopeButtonIndex)
        displayView.reloadData()
    }
    func filterContentForSearchText(_ searchText: String, scope: Int = 0) {
        searchResults = YJCache.shared.stocks.filter({( stock : Stocks) -> Bool in
            if searchBarIsEmpty(){
                return false
            }else if(scope == 0){
                return stock.id?.lowercased().contains(searchText.lowercased()) ?? false
            }else{
                return stock.name?.lowercased().contains(searchText.lowercased()) ?? false
            }
        })
    }
    // MARK: - TextField delagate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        add()
        return true
    }
    //MARK: -tableView Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        searchBar.text = searchResults[indexPath.row].id
        searchBar.endEditing(true)
        displayView.isHidden = true
    }
    //MARK: - tableView data source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reuseid = "stockCell"
        
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseid) ?? {
            let cell = UITableViewCell.init(style: .value1, reuseIdentifier: reuseid)
            return cell
            }()
        let stock = searchResults[indexPath.row]
        
        cell.textLabel?.text = stock.id
        cell.detailTextLabel?.text = stock.name
        
        return cell
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
