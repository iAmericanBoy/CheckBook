//
//  CheckBook+Convenience.swift
//  CheckBook
//
//  Created by Dominic Lanzillotta on 3/5/19.
//  Copyright © 2019 Dominic Lanzillotta. All rights reserved.
//

import Foundation
import CoreData
import CloudKit

extension Purchase {
    @discardableResult
    convenience init(amount: Double, date: Date, item: String, storeName: String, method: String, uuid: UUID = UUID(), lastModified: Date = Date(), context: NSManagedObjectContext = CoreDataStack.context) {
        self.init(context: context)
        
        self.amount = amount
        self.date = date
        self.item = item
        self.method = method
        self.storeName = storeName
        
        self.lastModified = lastModified
        self.uuid = uuid
    }
    
    convenience init?(record: CKRecord) {
        guard let amount = record[Purchase.amountKey] as? Double,
            let date = record[Purchase.dateKey] as? Date,
            let item = record[Purchase.itemKey] as? String,
            let method = record[Purchase.methodKey] as? String,
            let lastModified = record[Purchase.lastModifiedKey] as? Date,
            let storeName = record[Purchase.storeNameKey] as? String else {return nil}
        
        self.init(amount: amount, date: date, item: item, storeName: storeName, method: method, uuid: UUID(uuidString: record.recordID.recordName)!, lastModified: lastModified)
    }
}

extension CKRecord {
    convenience init?(purchase: Purchase) {
        self.init(recordType: Purchase.typeKey, recordID: CKRecord.ID(recordName: purchase.uuid!.uuidString))
        
        setValue(purchase.amount, forKey: Purchase.amountKey)
        setValue(purchase.date, forKey: Purchase.dateKey)
        setValue(purchase.item, forKey: Purchase.itemKey)
        setValue(purchase.method, forKey: Purchase.methodKey)
        setValue(purchase.lastModified, forKey: Purchase.lastModifiedKey)
        setValue(purchase.storeName, forKey: Purchase.storeNameKey)
    }
}
