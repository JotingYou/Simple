//
//  YJHistoryController.swift
//  Simple
//
//  Created by joting on 2021/2/3.
//  Copyright © 2021 YouJoting. All rights reserved.
//

import UIKit

class YJHistoryController: UITableViewController {
    lazy var normalCellHeights:[CGFloat] = (0..<holds.count).map { _ in YJConst.closeCellHeight }
    var transparentLayer:UIView?
    var line:UIImageView?
    var holds: [Holds] {
        return YJCache.shared.saledHolds
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "已卖出"
        setTableView()
        setNavigationBar()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
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
        if #available(iOS 13.0, *) {
            let navBarAppearance = UINavigationBarAppearance()
            navBarAppearance.configureWithOpaqueBackground()
            navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
            navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
            navBarAppearance.backgroundColor = UIColor.init(r: 93, g: 74, b: 153)
            self.navigationController!.navigationBar.tintColor = .white
            self.navigationController!.navigationBar.standardAppearance = navBarAppearance
            self.navigationController!.navigationBar.scrollEdgeAppearance = navBarAppearance
        }else{
            self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
            self.navigationController!.navigationBar.tintColor = .white
        }


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
        tableView.separatorStyle = .none
        //fix odd scroll bug
        self.tableView.estimatedRowHeight = 0;
        self.tableView.estimatedSectionHeaderHeight = 0;
        self.tableView.estimatedSectionFooterHeight = 0;
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return holds.count
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return normalCellHeights[indexPath.row]
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let person = holds[indexPath.row]

        let reusableID = "personCell"
        guard let cell:YJFoldingCell = tableView.dequeueReusableCell(withIdentifier: reusableID) as? YJFoldingCell else {
            let cell = YJFoldingCell.loadNib()
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
    

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            YJCache.shared.deleteHoldsAt(hold: holds[indexPath.row])
            tableView.deleteRows(at: [indexPath], with: .automatic)
            self.normalCellHeights.remove(at: indexPath.row)
        }
    }
    

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
extension YJHistoryController:YJFoldingCellDelegate{
    func foldCell(cell: YJFoldingCell) {
        guard let indexPath = self.tableView.indexPath(for: cell)else{
            return
        }
        var duration = 0.0

        if !cell.isUnfolded {

            normalCellHeights[indexPath.row] = YJConst.openCellHeight
            
            cell.unfold(true, animated: true, completion: nil)
            duration = 0.5
        } else {

            normalCellHeights[indexPath.row] = YJConst.closeCellHeight
            
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
    
    func showDetail(cell: YJFoldingCell) {
        let sb = UIStoryboard.init(name: "Main", bundle: Bundle.main)
        guard let dc:YJDetailTableViewController = sb.instantiateViewController(withIdentifier: "detailController") as? YJDetailTableViewController else{
            return
        }
        guard let index = self.tableView.indexPath(for: cell) else {
            return
        }
        dc.person = cell.person
        dc.indexPath = index
        dc.delegate = self
        show(dc, sender: nil)
    }
    
    
}
extension YJHistoryController:YJDetailTVCDelegate{
    func didEdited(index: IndexPath?) {
        tableView.reloadData()
    }
    
    
}
