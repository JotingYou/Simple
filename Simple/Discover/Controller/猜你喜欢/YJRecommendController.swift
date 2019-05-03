//
//  YJRecommendController.swift
//  Simple
//
//  Created by JotingYou on 2019/5/2.
//  Copyright © 2019 YouJoting. All rights reserved.
//

import UIKit
import LTScrollView
class YJRecommendController: UIViewController,LTTableViewProtocal {

    private lazy var tableView: UITableView = {
        let tableView = tableViewConfig(CGRect(x: 0, y: 0, width:YJConst.screenWidth, height: YJConst.screenHeight - YJConst.navBarHeight - YJConst.tabBarHeight), self, self, nil)
        tableView.register(YJRecommendCell.self, forCellReuseIdentifier: YJConst.recommendCellSI)
        return tableView
    }()
    
    lazy var viewModel: YJRecommendViewModel = {
        return YJRecommendViewModel()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        self.view.addSubview(tableView)
        glt_scrollView = tableView
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        setupLoadData()
    }
    
    func setupLoadData() {
        // 加载数据
        viewModel.updataBlock = { [unowned self] in
            // 更新列表数据
            self.tableView.reloadData()
        }
        viewModel.refreshDataSource()
    }


}
extension YJRecommendController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRowsInSection(section: section)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return viewModel.heightForRowAt(indexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:YJRecommendCell = tableView.dequeueReusableCell(withIdentifier: YJConst.recommendCellSI, for: indexPath) as! YJRecommendCell
        cell.streamModel = viewModel.streamList?[indexPath.row]
        return cell
    }
}
