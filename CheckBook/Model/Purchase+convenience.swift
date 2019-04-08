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
    convenience init(amount: NSDecimalNumber,
                     date: Date,
                     item: String,
                     storeName: String,
                     uuid: UUID = UUID(),
                     lastModified: Date = Date(),
                     purchaseMethod: PurchaseMethod,
                     category: Category,
                     user: User,
                     ledger: Ledger,
                     context: NSManagedObjectContext = CoreDataStack.context) {
        
        self.init(context: context)
        
        self.amount = amount
        self.date = date
        self.item = item
        self.storeName = storeName
        self.purchaseMethod = purchaseMethod
        self.ledger = ledger
        self.category = category
        self.user = user
        
        self.methodName = purchaseMethod.name
        self.methodUUID = purchaseMethod.uuid
        self.ledgerUUID = ledger.uuid
        self.categoryUUID = category.uuid
        self.userUUID = user.uuid
        self.appleUser = user.appleUser
        
        self.lastModified = lastModified
        self.uuid = uuid
    }
}

extension CKRecord {
    convenience init?(purchase: Purchase) {
        self.init(recordType: Purchase.typeKey, recordID: CKRecord.ID(recordName: purchase.uuid!.uuidString, zoneID: CKRecordZone.ID(zoneName: Purchase.privateRecordZoneName, ownerName: CKCurrentUserDefaultName)))
        
        let purchaseMethodReference = CKRecord.Reference(recordID: CKRecord.ID(recordName: purchase.methodUUID!.uuidString, zoneID: CKRecordZone.ID(zoneName: Purchase.privateRecordZoneName, ownerName: CKCurrentUserDefaultName)), action: CKRecord_Reference_Action.none)
        
        let ledgerReference = CKRecord.Reference(recordID: CKRecord.ID(recordName: purchase.ledgerUUID!.uuidString, zoneID: CKRecordZone.ID(zoneName: Purchase.privateRecordZoneName, ownerName: CKCurrentUserDefaultName)), action: .none)
        
        let categoryReference = CKRecord.Reference(recordID: CKRecord.ID(recordName: purchase.categoryUUID!.uuidString, zoneID: CKRecordZone.ID(zoneName: Purchase.privateRecordZoneName, ownerName: CKCurrentUserDefaultName)), action: .none)
        
        let userReference = CKRecord.Reference(recordID: CKRecord.ID(recordName: purchase.userUUID!.uuidString), action: .none)

        guard let methodUUID = purchase.purchaseMethod?.uuid, let methodName = purchase.purchaseMethod?.name, let ledgerUUID = purchase.ledger?.uuid, let categoryUUID = purchase.category?.uuid, let appleUserUUID = purchase.user?.appleUser, let userUUID = purchase.user?.uuid else {return nil}
        
        setValue(purchase.amount, forKey: Purchase.amountKey)
        setValue(purchaseMethodReference, forKey: Purchase.methodReferenceKey)
        setValue(ledgerReference, forKey: Purchase.ledgerReferenceKey)
        setValue(categoryReference, forKey: Purchase.categoryReferenceKey)
        setValue(userReference, forKey: Purchase.userReferenceKey)
        setValue(purchase.date, forKey: Purchase.dateKey)
        setValue(purchase.item, forKey: Purchase.itemKey)
        setValue(methodUUID.uuidString, forKey: Purchase.methodKey)
        setValue(ledgerUUID.uuidString, forKey: Purchase.ledgerKey)
        setValue(categoryUUID.uuidString, forKey: Purchase.categoryKey)
        setValue(appleUserUUID, forKey: Purchase.appleUserKey)
        setValue(userUUID.uuidString, forKey: Purchase.userKey)
        setValue(methodName, forKey: Purchase.methodNameKey)
        setValue(purchase.lastModified, forKey: Purchase.lastModifiedKey)
        setValue(purchase.storeName, forKey: Purchase.storeNameKey)
    }
}
