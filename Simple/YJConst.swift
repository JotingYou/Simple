//
//  YJConst.swift
//  Simple
//
//  Created by JotingYou on 2019/4/21.
//  Copyright © 2019 YouJoting. All rights reserved.
//

import UIKit

class YJConst: NSObject {
    static let openCellHeight:CGFloat = 330
    static let closeCellHeight:CGFloat = 80
    static let headerHeight:CGFloat = 140
    static let recordChangedNotification = "recordChangedNotification"
    static func isSameDay(_ day1:Date,_ day2:Date) -> Bool {
        let calendar = Calendar.current
        let cmp1 = calendar.dateComponents([.year,.month,.day], from: day1)
        let cmp2 = calendar.dateComponents([.year,.month,.day], from: day2)
        return cmp1.day == cmp2.day && cmp1.month == cmp2.month && cmp1.year == cmp2.year
        
    }

}
