//
//  YJRecommenderManager.swift
//  Simple
//
//  Created by JotingYou on 2019/5/1.
//  Copyright © 2019 YouJoting. All rights reserved.
//

import UIKit

class YJHeartManager: UIViewController {
    let pagesPresenter = YJPageViewControllerPresenter()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(pagesPresenter.navigationController.view)

        // Do any additional setup after loading the view.
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
