//
//  Category+convenience.swift
//  CheckBook
//
//  Created by Dominic Lanzillotta on 4/8/19.
//  Copyright © 2019 Dominic Lanzillotta. All rights reserved.
//

import Foundation
import CoreData
import CloudKit

extension Category {
    @discardableResult
    convenience init(name: String,
                     color: String? = nil,
                     uuid: UUID = UUID(),
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
        guard let name = record[Category.nameKey] as? String,
            let lastModified = record[Category.lastModifiedKey] as? Date else {return nil}
        
        self.init(name: name, color: record[Category.colorKey] as? String, uuid: UUID(uuidString: record.recordID.recordName)!, ledgerUUID: UUID(uuidString: (record.parent?.recordID.recordName)!)!, lastModified: lastModified, context: context)
    }
}
extension CKRecord {
    convenience init?(category: Category, zoneID: CKRecordZone.ID) {
        self.init(recordType: Category.typeKey, recordID: CKRecord.ID(recordName: category.uuid!.uuidString, zoneID: zoneID))
        
        setParent(CKRecord.ID(recordName: category.ledgerUUID!.uuidString, zoneID: zoneID))
        
        setValue(category.name, forKey: Category.nameKey)
        setValue(category.color, forKey: Category.colorKey)
        setValue(category.lastModified, forKey: Category.lastModifiedKey)
    }
}
