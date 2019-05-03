//
//  YJNewsController.swift
//  Simple
//
//  Created by JotingYou on 2019/5/2.
//  Copyright © 2019 YouJoting. All rights reserved.
//

import UIKit
import SwiftWebVC
class YJNewsController: UIViewController {
    let webVC = SwiftWebVC(urlString: YJConst.newsURLSrting, sharingEnabled: true)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let navController = UINavigationController.init(rootViewController: webVC)
        webVC.delegate = self
        view.addSubview(navController.view)
        let offset:CGFloat = 10
        
        navController.view.frame = CGRect.init(x: 0, y: -YJConst.tabBarHeight+offset, width: view.bounds.width, height: view.bounds.height-offset)
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
extension YJNewsController:SwiftWebVCDelegate{
    func didStartLoading() {
        
    }
    
    func didFinishLoading(success: Bool) {
        
    }
    
    
}
