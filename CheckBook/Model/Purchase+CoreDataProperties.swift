//
//  Purchase+CoreDataProperties.swift
//  CheckBook
//
//  Created by Dominic Lanzillotta on 4/10/19.
//  Copyright © 2019 Dominic Lanzillotta. All rights reserved.
//
//

import CoreData
import Foundation

extension Purchase {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Purchase> {
        return NSFetchRequest<Purchase>(entityName: "Purchase")
    }

    @NSManaged public var amount: NSDecimalNumber?
    @NSManaged public var appleUserRecordName: String?
    @NSManaged public var categoryUUID: UUID?
    @NSManaged public var date: NSDate?
    @NSManaged public var item: String?
    @NSManaged public var lastModified: NSDate?
    @NSManaged public var ledgerUUID: UUID?
    @NSManaged public var methodName: String?
    @NSManaged public var methodUUID: UUID?
    @NSManaged public var storeName: String?
    @NSManaged public var uuid: UUID?
    @NSManaged public var category: Category?
    @NSManaged public var ledger: Ledger?
    @NSManaged public var purchaseMethod: PurchaseMethod?
}
