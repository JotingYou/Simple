//
//  YJMainViewController.swift
//  Simple
//
//  Created by JotingYou on 2019/4/10.
//  Copyright © 2019 YouJoting. All rights reserved.
//

import UIKit
import FoldingCell

class YJMainViewController: UITableViewController,YJEditViewControllerDelegate,UISearchBarDelegate,UISearchResultsUpdating,YJFoldingCellDelegate,YJDetailTVCDelegate {

    
    var searchResults = Array<People>()
    let headerView = YJMainHeaderView.init(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: YJConst.headerHeight))
    
    lazy var normalCellHeights:[CGFloat] = (0..<YJCache.shared.people.count).map { _ in YJConst.closeCellHeight }
    lazy var searchCellHeights:[CGFloat] = (0..<searchResults.count).map { _ in YJConst.closeCellHeight }
    lazy var searchController:UISearchController = {
        let searchController = UISearchController.init(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = true
        definesPresentationContext = true
        searchController.obscuresBackgroundDuringPresentation = false

        return searchController
    }()

    lazy var searchBar: UISearchBar = {
        let searchBar = searchController.searchBar
        searchBar.searchBarStyle = .minimal
        searchBar.scopeButtonTitles = [NSLocalizedString("Name", comment: ""),NSLocalizedString("Stock Number", comment: ""),NSLocalizedString("Stock Name", comment: "")]
        searchBar.tintColor = .white
        return searchBar
    }()

    

    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 11.0, *) {
            navigationItem.searchController = searchController
        } else {
            navigationItem.titleView?.addSubview(searchBar)
        }
        extendedLayoutIncludesOpaqueBars = true
        
        searchBar.delegate = self
        
        setTableView()
        setRefresh()

    }
    //MARK: - REFRESH
    func setTableView() {
        tableView.rowHeight = UITableView.automaticDimension
        tableView.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "background"))
        //fix odd scroll bug
        self.tableView.estimatedRowHeight = 0;
        self.tableView.estimatedSectionHeaderHeight = 0;
        self.tableView.estimatedSectionFooterHeight = 0;
    }
    func setRefresh() {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .white
        refreshControl.addTarget(self, action: #selector(refreshStateChange), for: .valueChanged)
        tableView.addSubview(refreshControl)
        refreshDataAndView()
    }
    @objc func refreshStateChange(_ refreshControl:UIRefreshControl) {
        let deadlineTime = DispatchTime.now() + .seconds(1)
        DispatchQueue.main.asyncAfter(deadline: deadlineTime, execute: { [weak self] in
            refreshControl.endRefreshing()
            self?.refreshDataAndView()

        })

    }
    func refreshDataAndView() {
        YJCache.shared.updateRecord()
        if YJCache.shared.refreshPeople() {
            self.tableView.reloadData()
        }
    }
    //MARK: -
    //MARK: searchBar Delegate
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchBar.text!, scope: selectedScope)
    }
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
        searchBar.showsScopeBar = true
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.endEditing(true)
    }
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: Int) {
        searchResults = YJCache.shared.people.filter({( person : People) -> Bool in
            if searchBarIsEmpty(){
                return false
            }else if(scope == 0){
                return person.name?.lowercased().contains(searchText.lowercased()) ?? false
            }else if(scope == 1){
                return person.stock!.id?.lowercased().contains(searchText.lowercased()) ?? false
            }else{
                return person.stock!.name?.lowercased().contains(searchText.lowercased()) ?? false
            }
        })
    }

    //MARK: searchController Delegate
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!,scope: searchBar.selectedScopeButtonIndex)
        searchCellHeights = (0..<searchResults.count).map { _ in YJConst.closeCellHeight }
        tableView.reloadData()
    }
    //MARK: -
    //MARK: tableview
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return headerView
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return YJConst.headerHeight
    }
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if case let cell as YJFoldingCell = cell {
            let cellHeight:CGFloat = {
                if isFiltering() {
                    return searchCellHeights[indexPath.row]
                }else{
                    return normalCellHeights[indexPath.row]
                }
            }()
            
            if cellHeight == YJConst.closeCellHeight {
                cell.isUnfolded = false
                cell.unfold(false, animated: false, completion: nil)
            } else {
                cell.isUnfolded = true
                cell.unfold(true, animated: false, completion: nil)
            }
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if isFiltering() {
            return searchCellHeights[indexPath.row]
        }else{
            return normalCellHeights[indexPath.row]
        }

    }
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        if isFiltering() {
            return false
        }
        return true
    }
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            YJCache.shared.deletePersonAt(row: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            normalCellHeights.remove(at: indexPath.row)
            YJCache.shared.updateRecord()
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return searchResults.count
        }
        return YJCache.shared.people.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var person = YJCache.shared.people[indexPath.row]
        if isFiltering() {
            person = searchResults[indexPath.row]
        }
        let reusableID = "personCell"
        guard let cell:YJFoldingCell = tableView.dequeueReusableCell(withIdentifier: reusableID) as? YJFoldingCell else {
            let cell = YJFoldingCell.init(style: .value1, reuseIdentifier: "personCell")
            cell.setPerson(person: person)
            cell.delegate = self
            return cell
        }
        cell.setPerson(person: person)
        let durations: [TimeInterval] = [0.26, 0.2, 0.2,0.2,0.2]
        cell.durationsForExpandedState = durations
        cell.durationsForCollapsedState = durations
        cell.delegate = self
        return cell
    }
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        performSegue(withIdentifier: "toDetail", sender: indexPath)
//    }
    
    // MARK: - Navigation
    func showDetail(cell: YJFoldingCell) {
        guard let index = self.tableView.indexPath(for: cell) else {
            return
        }
//        let sender = ["type":1,"indexPath":index,"person":cell.person!] as [String : Any]
        let sender = index
        
        performSegue(withIdentifier: "toDetail", sender: sender)
    }
    @IBAction func toAdd(_ sender: Any) {
        performSegue(withIdentifier: "toEdit", sender: ["type":0])
    }
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination.isKind(of: YJEditViewController.self) {
            let dest:YJEditViewController = segue.destination as! YJEditViewController
            guard let dic = sender as? [String:Any] else{
                return
            }
            guard let type = dic["type"] as? Int else{
                return
            }
            dest.type = type
            dest.delegate = self
            if type == 1{
                guard let indexPath = dic["indexPath"] as? IndexPath else{
                    return
                }
                guard let person = dic["person"] as? People else{
                    return
                }
                dest.indexPath = indexPath
                dest.person = person
            }
        }
        else if segue.destination.isKind(of: YJDetailTableViewController.self){
            let dest = segue.destination as! YJDetailTableViewController
            if let index:IndexPath = sender as? IndexPath {
                if isFiltering(){
                    dest.person = searchResults[index.row]
                }else{
                    dest.person = YJCache.shared.people[index.row]

                }
                dest.delegate = self
                dest.indexPath = index
            }

        }
    }
 
    //MARK: -
    //MARK: Custom Delegate
    func foldCell(cell:YJFoldingCell){
        self.tableView.isUserInteractionEnabled = false
        guard let indexPath = self.tableView.indexPath(for: cell)else{
            return
        }        
        var duration = 0.0

        if !cell.isUnfolded {
            if isFiltering() {
                searchCellHeights[indexPath.row] = YJConst.openCellHeight
            }else{
                normalCellHeights[indexPath.row] = YJConst.openCellHeight
            }
//            if rectInScreen.maxY + YJConst.openCellHeight - YJConst.closeCellHeight > UIScreen.main.bounds.height{
//                self.tableView.scrollToRow(at: indexPath, at:.top , animated: true)
//            }
            cell.unfold(true, animated: true, completion: nil)
            duration = 0.5
        } else {
            if isFiltering() {
                searchCellHeights[indexPath.row] = YJConst.closeCellHeight
            }else{
                normalCellHeights[indexPath.row] = YJConst.closeCellHeight
            }

            cell.unfold(false, animated:true, completion: nil)
            duration = 0.8
        }
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut, animations: {
                self.tableView.beginUpdates()
                self.tableView.endUpdates()
            self.tableView.isUserInteractionEnabled = true
        }, completion: nil)
    }
    func didEdited(index: IndexPath) {
        //TODO
        YJCache.shared.updateRecord()
        self.tableView.reloadData()

    }
    
    func didFinished(tag:Int,indexPath:IndexPath?) {
        YJCache.shared.updateRecord()
        if tag == 0 {
            //let index = IndexPath.init(row: 0, section: 0)
            normalCellHeights.insert(YJConst.closeCellHeight, at: 0)
            //self.tableView.insertRows(at: [index], with: .automatic)
        }
        self.tableView.reloadData()
    }


}
