//
//  User+convenience.swift
//  CheckBook
//
//  Created by Dominic Lanzillotta on 4/8/19.
//  Copyright © 2019 Dominic Lanzillotta. All rights reserved.
//

import Foundation
import CoreData
import CloudKit

extension User {
    @discardableResult
    convenience init(name: String,
                     color: String? = nil,
                     appleUserUUID: String,
                     uuid: UUID = UUID(),
                     purchases: NSOrderedSet = NSOrderedSet(),
                     lastModified: Date = Date(),
                     context: NSManagedObjectContext = CoreDataStack.context) {
        
        self.init(context: context)
        
        self.name = name
        self.appleUser = appleUserUUID
        self.uuid = uuid
        self.purchases = purchases
        self.color = color
        
        self.lastModified = lastModified
    }
    
    @discardableResult
    convenience init?(record: CKRecord, context: NSManagedObjectContext = CoreDataStack.context) {
        guard let name = record[User.nameKey] as? String,
            let color = record[User.colorKey] as? String,
            let appleUserUUID = record[User.appleUserKey] as? String,
            let lastModified = record[User.lastModifiedKey] as? Date else {return nil}
        
        self.init(name: name, color: color, appleUserUUID: appleUserUUID, uuid: UUID(uuidString: record.recordID.recordName)!, lastModified: lastModified, context: context)
    }
}

extension CKRecord {
    convenience init?(user: User) {
        self.init(recordType: User.typeKey, recordID: CKRecord.ID(recordName: user.uuid!.uuidString, zoneID: CKRecordZone.ID(zoneName: Purchase.privateRecordZoneName, ownerName: CKCurrentUserDefaultName)))
        
        let appleUserRef = CKRecord.Reference(recordID: CKRecord.ID(recordName: user.appleUser!, zoneID: CKRecordZone.ID(zoneName: Purchase.privateRecordZoneName, ownerName: CKCurrentUserDefaultName)) , action: .deleteSelf)
        
        guard let appleUser = user.appleUser else {return nil}
        
        setValue(user.name, forKey: User.nameKey)
        setValue(user.color, forKey: User.colorKey)
        setValue(user.lastModified, forKey: User.lastModifiedKey)
        setValue(appleUser, forKey: User.appleUserKey)
        setValue(appleUserRef, forKey: User.appleUserReferenceKey)
    }
}
