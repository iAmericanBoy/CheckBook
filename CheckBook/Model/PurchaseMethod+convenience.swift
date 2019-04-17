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
    convenience init(name: String,
                     uuid: UUID = UUID(),
                     color: String? = nil,
                     ledgerUUID: UUID,
                     purchases: NSOrderedSet = NSOrderedSet(),
                     lastModified: Date = Date(),
                     context: NSManagedObjectContext = CoreDataStack.context) {
        
        self.init(context: context)
        
        self.name = name
        self.uuid = uuid
        self.purchases = purchases
        self.color = color
        self.ledgerUUID = ledgerUUID
        
        self.lastModified = lastModified
    }
    
    @discardableResult
    convenience init?(record: CKRecord, context: NSManagedObjectContext = CoreDataStack.context) {
        guard let name = record[PurchaseMethod.nameKey] as? String,
            let lastModified = record[PurchaseMethod.lastModifiedKey] as? Date else {return nil}
        
        self.init(name: name, uuid: UUID(uuidString: record.recordID.recordName)!, color: record[PurchaseMethod.colorKey] as? String, ledgerUUID: UUID(uuidString: (record.parent?.recordID.recordName)!)!, lastModified: lastModified, context: context)
    }
}
extension CKRecord {
    convenience init?(purchaseMethod: PurchaseMethod, zoneID: CKRecordZone.ID) {
        self.init(recordType: PurchaseMethod.typeKey, recordID: CKRecord.ID(recordName: purchaseMethod.uuid!.uuidString, zoneID: zoneID))
        
        setParent(CKRecord.ID(recordName: purchaseMethod.ledgerUUID!.uuidString, zoneID: zoneID))
        
        setValue(purchaseMethod.color, forKey: PurchaseMethod.colorKey)
        setValue(purchaseMethod.name, forKey: PurchaseMethod.nameKey)
        setValue(purchaseMethod.lastModified, forKey: PurchaseMethod.lastModifiedKey)
    }
}
