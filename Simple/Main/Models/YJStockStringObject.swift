//
//  YJStockStringObject.swift
//  Simple
//
//  Created by JotingYou on 2019/4/17.
//  Copyright © 2019 YouJoting. All rights reserved.
//

import UIKit

class YJStockStringObject: NSObject {
    let str:String!
    let id:String!
    let code:String!
    let name:String!
    let type:String!
    let name_spell:String!
    
    init(str:String) {
        self.str = str
        let strs = str.components(separatedBy: "\"")        
        self.id = strs[1]
        self.code = strs[3]
        self.name = strs[5]
        self.type = strs[7]
        self.name_spell = strs[9]
    }
    
    
}
