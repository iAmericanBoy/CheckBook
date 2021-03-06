//
//  Ledger+convenience.swift
//  CheckBook
//
//  Created by Dominic Lanzillotta on 4/3/19.
//  Copyright © 2019 Dominic Lanzillotta. All rights reserved.
//

import CloudKit
import CoreData
import Foundation

extension Ledger {
    @discardableResult
    convenience init(name: String,
                     uuid: UUID = UUID(),
                     appleUserRecordName: String?,
                     zoneName: String? = nil,
                     zoneOwnerName: String? = nil,
                     url: String? = nil,
                     purchases: NSOrderedSet = NSOrderedSet(),
                     lastModified: Date = Date(),
                     context: NSManagedObjectContext = CoreDataStack.context) {
        self.init(context: context)
        
        self.name = name
        self.uuid = uuid
        self.purchases = purchases
        self.appleUserRecordName = appleUserRecordName
        self.url = url
        
        self.zoneName = zoneName ?? Purchase.privateRecordZoneName
        self.zoneOwnerName = zoneOwnerName ?? CKCurrentUserDefaultName
        
        self.lastModified = lastModified
    }
    
    @discardableResult
    convenience init?(record: CKRecord, context: NSManagedObjectContext = CoreDataStack.context) {
        guard let name = record[Ledger.nameKey] as? String,
            let lastModified = record[Ledger.lastModifiedKey] as? Date else { return nil }
        
        self.init(name: name, uuid: UUID(uuidString: record.recordID.recordName)!, appleUserRecordName: record.creatorUserRecordID?.recordName, url: record[Ledger.shareURLKey] as? String, lastModified: lastModified, context: context)
        
        self.zoneOwnerName = record.recordID.zoneID.ownerName
        self.zoneName = record.recordID.zoneID.zoneName
    }
}

extension CKRecord {
    convenience init?(ledger: Ledger) {
        self.init(recordType: Ledger.typeKey, recordID: CKRecord.ID(recordName: ledger.uuid!.uuidString, zoneID: CKRecordZone.ID(zoneName: ledger.zoneName ?? Purchase.privateRecordZoneName, ownerName: ledger.zoneOwnerName ?? CKCurrentUserDefaultName)))
        
        setValue(ledger.url, forKey: Ledger.shareURLKey)
        setValue(ledger.name, forKey: Ledger.nameKey)
        setValue(ledger.lastModified, forKey: Ledger.lastModifiedKey)
    }
}
