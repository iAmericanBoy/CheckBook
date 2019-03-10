//
//  SyncController.swift
//  CheckBook
//
//  Created by Dominic Lanzillotta on 3/6/19.
//  Copyright © 2019 Dominic Lanzillotta. All rights reserved.
//

import Foundation
import CloudKit
import CoreData

class SyncController {
    
    //MARK: - Singleton
    /// The shared Instance of SyncController.
    static let shared = SyncController()
    
    ///Saves failed CK object to a local cache.
    /// - parameter uuid: The UUID of the purchase that was not able to be uploaded.
    func saveFailedUpload(withFailedPurchaseUUID uuid: UUID) {
        CachePurchase(uuid: uuid)
        CoreDataController.shared.saveToPersistentStore()
    }
    
    ///Updates child MOC with objects from CK
    /// - parameter records: The records that need to be updated or created in the local Store
    /// - parameter recordIDs: The recordIDs of records that need to be deleted from the local Store.
    func updateContextWith(fetchedRecordsToUpdate records: [CKRecord], deletedRecordIDs recordIDs: [CKRecord.ID]) {
        records.forEach { recordFromCK in
            guard let uuid = UUID(uuidString: recordFromCK.recordID.recordName) else {return}
            CoreDataController.shared.findPurchaseWith(uuid: uuid,inContext: CoreDataStack.childContext, completion: { purchaseFromCD in
                
                guard let amount = recordFromCK[Purchase.amountKey] as? Double,
                    let date = recordFromCK[Purchase.dateKey] as? Date,
                    let item = recordFromCK[Purchase.itemKey] as? String,
                    let method = recordFromCK[Purchase.methodKey] as? String,
                    let lastModified = recordFromCK[Purchase.lastModifiedKey] as? Date,
                    let storeName = recordFromCK[Purchase.storeNameKey] as? String else {return }
                
                if let purchaseFromCD = purchaseFromCD {
                    //update
                    if Calendar.current.compare(lastModified, to: purchaseFromCD.lastModified!, toGranularity: Calendar.Component.second).rawValue > 0 {
                    
                        purchaseFromCD.amount = amount
                        purchaseFromCD.date = date
                        purchaseFromCD.item = item
                        purchaseFromCD.storeName = storeName
                        purchaseFromCD.method = method
                        purchaseFromCD.uuid = uuid
                        purchaseFromCD.lastModified = lastModified
                    }
                } else {
                    //create new Purchase in ChildContext
                    Purchase(amount: amount, date: date, item: item, storeName: storeName, method: method, uuid: uuid, lastModified: lastModified, context: CoreDataStack.childContext)
                }
            })
        }
        
        //delete
        recordIDs.forEach { (recordID) in
            CoreDataController.shared.findPurchaseWith(uuid: UUID(uuidString: recordID.recordName)!, inContext: CoreDataStack.childContext, completion: { (purchaseToDelete) in
                if let purchase = purchaseToDelete {
                    CoreDataController.shared.remove(purchase: purchase)
                }
            })
        }
        
        //save
        do {
            if CoreDataStack.childContext.hasChanges {
                try CoreDataStack.childContext.save()
            }
        } catch {
            print("Error saving updated Objects to childContext with error: \(String(describing: error)) \(error.localizedDescription))")
        }
        CoreDataController.shared.saveToPersistentStore()
    }
    
    ///Retries upload of cached objects.
    func saveCachedPurchasesToCK() {
        var cachedPurchases: [CachePurchase] = []
        var recordsToUpdate: [CKRecord] = []
        var recordsToDelete: [CKRecord.ID] = []

        
        let dateSort = NSSortDescriptor(key: "\(CachePurchase.uploadKey)", ascending: false)
        let fetchRequest: NSFetchRequest<CachePurchase> = CachePurchase.fetchRequest()
        fetchRequest.sortDescriptors = [dateSort]
        do {
            cachedPurchases =  try CoreDataStack.context.fetch(fetchRequest)
        } catch {
            print("Error fetching cachedObjects with error: \(String(describing: error)) \(error.localizedDescription))")
        }
        
        
        cachedPurchases.forEach { (cachedPurchase) in
            CoreDataController.shared.findPurchaseWith(uuid: cachedPurchase.uuid, completion: { (purchaseFromCD) in
                if let purchase = purchaseFromCD {
                    //sent update to CK
                    recordsToUpdate.append(CKRecord(purchase: purchase)!)
                } else {
                    //sentdeleteToCK
                    if let uuid = cachedPurchase.uuid?.uuidString {
                        recordsToDelete.append(CKRecord.ID(recordName: uuid))
                    }
                }
            })
        }
        CloudKitController.shared.saveChangestoCK(purchasesToUpdate: recordsToUpdate, purchasesToDelete: recordsToDelete) { (isSuccess, savedRecords, deletedRecordIDs) in
            guard let savedRecords = savedRecords, let deletedRecordIDs = deletedRecordIDs, isSuccess else {return}
            savedRecords.forEach({ (record) in
                CoreDataController.shared.findPurchaseWith(uuid: UUID(uuidString: record.recordID.recordName), inContext: CoreDataStack.cacheContext, completion: { (cachePurchase) in
                    guard let cachePurchase = cachePurchase else {return}
                    CoreDataController.shared.remove(purchase: cachePurchase)
                })
            })
            deletedRecordIDs.forEach({ (recordID) in
                CoreDataController.shared.findPurchaseWith(uuid: UUID(uuidString: recordID.recordName), inContext: CoreDataStack.cacheContext, completion: { (cachePurchase) in
                    guard let cachePurchase = cachePurchase else {return}
                    CoreDataController.shared.remove(purchase: cachePurchase)
                })
            })
        }
    }
}
