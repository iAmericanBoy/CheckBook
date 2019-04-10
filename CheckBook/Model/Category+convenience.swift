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
                     purchases: NSOrderedSet = NSOrderedSet(),
                     lastModified: Date = Date(),
                     context: NSManagedObjectContext = CoreDataStack.context) {
        
        self.init(context: context)
        
        self.name = name
        self.uuid = uuid
        self.purchases = purchases
        self.color = color
        
        self.lastModified = lastModified
    }
    
    @discardableResult
    convenience init?(record: CKRecord, context: NSManagedObjectContext = CoreDataStack.context) {
        guard let name = record[Category.nameKey] as? String,
            let lastModified = record[Category.lastModifiedKey] as? Date else {return nil}
        
        self.init(name: name, color: record[Category.colorKey] as? String, uuid: UUID(uuidString: record.recordID.recordName)!, lastModified: lastModified)
    }
}
extension CKRecord {
    convenience init?(category: Category) {
        self.init(recordType: Category.typeKey, recordID: CKRecord.ID(recordName: category.uuid!.uuidString, zoneID: CKRecordZone.ID(zoneName: Purchase.privateRecordZoneName, ownerName: CKCurrentUserDefaultName)))
        
        setValue(category.name, forKey: Category.nameKey)
        setValue(category.color, forKey: Category.colorKey)
        setValue(category.lastModified, forKey: Category.lastModifiedKey)
    }
}
