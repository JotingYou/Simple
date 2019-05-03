//
//  YJPageViewControllerPresenter.swift
//  Simple
//
//  Created by JotingYou on 2019/5/1.
//  Copyright © 2019 YouJoting. All rights reserved.
//

import UIKit
import BouncyPageViewController
class YJPageViewControllerPresenter: NSObject {
    final var pagesQueue = [YJHeartController]()
    var navigationController:UINavigationController!
    override init() {
        super.init()
        for idx in 0...5 {
            let pageViewController = self.pageViewController(index: idx)
            pagesQueue.append(pageViewController)
        }
        let pageViewController = BouncyPageViewController(initialViewControllers: Array(pagesQueue[1...2]))
        pageViewController.viewControllerAfterViewController = self.viewControllerAfterViewController
        pageViewController.viewControllerBeforeViewController = self.viewControllerBeforeViewController
        pageViewController.didScroll = self.pageViewControllerDidScroll
        
        navigationController = UINavigationController(rootViewController: pageViewController)
        navigationController.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController.navigationBar.shadowImage = UIImage()
        pageViewController.navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: UIImage(named:"menu"), style: .plain, target: self, action: #selector(dismiss))

        
        pageViewController.navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: UIImage(named:"settings"), style: .plain, target: nil, action: nil)
        
    }
    @objc func dismiss(){
        //navigationController.dismiss(animated: true, completion: nil)
    }
    func pageViewControllerDidScroll(pageViewController:BouncyPageViewController,offset:CGFloat,progress:CGFloat) {
        for vc in pageViewController.visibleControllers() {
            let vc = (vc as! YJHeartController)
            vc.progress = progress            
        }
        guard let firstVC = pageViewController.visibleControllers().first as? YJHeartController else{
            return
        }
        let color = firstVC.tintColor
        pageViewController.navigationItem.leftBarButtonItem!.tintColor = color
        pageViewController.navigationItem.rightBarButtonItem!.tintColor = color
    }
    func viewControllerAfterViewController(prevVC:UIViewController) -> UIViewController? {
        if let index = self.pagesQueue.index(of: prevVC as! YJHeartController), index+1 < self.pagesQueue.count {
            return self.pagesQueue[index+1]
        }
        return nil
    }
    func viewControllerBeforeViewController(prevVC: UIViewController) -> UIViewController? {
        if let idx = self.pagesQueue.index(of: prevVC as! YJHeartController), idx - 1 >= 0 {
            return self.pagesQueue[idx - 1]
        }
        return nil
    }
    func pageViewController(index:Int) -> YJHeartController {
        let pageViewController = YJHeartController.init(nibName: "YJHeartController", bundle: nil)
        let firstColor = UIColor.white
        let secondColor = UIColor(red:0.96, green:0.16, blue:0.39, alpha:1.00)
        pageViewController.tintColor = index % 2 == 0 ?  secondColor : firstColor
        pageViewController.view.backgroundColor = index % 2 == 0 ? firstColor : secondColor
        pageViewController.dayLabel.text = index % 2 == 0 ? "Today" : "Yesterday"
        pageViewController.heartRateLabel.text = index % 2 == 0 ? "\(index)/280" : "\(index)/320"

        return pageViewController
    }
    
}
