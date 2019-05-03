//
//  YJAttentionController.swift
//  Simple
//
//  Created by JotingYou on 2019/5/2.
//  Copyright © 2019 YouJoting. All rights reserved.
//

import UIKit
import LTScrollView
class YJAttentionController: UIViewController,LTTableViewProtocal {
    // 懒加载
    lazy var viewModel: YJAttentionViewModel = {
        return YJAttentionViewModel()
    }()
    private lazy var tableView: UITableView = {
        let tableView = tableViewConfig(CGRect(x: 0, y: 56, width:YJConst.screenWidth, height: YJConst.screenHeight - YJConst.navBarHeight - YJConst.tabBarHeight), self, self, nil)
        tableView.register(YJAttentionCell.self, forCellReuseIdentifier: YJConst.attendCellSI)
        return tableView
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        self.view.addSubview(tableView)
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        
        setupLoadData()
    }
    // 加载数据
    func setupLoadData() {
        // 加载数据
        viewModel.updataBlock = { [unowned self] in
            // 更新列表数据
            self.tableView.reloadData()
        }
        viewModel.refreshDataSource()
    }
    // MARK: - Table view data source


 

}
extension YJAttentionController:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return viewModel.numberOfRowsInSection(section: section)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return viewModel.heightForRowAt(indexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:YJAttentionCell = tableView.dequeueReusableCell(withIdentifier: YJConst.attendCellSI, for: indexPath) as! YJAttentionCell
        cell.selectionStyle = .none
        cell.eventInfosModel = viewModel.eventInfos?[indexPath.row]
        return cell
        
    }
}
