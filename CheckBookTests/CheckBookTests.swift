//
//  CheckBookTests.swift
//  CheckBookTests
//
//  Created by Dominic Lanzillotta on 4/25/19.
//  Copyright © 2019 Dominic Lanzillotta. All rights reserved.
//

import XCTest
import CoreData
import CloudKit
@testable import CheckBook


class CheckBookTests: XCTestCase {

    var testContext: NSManagedObjectContext?
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        testContext = setUpInMemoryManagedObjectContext()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        testContext = nil
        
    }
    func testTearDown() {
        setUp()
        tearDown()
        XCTAssertNil(testContext, "after TearDown the context should be nil")
    }
    
    func testSetUp() {
        setUp()
        XCTAssertNotNil(testContext)
        tearDown()
    }

    func testCreateLedger() {
        setUp()
        guard let testContext = testContext else {
            assertionFailure("unable to unwrap testContext")
            return
        }
        let newLedger = Ledger(name: "testName", appleUserRecordName: nil, context: testContext)
        
        XCTAssertEqual(testContext.registeredObjects.count, 1)
        XCTAssertTrue(testContext.registeredObjects.contains(newLedger))
        tearDown()
    }
    
    
    func testLedgerCKRecord() {
        setUp()
        guard let testContext = testContext else {
            assertionFailure("unable to unwrap testContext")
            return
        }
        let ledger = Ledger(name: "testName", appleUserRecordName: nil, context: testContext)
        guard let newRecord = CKRecord(ledger: ledger) else {
            assertionFailure("Unable to create Record from Ledger")
            return
        }
        let ledgerFromRecord = Ledger(record: newRecord, context: testContext)
        
        XCTAssertNotEqual(ledgerFromRecord, ledger)
        tearDown()
    }
    
    
    func testCreateCategory() {
        setUp()
        guard let testContext = testContext else {
            assertionFailure("unable to unwrap testContext")
            return
        }
        let newLedger = Ledger(name: "testName", appleUserRecordName: nil, context: testContext)
        let newCategory = Category(name: "testCategory", ledger: newLedger, context: testContext)
        
        XCTAssertEqual(testContext.registeredObjects.count, 2)
        XCTAssertTrue(testContext.registeredObjects.contains(newCategory))
        tearDown()
    }
    
    func testCreatePurchaseMethod() {
        setUp()
        guard let testContext = testContext else {
            assertionFailure("unable to unwrap testContext")
            return
        }
        let newLedger = Ledger(name: "testName", appleUserRecordName: nil, context: testContext)
        let newMethod = PurchaseMethod(name: "testMethod", ledger: newLedger, context: testContext)
        
        XCTAssertEqual(testContext.registeredObjects.count, 2)
        XCTAssertTrue(testContext.registeredObjects.contains(newMethod))
        tearDown()
    }
    
    func testCreatePurchase() {
        setUp()
        guard let testContext = testContext else {
            assertionFailure("unable to unwrap testContext")
            return
        }
        let newLedger = Ledger(name: "testName", appleUserRecordName: nil, context: testContext)
        let newMethod = PurchaseMethod(name: "testMethod", ledger: newLedger, context: testContext)
        let newCategory = Category(name: "testCategory", ledger: newLedger, context: testContext)

        let newPurchase = Purchase(amount: 123.45, date: Date(), item: " ", storeName: "testStore", purchaseMethod: newMethod, category: newCategory, appleUserRecordName: nil, ledger: newLedger, context: testContext)
        
        XCTAssertEqual(testContext.registeredObjects.count, 4)
        XCTAssertTrue(testContext.registeredObjects.contains(newPurchase))
        tearDown()
    }
}
