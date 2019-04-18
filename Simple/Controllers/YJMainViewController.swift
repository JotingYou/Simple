//
//  YJMainViewController.swift
//  Simple
//
//  Created by JotingYou on 2019/4/10.
//  Copyright © 2019 YouJoting. All rights reserved.
//

import UIKit

class YJMainViewController: UITableViewController,YJEditViewControllerDelegate,UISearchBarDelegate,YJDetailTVCDelegate,UISearchResultsUpdating {
    
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
        searchBar.scopeButtonTitles = ["Name","Stock Number","Stock Name"]

        return searchBar
    }()

    var searchResults = Array<People>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 11.0, *) {
            navigationItem.searchController = searchController
        }
        searchBar.delegate = self
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
                return person.fund_number?.lowercased().contains(searchText.lowercased()) ?? false
            }else{
                return person.fund?.lowercased().contains(searchText.lowercased()) ?? false
            }
        })
    }

    //MARK: searchController Delegate
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!,scope: searchBar.selectedScopeButtonIndex)
        tableView.reloadData()
    }
    //MARK: -
    //MARK: tableview
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
        let cell = tableView.dequeueReusableCell(withIdentifier: reusableID) ?? {
            let cell = UITableViewCell.init(style: .value1, reuseIdentifier: "personCell")
            return cell
        }()
        
        cell.textLabel?.text = person.name
        if person.isValued {
            cell.detailTextLabel?.text = String(person.profit)
        }else{
            cell.detailTextLabel?.text = "Waiting..."
        }
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "toDetail", sender: indexPath)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination.isKind(of: YJEditViewController.self) {
            let dest:YJEditViewController = segue.destination as! YJEditViewController
            dest.type = 0
            dest.delegate = self
        }else if segue.destination.isKind(of: YJDetailTableViewController.self){
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
    func didFinished() {
        let index = IndexPath.init(row: 0, section: 0)
        self.tableView.insertRows(at: [index], with: .automatic)
    }
    
    func didEdited(index:IndexPath) {
        self.tableView.reloadRows(at: [index], with: .automatic)
    }
}
