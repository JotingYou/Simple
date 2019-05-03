//
//  YJDiscoverController.swift
//  Simple
//
//  Created by JotingYou on 2019/5/2.
//  Copyright © 2019 YouJoting. All rights reserved.
//

import UIKit
import LTScrollView
class YJDiscoverController: UIViewController {
    // - headerView
    private lazy var headerView:UIView = {
        let view = UIView.init(frame: CGRect(x:0, y:0, width:YJConst.screenWidth, height:0))
        view.backgroundColor = UIColor.white
        return view
    }()
    var transparentLayer:UIView?
    private lazy var viewControllers: [UIViewController] = {
        let attentionVC = YJAttentionController()
        let recommendVC = YJRecommendController()
        let newsVC = YJNewsController()
        return [attentionVC,recommendVC,newsVC]
    }()
    
    private lazy var titles: [String] = {
        return ["关注动态","猜你喜欢" ,"最新资讯"]
    }()
    
    private lazy var layout: LTLayout = {
        let layout = LTLayout()
        layout.isAverage = true
        layout.sliderWidth = 80
        layout.titleViewBgColor = UIColor.white
        layout.titleColor = UIColor(r: 178, g: 178, b: 178)
        layout.titleSelectColor = UIColor(r: 16, g: 16, b: 16)
        layout.bottomLineColor = UIColor.red
        layout.sliderHeight = 56
        /* 更多属性设置请参考 LTLayout 中 public 属性说明 */
        return layout
    }()
    
    private lazy var advancedManager: LTAdvancedManager = {
        let advancedManager = LTAdvancedManager(frame: CGRect(x: 0, y: YJConst.navBarHeight, width: YJConst.screenWidth, height: YJConst.screenHeight-YJConst.navBarHeight), viewControllers: viewControllers, titles: titles, currentViewController: self, layout: layout, headerViewHandle: {[weak self] in
                guard let strongSelf = self else { return UIView() }
                let headerView = strongSelf.headerView
                return headerView
            })
        
        /* 设置代理 监听滚动 */
        advancedManager.delegate = self
        /* 设置悬停位置 */
        // advancedManager.hoverY = navigationBarHeight
        /* 点击切换滚动过程动画 */
        // advancedManager.isClickScrollAnimation = true
        /* 代码设置滚动到第几个位置 */
        // advancedManager.scrollToIndex(index: viewControllers.count - 1)
        return advancedManager
    }()
    
    // - 导航栏左边按钮
    private lazy var leftBarButton:UIButton = {
        let button = UIButton.init(type: UIButton.ButtonType.custom)
        button.frame = CGRect(x:0, y:0, width:30, height: 30)
        button.setImage(UIImage(named: "msg"), for: UIControl.State.normal)
        button.addTarget(self, action: #selector(leftBarButtonClick), for: UIControl.Event.touchUpInside)
        return button
    }()
    // - 导航栏右边按钮
    private lazy var rightBarButton:UIButton = {
        let button = UIButton.init(type: UIButton.ButtonType.custom)
        button.frame = CGRect(x:0, y:0, width:30, height: 30)
        button.setImage(UIImage(named: "搜索"), for: UIControl.State.normal)
        button.addTarget(self, action: #selector(rightBarButtonClick), for: UIControl.Event.touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        self.automaticallyAdjustsScrollViewInsets = false
        view.addSubview(advancedManager)
        advancedManagerConfig()
        self.title = NSLocalizedString("Discovery", comment: "")
        // 导航栏左右item
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: leftBarButton)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: rightBarButton)
        transparentLayer = self.navigationController!.navigationBar.subviews.first
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)

            hideNavigationBar()
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        showNavigationBar()
    }
    func hideNavigationBar(){
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        //line?.alpha = 0
        transparentLayer?.alpha = 0
    }
    func showNavigationBar(){
        self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        //line?.alpha = 1
        transparentLayer?.alpha = 1
    }
    // - 导航栏左边消息点击事件
    @objc func leftBarButtonClick() {
        
    }
    // - 导航栏左边消息点击事件
    @objc func rightBarButtonClick() {
        
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
extension YJDiscoverController : LTAdvancedScrollViewDelegate {
    // 具体使用请参考以下
    private func advancedManagerConfig() {
        // 选中事件
        advancedManager.advancedDidSelectIndexHandle = {
            print("选中了 -> \($0)")
        }
    }
    
    func glt_scrollViewOffsetY(_ offsetY: CGFloat) {
    }
}
