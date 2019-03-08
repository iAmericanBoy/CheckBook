//
//  CloudKitController.swift
//  CheckBook
//
//  Created by Dominic Lanzillotta on 3/6/19.
//  Copyright © 2019 Dominic Lanzillotta. All rights reserved.
//

import Foundation
import CloudKit

class CloudKitController {
    
    //MARK: - Singleton
    /// The shared Instance of CloudKitController.
    static let shared = CloudKitController()
    
    //MARK: - Properties
    /// The private Database of the User.
    fileprivate let privateDB = CKContainer.default().privateCloudDatabase
    
    //MARK: - CRUD
    /// Creates new Purchase in CloudKit.
    /// - parameter purchase: The purchase to be created
    /// - parameter completion: Handler for when the purchase has been created.
    /// - parameter isSuccess: Confirms the new purchase was created.
    /// - parameter newPurchase: The new Purchase or nil.
    func create(purchase: Purchase, completion: @escaping (_ isSuccess: Bool, _ newPurchase: Purchase?) -> Void) {
        
        guard let record = CKRecord(purchase: purchase) else {completion(false, nil); return}
        
        saveChangestoCK(purchasesToUpdate: [record], purchasesToDelete: []) { (isSuccess, savedRecords, _) in
            if isSuccess {
                guard let record = savedRecords?.first , record.recordID.recordName == purchase.uuid?.uuidString,
                    let savedPurchase = Purchase(record: record) else {
                        completion(false, nil)
                        return
                }
                completion(true,savedPurchase)
            }
        }
    }
    
    ///Gets all the Records form CloudKit
    /// - parameter completion: Handler for the feched Records.
    /// - parameter isSuccess: Confirms that records where able to be fetched.
    /// - parameter fetchedPurchases: The fetched Purchases (can be nil).
    func fetchPurchasesFromCK(completion: @escaping(_ isSuccess: Bool,_ fetchedPurchases:[Purchase]?)-> Void ) {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: Purchase.typeKey, predicate: predicate)
        privateDB.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                print("An Error fetching record from CloudKit has occured: \(error), \(error.localizedDescription)")
                completion(false, nil)
                return
            }
            guard let fetchedRecords = records else {completion(false,nil); return}
            let purchases = fetchedRecords.compactMap({ Purchase(record: $0)})
            completion(true,purchases)
        }
    }
    
    /// Updates the purchase if the purchase exists in the source of truth.
    /// - parameter purchase: The purchase that needs updating.
    /// - parameter completion: Handler for when the purchase has been updated.
    /// - parameter isSuccess: Confirms the new purchase was updated.
    /// - parameter updatedPurchase: The updated purchase or nil if the puchase could not be updated in CloudKit.
    func update(purchase: Purchase, completion: @escaping (_ isSuccess: Bool, _ updatedPurchase: Purchase?) -> Void) {
        
        guard let record = CKRecord(purchase: purchase) else {completion(false, nil); return}

        saveChangestoCK(purchasesToUpdate: [record], purchasesToDelete: []) { (isSuccess, savedRecords, _) in
            if isSuccess {
                guard let record = savedRecords?.first , record.recordID.recordName == purchase.uuid?.uuidString,
                    let updatedPurchase = Purchase(record: record) else {
                        completion(false, nil)
                        return
                }
                completion(true,updatedPurchase)
            }
        }
    }
    
    /// Deletes the purchase if the contact exists in the source of truth.
    /// - parameter purchase: The purchase that needs deleting
    /// - parameter completion: Handler for when the purchase has been deleted
    /// - parameter isSuccess: Confirms the purchase was deleted.
    func delete(purchase: Purchase, completion: @escaping (_ isSuccess: Bool) -> Void) {
        
        guard let record = CKRecord(purchase: purchase) else {completion(false); return}

        saveChangestoCK(purchasesToUpdate: [], purchasesToDelete: [record.recordID]) { (isSuccess, _, deletedRecordIDs) in
            if isSuccess {
                guard let recordID = deletedRecordIDs?.first , recordID.recordName == purchase.uuid?.uuidString else {
                    completion(false)
                    return
                }
                completion(true)
            }
        }
    }
    
    //MARK: - Save
    /// Updates and Deletes changes to CloudKit.
    /// - parameter purchasesToUpdate: Purchases that where updated or created as Records.
    /// - parameter recordIDs: Purchases that need deleted as RecordsIDs.
    /// - parameter completion: Handler for when the Purchases has been deleted or updated/saved.
    /// - parameter isSuccess: Confirms that the change has synced to CloudKit.
    /// - parameter savedRecords: The saved records (can be nil).
    /// - parameter deletedRecordIDs: The deleted recordIds (can be nil).
    func saveChangestoCK(purchasesToUpdate update: [CKRecord], purchasesToDelete recordIDs: [CKRecord.ID], completion: @escaping (_ isSuccess: Bool,_ savedRecords: [CKRecord]?, _ deletedRecordIDs: [CKRecord.ID]?) -> Void) {
        let operation = CKModifyRecordsOperation(recordsToSave: update, recordIDsToDelete: recordIDs)
        operation.savePolicy = .changedKeys
        operation.modifyRecordsCompletionBlock = { (savedRecords,deletedRecords,error) in
            if let error = error {
                print("An Error updating CK has occured. \(error), \(error.localizedDescription)")
                completion(false, savedRecords,deletedRecords)
                return
            }
            guard let saved = savedRecords, let deleted = deletedRecords else {completion(false,savedRecords,deletedRecords); return}
            completion(true,saved,deleted)
        }
        privateDB.add(operation)
    }
}
