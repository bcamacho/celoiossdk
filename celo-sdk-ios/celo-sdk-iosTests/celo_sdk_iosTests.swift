//
//  celo_sdk_iosTests.swift
//  celo-sdk-iosTests
//
//  Created by Sreedeep on 02/11/21.
//

import XCTest
@testable import celo_sdk_ios

class celo_sdk_iosTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    private let password = "PASSWORD123"
    
    func testAccount() {
        guard let _  = try? CeloSDK.account.generateAccount(password: password) else {
            XCTFail()
            return
        }
        
        XCTAssert(CeloSDK.account.hasAccount)
        
        guard let address = CeloSDK.account.address else {
            XCTFail()
            return
        }
        XCTAssert(address.count == 42)
        
        guard let privateKey = try? CeloSDK.account.privateKey(password: password) else {
            XCTFail()
            return
        }
        XCTAssert(privateKey.count == 64)
        
        guard let _ = try? CeloSDK.account.importAccount(privateKey: privateKey, password: password) else {
            XCTFail()
            return
        }
        
        XCTAssert(address == CeloSDK.account.address)
        
        XCTAssert(CeloSDK.account.verifyPassword(password))
        XCTAssertFalse(CeloSDK.account.verifyPassword("WRONG_PASSWORD"))
    }
    
    func testBalance() {
        XCTAssert(try! CeloSDK.balance.celoBalanceSync() == "0")
        XCTAssert(try! CeloSDK.balance.celoUSDBalanceSync() == "0")
    }

}
