//
//  YJTimer.swift
//  Simple
//
//  Created by JotingYou on 2019/5/27.
//  Copyright © 2019 YouJoting. All rights reserved.
//

import UIKit
import CocoaLumberjack

class YJTimer: NSObject {
    weak var target:NSObject!
    let selector:Selector!
    var timer:Timer?
    
    init(_ timeInterval:TimeInterval, _ target:NSObject,_ selector:Selector,_ userInfo:Any? = nil) {
        self.target = target
        self.selector = selector
        timer = Timer.scheduledTimer(timeInterval: timeInterval, target: target, selector: selector, userInfo: userInfo, repeats: true)
    }
    func shutDown() {
        self.timer?.invalidate()
        self.timer = nil
    }
    
}
