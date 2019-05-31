//
//  CheckBookTests.swift
//  CheckBookTests
//
//  Created by Dominic Lanzillotta on 4/25/19.
//  Copyright © 2019 Dominic Lanzillotta. All rights reserved.
//

@testable import CheckBook
import CloudKit
import CoreData
import XCTest

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
    
    // MARK: - Ledger
    
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
    
    /// This checks if the two Ledgers created have the same attributes. They are not the same objcts as CoreData doesn't allow two exact matches(objectID!) to be in a context
    func testLedgerConvertCKRecord() {
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
        
        XCTAssertEqual(ledgerFromRecord?.appleUserRecordName, ledger.appleUserRecordName)
        XCTAssertEqual(ledgerFromRecord?.lastModified, ledger.lastModified)
        XCTAssertEqual(ledgerFromRecord?.zoneOwnerName, ledger.zoneOwnerName)
        XCTAssertEqual(ledgerFromRecord?.zoneName, ledger.zoneName)
        XCTAssertEqual(ledgerFromRecord?.name, ledger.name)
        XCTAssertEqual(ledgerFromRecord?.uuid, ledger.uuid)
        XCTAssertEqual(ledgerFromRecord?.managedObjectContext, ledger.managedObjectContext)
        XCTAssertEqual(ledgerFromRecord?.url, ledger.url)
        XCTAssertEqual(ledgerFromRecord?.purchases, ledger.purchases)
        tearDown()
    }
    
    func testCreateLedgerCKRecord() {
        setUp()
        guard let testContext = testContext else {
            assertionFailure("unable to unwrap testContext")
            return
        }
        let newLedger = Ledger(name: "testName", appleUserRecordName: nil, context: testContext)
        
        let newRecord = CKRecord(ledger: newLedger)
        
        XCTAssertEqual(newLedger.name, newRecord?[Ledger.nameKey])
        XCTAssertEqual(newLedger.uuid?.uuidString, newRecord?.recordID.recordName)
        XCTAssertEqual(newLedger.zoneName, newRecord?.recordID.zoneID.zoneName)
        XCTAssertEqual(newLedger.zoneOwnerName, newRecord?.recordID.zoneID.ownerName)
        XCTAssertEqual(newLedger.lastModified, newRecord?[Ledger.lastModifiedKey])
        XCTAssertEqual(newLedger.appleUserRecordName, newRecord?.creatorUserRecordID?.recordName)
        XCTAssertEqual(newLedger.url, newRecord?[Ledger.shareURLKey])
        XCTAssertEqual(newLedger.appleUserRecordName, newRecord?.creatorUserRecordID?.recordName)
        XCTAssertEqual(Ledger.typeKey, newRecord?.recordType.description)
        tearDown()
    }
    
    // MARK: - Category
    
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
    
    func testCreateCategoryCKRecord() {
        setUp()
        guard let testContext = testContext else {
            assertionFailure("unable to unwrap testContext")
            return
        }
        let newLedger = Ledger(name: "testName", appleUserRecordName: nil, context: testContext)
        let newCategory = Category(name: "testCategory", ledger: newLedger, context: testContext)
        
        let newRecord = CKRecord(category: newCategory)
        
        XCTAssertEqual(newCategory.name, newRecord?[Category.nameKey])
        XCTAssertEqual(newCategory.color, newRecord?[Category.colorKey])
        XCTAssertEqual(newCategory.lastModified, newRecord?[Category.lastModifiedKey])
        XCTAssertEqual(Category.typeKey, newRecord?.recordType)
        
        XCTAssertEqual(newCategory.ledgerUUID?.uuidString, newRecord?.parent?.recordID.recordName)
        XCTAssertEqual(newLedger.zoneOwnerName, newRecord?.parent?.recordID.zoneID.ownerName)
        XCTAssertEqual(newLedger.zoneName, newRecord?.parent?.recordID.zoneID.zoneName)
        
        XCTAssertEqual(newCategory.uuid?.uuidString, newRecord?.recordID.recordName)
        XCTAssertEqual(newCategory.zoneName, newRecord?.recordID.zoneID.zoneName)
        XCTAssertEqual(newCategory.zoneOwnerName, newRecord?.recordID.zoneID.ownerName)
        
        tearDown()
    }
    
    func testCategoryConvertCKRecord() {
        setUp()
        guard let testContext = testContext else {
            assertionFailure("unable to unwrap testContext")
            return
        }
        let newLedger = Ledger(name: "testName", appleUserRecordName: nil, context: testContext)
        let category = Category(name: "testCategory", ledger: newLedger, context: testContext)
        
        guard let newRecord = CKRecord(category: category) else {
            assertionFailure("Unable to create Record from Category")
            return
        }
        let categoryFromRecord = Category(record: newRecord, context: testContext)
        
        XCTAssertEqual(categoryFromRecord?.name, category.name)
        XCTAssertEqual(categoryFromRecord?.uuid, category.uuid)
        XCTAssertEqual(categoryFromRecord?.ledgerUUID, newLedger.uuid)
        XCTAssertEqual(categoryFromRecord?.ledgerUUID, category.ledgerUUID)
        XCTAssertEqual(categoryFromRecord?.lastModified, category.lastModified)
        XCTAssertEqual(categoryFromRecord?.color, category.color)
        XCTAssertEqual(categoryFromRecord?.purchases, category.purchases)
        XCTAssertEqual(categoryFromRecord?.zoneName, category.zoneName)
        XCTAssertEqual(categoryFromRecord?.zoneOwnerName, category.zoneOwnerName)
        XCTAssertEqual(categoryFromRecord?.managedObjectContext, category.managedObjectContext)
        
        tearDown()
    }
    
    // MARK: - PurchaseMethod
    
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
    
    func testCreatePurchaseMethodCKRecord() {
        setUp()
        guard let testContext = testContext else {
            assertionFailure("unable to unwrap testContext")
            return
        }
        let newLedger = Ledger(name: "testName", appleUserRecordName: nil, context: testContext)
        let newPurchaseMethod = PurchaseMethod(name: "testName", ledger: newLedger, context: testContext)
        let newRecord = CKRecord(purchaseMethod: newPurchaseMethod)
        
        XCTAssertEqual(newPurchaseMethod.name, newRecord?[PurchaseMethod.nameKey])
        XCTAssertEqual(newPurchaseMethod.color, newRecord?[PurchaseMethod.colorKey])
        XCTAssertEqual(newPurchaseMethod.lastModified, newRecord?[PurchaseMethod.lastModifiedKey])
        XCTAssertEqual(PurchaseMethod.typeKey, newRecord?.recordType)
        
        XCTAssertEqual(newPurchaseMethod.ledgerUUID?.uuidString, newRecord?.parent?.recordID.recordName)
        XCTAssertEqual(newLedger.zoneOwnerName, newRecord?.parent?.recordID.zoneID.ownerName)
        XCTAssertEqual(newLedger.zoneName, newRecord?.parent?.recordID.zoneID.zoneName)
        
        XCTAssertEqual(newPurchaseMethod.uuid?.uuidString, newRecord?.recordID.recordName)
        XCTAssertEqual(newPurchaseMethod.zoneName, newRecord?.recordID.zoneID.zoneName)
        XCTAssertEqual(newPurchaseMethod.zoneOwnerName, newRecord?.recordID.zoneID.ownerName)
        
        tearDown()
    }
    
    func testConvertPurchaseMethodCKRecord() {
        setUp()
        guard let testContext = testContext else {
            assertionFailure("unable to unwrap testContext")
            return
        }
        let newLedger = Ledger(name: "testName", appleUserRecordName: nil, context: testContext)
        let purchaseMethod = PurchaseMethod(name: "testName", ledger: newLedger, context: testContext)
        
        guard let newRecord = CKRecord(purchaseMethod: purchaseMethod) else {
            assertionFailure("Unable to create Record from PurchaseMethod")
            return
        }
        let purchaseMethodFromRecord = PurchaseMethod(record: newRecord, context: testContext)
        
        XCTAssertEqual(purchaseMethodFromRecord?.name, purchaseMethod.name)
        XCTAssertEqual(purchaseMethodFromRecord?.color, purchaseMethod.color)
        XCTAssertEqual(purchaseMethodFromRecord?.lastModified, purchaseMethod.lastModified)
        XCTAssertEqual(purchaseMethodFromRecord?.uuid, purchaseMethod.uuid)
        XCTAssertEqual(purchaseMethodFromRecord?.purchases, purchaseMethod.purchases)
        
        XCTAssertEqual(purchaseMethodFromRecord?.ledgerUUID, newLedger.uuid)
        XCTAssertEqual(purchaseMethodFromRecord?.ledgerUUID, purchaseMethod.ledgerUUID)
        
        XCTAssertEqual(purchaseMethodFromRecord?.zoneName, purchaseMethod.zoneName)
        XCTAssertEqual(purchaseMethodFromRecord?.zoneOwnerName, purchaseMethod.zoneOwnerName)
        XCTAssertEqual(purchaseMethodFromRecord?.managedObjectContext, purchaseMethod.managedObjectContext)
        
        tearDown()
    }
    
    // MARK: - Purchase
    
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
    
    func testCreatePurchaseCKRecord() {
        setUp()
        guard let testContext = testContext else {
            assertionFailure("unable to unwrap testContext")
            return
        }
        let newLedger = Ledger(name: "testName", appleUserRecordName: nil, context: testContext)
        let newMethod = PurchaseMethod(name: "testMethod", ledger: newLedger, context: testContext)
        let newCategory = Category(name: "testCategory", ledger: newLedger, context: testContext)
        
        let newPurchase = Purchase(amount: 123.45, date: Date(), item: " ", storeName: "testStore", purchaseMethod: newMethod, category: newCategory, appleUserRecordName: nil, ledger: newLedger, context: testContext)
        
        let newRecord = CKRecord(purchase: newPurchase)
        
        XCTAssertEqual(newPurchase.lastModified, newRecord?[Purchase.lastModifiedKey])
        XCTAssertEqual(newPurchase.amount?.doubleValue, newRecord?[Purchase.amountKey])
        XCTAssertEqual(newPurchase.appleUserRecordName, newRecord?.creatorUserRecordID?.recordName)
        XCTAssertEqual(newPurchase.date, newRecord?[Purchase.dateKey])
        XCTAssertEqual(newPurchase.item, newRecord?[Purchase.itemKey])
        XCTAssertEqual(newPurchase.storeName, newRecord?[Purchase.storeNameKey])
        
        XCTAssertEqual(newPurchase.methodUUID?.uuidString, newRecord?[Purchase.methodKey])
        XCTAssertEqual(newPurchase.methodName, newRecord?[Purchase.methodNameKey])
        
        XCTAssertEqual(newPurchase.categoryUUID?.uuidString, newRecord?[Purchase.categoryKey])
        
        XCTAssertEqual(newPurchase.ledgerUUID?.uuidString, newRecord?[Purchase.ledgerKey])
        XCTAssertEqual(newPurchase.ledgerUUID?.uuidString, newRecord?.parent?.recordID.recordName)
        XCTAssertEqual(newPurchase.ledger?.zoneName, newRecord?.parent?.recordID.zoneID.zoneName)
        XCTAssertEqual(newPurchase.ledger?.zoneOwnerName, newRecord?.parent?.recordID.zoneID.ownerName)
        
        XCTAssertEqual(Purchase.typeKey, newRecord?.recordType)
        
        tearDown()
    }
    
    // TODO: - Find a way to test references for the purchaseCKRecord
}
