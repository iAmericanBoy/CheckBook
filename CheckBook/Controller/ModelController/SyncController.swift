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
        do {
            if CoreDataStack.cacheContext.hasChanges {
                try CoreDataStack.cacheContext.save()
            }
        } catch {
            print("Error saving failed purchase to chache with error: \(String(describing: error)) \(error.localizedDescription))")
        }
    }
    
    ///Updates child MOC with objects from CK
    /// - parameter records: The records that need to be updated or created in the local Store
    /// - parameter recordIDs: The recordIDs of records that need to be deleted from the local Store.
    func updateContextWith(fetchedRecordsToUpdate records: [CKRecord], deletedRecordIDs recordIDs: [CKRecord.ID]) {
        let purchases = records.compactMap({ Purchase(record: $0, context: CoreDataStack.childContext)})
        purchases.forEach { purchaseFromCK in
            CoreDataController.shared.findPurchaseWith(uuid: purchaseFromCK.uuid,inContext: CoreDataStack.childContext, completion: { purchaseFromCD in
                if let purchaseFromCD  = purchaseFromCD {
                    //update
                    if purchaseFromCK.lastModified?.compare((purchaseFromCD.lastModified)!).rawValue == 1 {
                        purchaseFromCD.amount = purchaseFromCK.amount
                        purchaseFromCD.date = purchaseFromCK.date
                        purchaseFromCD.item = purchaseFromCK.item
                        purchaseFromCD.storeName = purchaseFromCK.storeName
                        purchaseFromCD.method = purchaseFromCK.method
                        purchaseFromCD.uuid = purchaseFromCK.uuid
                        purchaseFromCD.lastModified = purchaseFromCK.lastModified
                    }
                } else {
                    //create new Purchase in ChildContext
                    Purchase(amount: purchaseFromCK.amount, date: purchaseFromCK.date!, item: purchaseFromCK.item!, storeName: purchaseFromCK.storeName!, method: purchaseFromCK.method!, uuid: purchaseFromCK.uuid!, lastModified: purchaseFromCK.lastModified!, context: CoreDataStack.childContext)
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
                //TODO: - Make sure MainContext gets notified and updates Views
            }
        } catch {
            print("Error saving updated Objects to childContext with error: \(String(describing: error)) \(error.localizedDescription))")
        }
    }
    
    ///Retries upload of cached objects.
    func saveCachedPurchasesToCK() {
        var cachedPurchases: [CachePurchase] = []
        var recordsToUpdate: [CKRecord?] = []
        var recordsToDelete: [CKRecord.ID?] = []

        
        let dateSort = NSSortDescriptor(key: "\(CachePurchase.uploadKey)", ascending: false)
        let fetchRequest: NSFetchRequest<CachePurchase> = CachePurchase.fetchRequest()
        fetchRequest.fetchLimit = 20
        fetchRequest.sortDescriptors = [dateSort]
        do {
            cachedPurchases =  try CoreDataStack.cacheContext.fetch(fetchRequest)
        } catch {
            print("Error fetching cachedObjects with error: \(String(describing: error)) \(error.localizedDescription))")
        }
        
        
        cachedPurchases.forEach { (cachedPurchase) in
            CoreDataController.shared.findPurchaseWith(uuid: cachedPurchase.uuid, completion: { (purchaseFromCD) in
                if let purchase = purchaseFromCD {
                    //sent update to CK
                    recordsToUpdate.append(CKRecord(purchase: purchase))
                } else {
                    //sentdeleteToCK
                    recordsToDelete.append(CKRecord.ID(recordName: (cachedPurchase.uuid?.uuidString)!))
                }
            })
        }
        //TODO: BatchUpdate ToCK
        //TODO: Delete form Cache
    }
}
