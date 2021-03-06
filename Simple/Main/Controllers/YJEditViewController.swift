//
//  YJTableViewController.swift
//  Simple
//
//  Created by JotingYou on 2019/4/11.
//  Copyright © 2019 YouJoting. All rights reserved.
//

import UIKit
import CocoaLumberjack
protocol YJEditViewControllerDelegate:NSObjectProtocol {
    ///tag:0 for add;1 for edit
    func didFinished(tag:Int,indexPath:IndexPath?);
}

class YJEditViewController: UIViewController,UITextFieldDelegate,UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource {

    
    var type = 0//0 for add;1 for edit
    var person:Holds?
    var indexPath:IndexPath?
    
    weak var delegate:YJEditViewControllerDelegate?
    var isSearching = false
    var searchResults = Array<Stocks>()

    var datePicker: UIDatePicker?
    
    @IBOutlet weak var displayView: UITableView!
    @IBOutlet weak var nameField: UITextField!
    
    @IBOutlet weak var dateField: UITextField!
    @IBOutlet weak var totalCostField: UITextField!
    @IBOutlet weak var amountField: UITextField!
   // @IBOutlet weak var feeField:UITextField!
    
    @IBOutlet weak var stockLabel: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    
    lazy var searchBarActiveContraints:[NSLayoutConstraint] = {
        var array = Array<NSLayoutConstraint>()
        let top = NSLayoutConstraint.init(item: searchBar, attribute: .top, relatedBy: .equal, toItem: view, attribute: .topMargin, multiplier: 1, constant: 0)
        let leading = NSLayoutConstraint.init(item: searchBar, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0)
        let trailing = NSLayoutConstraint.init(item: searchBar, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0)
        array.append(top)
        array.append(leading)
        array.append(trailing)
        return array
    }()
    lazy var searchBarNormalContraints:[NSLayoutConstraint] = {
        var array = Array<NSLayoutConstraint>()
        let horion = NSLayoutConstraint.init(item: searchBar, attribute:.centerY , relatedBy: .equal, toItem: stockLabel, attribute: .centerY, multiplier: 1, constant: 0)
        let leading = NSLayoutConstraint.init(item: searchBar, attribute: .leading, relatedBy: .equal, toItem:stockLabel, attribute: .trailing, multiplier: 1, constant: 5)
        let trailing = NSLayoutConstraint.init(item: searchBar, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: -15)
        array.append(horion)
        array.append(leading)
        array.append(trailing)
        return array
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        setFields()
        setSearchBar()
        setDatePicker()
        
    }
    // MARK: - Actions
    @IBAction func add() {
        let name:String = nameField.text!
        if name.count==0 {
            nameField.becomeFirstResponder()
            return
        }
        guard let totalCost:Double = Double(totalCostField.text!)else{
            totalCostField.becomeFirstResponder()
            return
        }
        let fund_number = searchBar.text!
        filterContentForSearchText(fund_number)
        if searchResults.count == 0 {
            DDLogDebug("请选择基金")
            searchBar.becomeFirstResponder()
            return
        }
        let stock = searchResults.first
        guard let amount = Double(amountField.text!)else{
            amountField.becomeFirstResponder()
            return
        }
        
        guard let buy_date:Date = YJCache.shared.dateFormatter.date(from: dateField.text!)else{
            dateField.becomeFirstResponder()
            return
        }

        
        if type == 0 {
            //新增顾客
            if !YJCache.shared.insertHolds(name,totalCost,stock!,amount, buy_date){
                YJProgressHUD.showError(message: "创建用户失败")
                return
            }
        }else{
            //编辑顾客信息
            if !YJCache.shared.updateHolds(person!,name, totalCost, stock!, amount,buy_date)
            {
                YJProgressHUD.showError(message: "更新用户信息失败")
                return
            }
        }
        
        self.delegate?.didFinished(tag:type,indexPath: indexPath)
        self.navigationController?.popViewController(animated: true)
        
    }
    // MARK: - Set Views
    func setDatePicker(){
        datePicker = UIDatePicker()
        datePicker?.datePickerMode = .date
        datePicker?.locale = Locale.init(identifier: "zh")
        datePicker?.maximumDate = Date()
        
        datePicker?.date = YJCache.shared.dateFormatter.date(from: dateField.text!)!
        
        dateField.inputView = datePicker!
        datePicker?.addTarget(self, action: #selector(chooseDate), for: .valueChanged)
    }
    @objc func chooseDate(){
        dateField.text = YJCache.shared.dateFormatter.string(from: (datePicker?.date)!)
    }
    func setFields(){
        self.totalCostField.delegate = self
        self.amountField.delegate = self
        self.nameField.delegate = self
        self.dateField.delegate = self
        if type == 1 {
            //填充文本信息
            self.totalCostField.text = String(person!.total_cost)
            dateField.text = YJCache.shared.dateFormatter.string(from: person!.buy_date!)
            self.amountField.text = String(person!.amount)
            self.nameField.text = String(person!.owner!.name!)
            self.title = NSLocalizedString("Edit", comment: "")
            searchBar.text = person?.stock?.id
            //self.feeField.text = String(person!.fee_rate * 100)
            
        }else{

            dateField.text = YJCache.shared.dateFormatter.string(from: Date())
        }
    }
    func setSearchBar() {
        searchBar.delegate = self
        searchBar.searchBarStyle = .minimal
        searchBar.scopeButtonTitles = [NSLocalizedString("Stock Number", comment: ""),NSLocalizedString("Stock Name", comment: "")]
        view.addConstraints(searchBarNormalContraints)
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
        searchBar.showsScopeBar = true
        displayView.isHidden = false
        view.bringSubviewToFront(displayView)
        isSearching = true
        searchBarMoveToTop()
        
    }
    func searchBarMoveToTop() {
        view.removeConstraints(searchBarNormalContraints)
        view.addConstraints(searchBarActiveContraints)
        
    }
    func searchBarGoBack() {
        view.removeConstraints(searchBarActiveContraints)
        view.addConstraints(searchBarNormalContraints)

    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        searchBar.endEditing(true)
        displayView.isHidden = true
        searchBarGoBack()

    }
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        isSearching = false
        searchBar.showsScopeBar = false
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
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.tag == 3 {
            return false
        }
        return true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        add()
        return true
    }
    //MARK: -tableView Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        searchBar.text = searchResults[indexPath.row].id
        searchBar.endEditing(true)
        searchBarGoBack()
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
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchBar.resignFirstResponder()
    }
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    

}
