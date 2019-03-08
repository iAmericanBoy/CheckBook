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
    ///Function to fetch the updated RecordZone
    /// - parameter completion: Handler for the feched Zone.
    /// - parameter isSuccess: Confirms there was a zone with Updates.
    /// - parameter updatedZone: The updated Zone (can be nil).
    private func fetchUpdatedZone(completion: @escaping (_ isSuccess: Bool, _ updatedZone: CKRecordZone.ID?) -> Void) {
        let serverChangeTokenData = UserDefaults(suiteName: "group.com.oskman.DaysInARowGroup")?.data(forKey: CloudKitController.changeToken) ?? Data()
        
        let token: CKServerChangeToken?
        do {
            token = try NSKeyedUnarchiver.unarchivedObject(ofClass: CKServerChangeToken.self, from: serverChangeTokenData)
        } catch {
            token = nil
        }
        
        let fetch = CKFetchDatabaseChangesOperation(previousServerChangeToken: token)
        
        fetch.changeTokenUpdatedBlock = { (newToken) in
            do {
                let data = try NSKeyedArchiver.archivedData(withRootObject: newToken, requiringSecureCoding: false)
                UserDefaults(suiteName: "group.com.oskman.DaysInARowGroup")?.set(data, forKey: CloudKitController.changeToken)
            } catch {
                print("Error encoding the token for UserDefualts: \(String(describing: error)) \(error.localizedDescription))")
            }
        }
        fetch.fetchDatabaseChangesCompletionBlock = { (newToken,_,error) in
            if let error = error {
                print("An Error fetching updated in Zone has occured. \(error), \(error.localizedDescription)")
                completion(false, nil)
                return
            }
            guard let newToken = newToken else {completion(false,nil); return}
            do {
                let data = try NSKeyedArchiver.archivedData(withRootObject: newToken, requiringSecureCoding: false)
                UserDefaults(suiteName: "group.com.oskman.DaysInARowGroup")?.set(data, forKey: CloudKitController.changeToken)
            } catch {
                print("Error encoding the token for UserDefualts: \(String(describing: error)) \(error.localizedDescription))")
            }
        }
        
        fetch.recordZoneWithIDChangedBlock = { (recordZoneID) in
            completion(true,recordZoneID)
        }
    }
    
    ///Gets all the updated records form CloudKit
    /// - parameter completion: Handler for the feched Records.
    /// - parameter isSuccess: Confirms that records where able to be fetched.
    /// - parameter fetchedPurchases: The fetched Purchases (can be nil).
    func fetchUpdatedPurchasesFromCK(completion: @escaping(_ isSuccess: Bool,_ fetchedPurchases:[Purchase]?)-> Void ) {
        fetchUpdatedZone { (isSuccess, updatedZone) in
            <#code#>
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
