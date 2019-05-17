//
//  SimpleTests.swift
//  SimpleTests
//
//  Created by JotingYou on 2019/4/10.
//  Copyright © 2019 YouJoting. All rights reserved.
//

import XCTest
@testable import Simple

class SimpleTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let networkManager = YJHttpTool.shared
        let exp = self.expectation(description: "network ")
        
        networkManager.getBasicRate { (dic) in
            let now = dic["now"]
            let yesterday = dic["yesterday"]
            XCTAssert(now != "", "dic is nil")
            XCTAssert(yesterday != "", "dic is nil")
            exp.fulfill()
        }
        self.waitForExpectations(timeout: 1) { (error) in
            networkManager.cancelTask()
        }
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            YJCache.shared.readStocksFromFile()
            // Put the code you want to measure the time of here.
        }
    }

}
