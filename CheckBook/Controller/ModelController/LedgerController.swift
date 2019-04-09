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
        let ledger = Ledger(name: name)
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
