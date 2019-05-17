//
//  YJConst.swift
//  Simple
//
//  Created by JotingYou on 2019/4/21.
//  Copyright © 2019 YouJoting. All rights reserved.
//

import UIKit

class YJConst: NSObject {
    //MARK:- DATA
    static let screenWidth:CGFloat = UIScreen.main.bounds.width
    static let screenHeight = UIScreen.main.bounds.height
    
    static let openCellHeight:CGFloat = 330
    static let closeCellHeight:CGFloat = 80
    
    static let headerHeight:CGFloat = 140

    static let isIphoneX = (screenHeight == 812 || screenHeight == 896) ? true : false
    static let navBarHeight : CGFloat = isIphoneX ? 88:64
    static let tabBarHeight : CGFloat = isIphoneX ? 83:49
    static let scrollOffSetConst : CGFloat = 100
    //MARK:-
        //MARK:URL
    static let newsURLSrting = "https://www.yicai.com/news/info/"
    static let fundFileUrl = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("fundcode_search.js")
    static let attendJsonURL = URL(fileURLWithPath: Bundle.main.path(forResource: "DiscoverAttention", ofType: "json")!)
        //MARK:NOTIFICATION
    static let recordChangedNotification = "recordChangedNotification"
    static let recordChangedBasic = "recordChangedBasicNotification"
    static let personHasUpdateStock = "personHasUpdateStockNotification"
    static let internetTimeout = "internetTimeoutNotification"
    //MARK:Cell Indentifier
    static let attendCellSI = "YJAttentionCell"
    static let attendPicCellSI = "YJAttentionPicCell"
    static let recommendCellSI = "YJrecommendCell"
    static let recommendPicCellSI = "YJrecommendPicCell"
    
    //MARK:- FUNCTION
    static func isSameDay(_ day1:Date,_ day2:Date) -> Bool {
        let calendar = Calendar.current
        let cmp1 = calendar.dateComponents([.year,.month,.day], from: day1)
        let cmp2 = calendar.dateComponents([.year,.month,.day], from: day2)
        return cmp1.day == cmp2.day && cmp1.month == cmp2.month && cmp1.year == cmp2.year
        
    }

}
