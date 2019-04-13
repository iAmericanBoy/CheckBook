//
//  Ledger+convenience.swift
//  CheckBook
//
//  Created by Dominic Lanzillotta on 4/3/19.
//  Copyright © 2019 Dominic Lanzillotta. All rights reserved.
//

import Foundation
import CoreData
import CloudKit

extension Ledger {
    @discardableResult
    convenience init(name: String,
                     uuid: UUID = UUID(),
                     appleUserRecordName: String?,
                     purchases: NSOrderedSet = NSOrderedSet(),
                     lastModified: Date = Date(),
                     context: NSManagedObjectContext = CoreDataStack.context) {
        
        self.init(context: context)
        
        self.name = name
        self.uuid = uuid
        self.purchases = purchases
        self.appleUserRecordName = appleUserRecordName
        
        self.lastModified = lastModified
    }
    
    @discardableResult
    convenience init?(record: CKRecord, context: NSManagedObjectContext = CoreDataStack.context) {
        guard let name = record[Ledger.nameKey] as? String,
            let lastModified = record[Ledger.lastModifiedKey] as? Date else {return nil}
        
        self.init(name: name, uuid: UUID(uuidString: record.recordID.recordName)!, appleUserRecordName: record.creatorUserRecordID?.recordName, lastModified: lastModified, context: context)
    }
}

extension CKRecord {
    convenience init?(ledger: Ledger) {
        self.init(recordType: Ledger.typeKey, recordID: CKRecord.ID(recordName: ledger.uuid!.uuidString, zoneID: CKRecordZone.ID(zoneName: Purchase.privateRecordZoneName, ownerName: CKCurrentUserDefaultName)))
        
        setValue(ledger.name, forKey: Ledger.nameKey)
        setValue(ledger.lastModified, forKey: Ledger.lastModifiedKey)
    }
}

