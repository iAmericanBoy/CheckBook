//
//  PurchaseMethod+convenience.swift
//  CheckBook
//
//  Created by Dominic Lanzillotta on 3/9/19.
//  Copyright © 2019 Dominic Lanzillotta. All rights reserved.
//

import Foundation
import CoreData
import CloudKit

extension PurchaseMethod {
    @discardableResult
    convenience init(name: String, uuid: UUID = UUID(), purchases: NSSet = NSSet(),lastModified: Date = Date(), context: NSManagedObjectContext = CoreDataStack.context) {
        self.init(context: context)
        
        self.name = name
        self.uuid = uuid
        self.purchases = purchases
        
        self.lastModified = lastModified
    }
    
    convenience init?(record: CKRecord, context: NSManagedObjectContext = CoreDataStack.context) {
        guard let name = record[PurchaseMethod.nameKey] as? String,
            let lastModified = record[PurchaseMethod.lastModifiedKey] as? Date else {return nil}
        
        self.init(name: name, uuid: UUID(uuidString: record.recordID.recordName)!, lastModified: lastModified)
    }
}
extension CKRecord {
    convenience init?(purchaseMethod: PurchaseMethod) {
        self.init(recordType: PurchaseMethod.typeKey, recordID: CKRecord.ID(recordName: purchaseMethod.uuid!.uuidString, zoneID: CKRecordZone.ID(zoneName: Purchase.privateRecordZoneName, ownerName: CKCurrentUserDefaultName)))
        
        setValue(purchaseMethod.name, forKey: PurchaseMethod.nameKey)
        setValue(purchaseMethod.lastModified, forKey: PurchaseMethod.lastModifiedKey)
    }
}
