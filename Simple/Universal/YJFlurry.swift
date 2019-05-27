//
//  YJFlurry.swift
//  Simple
//
//  Created by JotingYou on 2019/5/27.
//  Copyright © 2019 YouJoting. All rights reserved.
//

import UIKit
import Flurry_iOS_SDK
import CocoaLumberjack

class YJFlurry: NSObject {
    private let api = YJConst.flurryApi
    private var isInited = false
    private let queue = DispatchQueue.init(label: "Flurry")
    private var events:Array<String>? = Array<String>()
    static let shared = YJFlurry()
    override init() {
        super.init()
        DispatchQueue.main.async {[weak self] in
            guard let wself = self else {
                return
            }
            Flurry.startSession(wself.api, with: FlurrySessionBuilder.init().withCrashReporting(true).withLogLevel(FlurryLogLevelDebug))
            wself.queue.sync {
                for event in wself.events!{
                    Flurry.logEvent(event)
                }
                wself.events = nil
                wself.isInited = true
                DDLogInfo("Flurry inited")
            }
        }
    }
    func logEvent(name:String){
        queue.sync {
            if isInited {
                Flurry.logEvent(name)
            }else{
                self.events?.append(name)
                DDLogInfo("Flurry add event:\(name)")
            }
        }
    }
}
