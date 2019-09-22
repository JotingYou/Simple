//
//  YJMainViewController.swift
//  Simple
//
//  Created by JotingYou on 2019/4/10.
//  Copyright © 2019 YouJoting. All rights reserved.
//

import UIKit
import FoldingCell
import CocoaLumberjack

class YJMainController: UITableViewController,YJEditViewControllerDelegate,UISearchBarDelegate,UISearchResultsUpdating,YJFoldingCellDelegate,YJDetailTVCDelegate {
    //@IBOutlet var tableView:UITableView!
    var searchResults = Array<People>()
    var line:UIImageView?
    var transparentLayer:UIView?
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
    var timer:YJTimer?
    
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
            present(searchController, animated: true, completion: nil)
        }
        searchBar.delegate = self
        
        setTableView()
        setNotifications()

        setRefresh()
        setNavigationBar()
        //开启计时器 自动刷新数据 半个小时
        timer = YJTimer.init(1800, self, #selector(repeatRefreshPeople))
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if tableView.contentOffset.y >= -YJConst.navBarHeight {
            showNavigationBar()
        }else{
            hideNavigationBar()
        }
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        showNavigationBar()
    }
    //MARK: - Notification
    func setNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(reloadPersonCell(notification:)), name: NSNotification.Name(rawValue: YJConst.personHasUpdateStock), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(internetTimeout(noti:)), name: NSNotification.Name(rawValue:YJConst.internetTimeout), object: nil)
    }
    @objc func reloadPersonCell(notification:NSNotification){
        guard let isUpdated:Bool = notification.object as? Bool else {
            return
        }
        if isUpdated {
            YJCache.shared.updateRecord()
            self.tableView.reloadData()
        }
        
    }
    @objc func internetTimeout(noti:Notification) {
        YJProgressHUD.showError(message: YJConst.internetTimeout)
    }

    //MARK: - SETUP
    func setNavigationBar(){
        extendedLayoutIncludesOpaqueBars = true
        transparentLayer = self.navigationController!.navigationBar.subviews.first
        for (_,view) in self.navigationController!.navigationBar.subviews.first!.subviews.enumerated(){
            if view.isKind(of: UIImageView.self){
                line = view as? UIImageView
            }
        }
        if #available(iOS 11.0, *) {
            navigationItem.hidesSearchBarWhenScrolling = true
        }
        //修改导航栏标题文字颜色
        self.navigationController?.navigationBar.titleTextAttributes =
            [.foregroundColor: UIColor.white]
        //修改导航栏按钮颜色
        self.navigationController?.navigationBar.tintColor = UIColor.white
        //设置视图的背景图片（自动拉伸）
        self.view.layer.contents = #imageLiteral(resourceName: "background").cgImage
    }
    func hideNavigationBar(){
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        //line?.alpha = 0
        transparentLayer?.alpha = 0
    }
    func showNavigationBar(){
        self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
            //line?.alpha = 1
        self.transparentLayer?.alpha = 1
        //navigationController?.navigationBar.isTranslucent = true
    }
    func setTableView() {
        tableView.rowHeight = UITableView.automaticDimension
        //fix odd scroll bug
        self.tableView.estimatedRowHeight = 0;
        self.tableView.estimatedSectionHeaderHeight = 0;
        self.tableView.estimatedSectionFooterHeight = 0;
    }
    //MARK: REFRESH
    func setRefresh() {
        refreshControl = UIRefreshControl()
        refreshControl!.tintColor = .white
        refreshControl!.addTarget(self, action: #selector(refreshStateChange), for: .valueChanged)
        refreshStateChange(refreshControl!)
    }
    @objc func refreshStateChange(_ refreshControl:UIRefreshControl) {
        if YJCache.shared.people.count == 0 {
            YJCache.shared.refreshRecord()
            OperationQueue.main.addOperation {
                refreshControl.endRefreshing()
            }
        }else{
            YJCache.shared.refreshPeople({
                YJCache.shared.refreshRecord()
                OperationQueue.main.addOperation {
                    [weak self] in
                    refreshControl.endRefreshing()
                    self?.tableView.reloadData()
                }
            })
        }
    }
    @objc func repeatRefreshPeople() {
        guard let rc = refreshControl else {
            return
        }
        DDLogDebug("\(#function) perform")
        refreshStateChange(rc)
    }
    //MARK: -
    //MARK: searchBar Delegate
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchBar.text!, scope: selectedScope)
    }
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
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
            [weak self] in
            guard let wSelf = self else{
                return
            }
            wSelf.tableView.beginUpdates()
            wSelf.tableView.endUpdates()
            //fix odd bugs
            let rect = wSelf.tableView.rectForRow(at: indexPath)
            let rectInScrollView = wSelf.tableView.convert(rect, to: wSelf.tableView.superview)
            if rectInScrollView.maxY > UIScreen.main.bounds.maxY{
                wSelf.tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
            }
        },completion:nil)
        

    }
    func didEdited(index: IndexPath) {
        YJCache.shared.updateRecord()
        self.tableView.reloadData()

    }
    
    func didFinished(tag:Int,indexPath:IndexPath?) {
        YJCache.shared.updateRecord()
        if tag == 0 {
            //insert
            normalCellHeights.insert(YJConst.closeCellHeight, at: 0)
        }
        self.tableView.reloadData()
    }
    deinit{
        NotificationCenter.default.removeObserver(self)
        self.timer?.shutDown()
    }

}
//MARK: -
//MARK: tableview
extension YJMainController{

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return headerView
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if searchController.isActive {
            return 0
        }
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
}
extension YJMainController {
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentOffSet = scrollView.contentOffset.y
        DDLogDebug("\(scrollView.contentOffset.y)")
        let alphaHeight = (currentOffSet+YJConst.navBarHeight + YJConst.scrollOffSetConst)/YJConst.scrollOffSetConst
        let alpha = alphaHeight<1 ? alphaHeight : 1
        if alpha > 0.9{
            UIView.animate(withDuration: 0.5) {[weak self] in
                self?.showNavigationBar()
            }
        }else{
            UIView.animate(withDuration: 0.5) {
                [weak self] in
                self?.hideNavigationBar()
            }
        }
    }

}

