//
//  LedgerController.swift
//  CheckBook
//
//  Created by Dominic Lanzillotta on 4/5/19.
//  Copyright © 2019 Dominic Lanzillotta. All rights reserved.
//

import Foundation
import CloudKit

class LedgerController {
    
    //MARK: - Singleton
    /// The shared Instance of LedgerController.
    static let shared = LedgerController()
    
    //MARK: - CRUD
    /// Creates new Ledger using the convenience initilizer inside the CoredataStack.context and tries to uploads it to CloudKit. If the upload fails the new Ledger gets added to the CacheContext for a later try.
    /// - parameter name: The name of the Ledger.
    func createNewLedgerWith(name: String) -> Ledger {
        let ledger = Ledger(name: name, appleUserRecordName: CloudKitController.shared.appleUserID?.recordName)
        CoreDataController.shared.saveToPersistentStore()
        
        guard let newRecord = CKRecord(ledger: ledger) else {return ledger}
        
        CloudKitController.shared.create(record: newRecord) { (isSuccess, newRecord) in
            if !isSuccess {
                guard let uuid = ledger.uuid else {return}
                SyncController.shared.saveFailedUpload(withFailedPurchaseUUID: uuid)
            }
        }
        return ledger
    }
    
    ///Adds the url as a string to a Ledger and saves it.
    /// - parameter ledger: The ledger to update.
    /// - parameter stringURL: The new URL for a ledger.
    /// - parameter completion: Handler for when the ledger was updated
    /// - parameter isSuccess: Confirms that the ledger was updated.
    func add(stringURL: String, toLedger ledger: Ledger, _ completion: @escaping (_ isSuccess: Bool) -> Void) {
        ledger.url = stringURL
        ledger.lastModified = Date()
        
        CoreDataController.shared.saveToPersistentStore()

        guard let record = CKRecord(ledger: ledger) else {completion(false);return}
        
        
        CloudKitController.shared.saveChangestoCK(recordsToUpdate: [record], purchasesToDelete: []) { (isSuccess, updatedRecords, _) in
            if !isSuccess {
                guard let uuid = ledger.uuid else {return}
                SyncController.shared.saveFailedUpload(withFailedPurchaseUUID: uuid)
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    
    
    /// Deletes the Ledger, deletes it from Cotext and CloudKit. If the CK delete Fails the Ledger gets added to the cache for uploading at a later date.
    /// - parameter ledger: The ledger to delete.
    func delete(ledger: Ledger) {
        
        guard let recordToDelete = CKRecord(ledger: ledger) else {return}
        
        CloudKitController.shared.delete(record: recordToDelete) { (isSuccess) in
            if !isSuccess {
                guard let uuid = ledger.uuid else {return}
                SyncController.shared.saveFailedUpload(withFailedPurchaseUUID: uuid)
            }
        }
        CoreDataController.shared.remove(object: ledger)
    }
}
