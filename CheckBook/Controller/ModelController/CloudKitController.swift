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
    
    //MARK: - INIT
    init() {
        createZone(withName: Purchase.privateRecordZoneName) { (isSuccess, newZone) in
            if !isSuccess {
                print("Could not create new zone.")
            }
        }
    }
    
    //MARK: - CRUD
    /// Creates new Record in CloudKit.
    /// - parameter record: The record to be created
    /// - parameter completion: Handler for when the purchase has been created.
    /// - parameter isSuccess: Confirms the new purchase was created.
    /// - parameter newRecord: The new Record or nil.
    func create(record: CKRecord, completion: @escaping (_ isSuccess: Bool, _ newRecord: CKRecord?) -> Void) {
        
        saveChangestoCK(recordsToUpdate: [record], purchasesToDelete: []) { (isSuccess, savedRecords, _) in
            if isSuccess {
                guard let newRecord = savedRecords?.first , newRecord.recordID == record.recordID else {
                    completion(false, nil)
                    return
                }
                completion(true,newRecord)
            } else {
                completion(false, nil)
            }
        }
    }
    
    ///Creates a Custom Zone.
    /// - parameter name: The name of the custom recordZone.
    /// - parameter completion: Handler for creating the zone.
    /// - parameter isSuccess: Confirms there was a zone with Updates.
    /// - parameter newRecordZone: The new recordZone created. Or nil if error.
    func createZone(withName name : String, completion: @escaping (_ isSuccess: Bool, _ newRecordZone:CKRecordZone?) -> Void) {
        
        let newRecordZone = CKRecordZone(zoneName: name)
        let fetch = CKModifyRecordZonesOperation(recordZonesToSave: [newRecordZone], recordZoneIDsToDelete: nil)
        
        fetch.modifyRecordZonesCompletionBlock = { (savedRecordZones,_,error)in
            if let error = error {
                print("Error creating record with name: \(name) has occured: \(error), \(error.localizedDescription)")
                completion(false,nil)
            }
            
            guard let recordZone = savedRecordZones?.first, recordZone.zoneID.zoneName == name else {completion(false,nil);return}
            completion(true, recordZone)
        }
        
        privateDB.add(fetch)
    }

    
    ///Function to fetch the updated RecordZone
    /// - parameter completion: Handler for the feched Zone.
    /// - parameter isSuccess: Confirms there was a zone with Updates.
    /// - parameter updatedZone: The updated Zone (can be nil).
    private func fetchUpdatedZone(completion: @escaping (_ isSuccess: Bool, _ updatedZone: CKRecordZone.ID?) -> Void) {
        let serverChangeTokenData = UserDefaults(suiteName: "group.com.oskman.DaysInARowGroup")?.data(forKey: CloudKitController.zoneChangeServerToken) ?? Data()
        
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
                UserDefaults(suiteName: "group.com.oskman.DaysInARowGroup")?.set(data, forKey: CloudKitController.zoneChangeServerToken)
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
                UserDefaults(suiteName: "group.com.oskman.DaysInARowGroup")?.set(data, forKey: CloudKitController.zoneChangeServerToken)
            } catch {
                print("Error encoding the token for UserDefualts: \(String(describing: error)) \(error.localizedDescription))")
            }
        }
        
        fetch.recordZoneWithIDChangedBlock = { (recordZoneID) in
            completion(true,recordZoneID)
        }
        privateDB.add(fetch)
    }
    
    ///Gets all the updated records form CloudKit
    /// - parameter completion: Handler for the feched Records.
    /// - parameter isSuccess: Confirms that records where able to be fetched.
    /// - parameter updatedPurchases: The updated records (can be empty).
    /// - parameter updatedPurchases: The deleted recordIDS (can be empty).
    func fetchUpdatedRecordsFromCK(completion: @escaping(_ isSuccess: Bool,_ updatedPurchases:[CKRecord], _ deletedPurchases: [CKRecord.ID])-> Void ) {
        var deletedRecordIDs: [CKRecord.ID] = []
        var updatedRecords: [CKRecord] = []
        
        fetchUpdatedZone { [weak self] (isSuccess, updatedZoneID) in
            if isSuccess {
                guard let updatedZoneID = updatedZoneID else {return}
                
                
                let serverChangeTokenData = UserDefaults(suiteName: "group.com.oskman.DaysInARowGroup")?.data(forKey: CloudKitController.updatesInZoneServerToken) ?? Data()
                
                let token: CKServerChangeToken?
                do {
                    token = try NSKeyedUnarchiver.unarchivedObject(ofClass: CKServerChangeToken.self, from: serverChangeTokenData)
                } catch {
                    token = nil
                }
                
                let fetch = CKFetchRecordZoneChangesOperation(recordZoneIDs: [updatedZoneID], configurationsByRecordZoneID: [updatedZoneID: CKFetchRecordZoneChangesOperation.ZoneConfiguration(previousServerChangeToken: token, resultsLimit: nil, desiredKeys: nil)])
                
                fetch.recordChangedBlock = { (updatedRecord) in
                    updatedRecords.append(updatedRecord)
                }
                fetch.recordWithIDWasDeletedBlock = { (deletedRecordID,_) in
                    deletedRecordIDs.append(deletedRecordID)
                }
                fetch.recordZoneFetchCompletionBlock = { (_,newServerChangeToken,_,_,error) in
                    if let error = error {
                        print("An Error fetching updates in Zone has occured. \(error), \(error.localizedDescription)")
                        completion(false, updatedRecords,deletedRecordIDs)
                        return
                    }
                    guard let newToken = newServerChangeToken else {completion(false,updatedRecords,deletedRecordIDs); return}
                    do {
                        let data = try NSKeyedArchiver.archivedData(withRootObject: newToken, requiringSecureCoding: false)
                        UserDefaults(suiteName: "group.com.oskman.DaysInARowGroup")?.set(data, forKey: CloudKitController.updatesInZoneServerToken)
                    } catch {
                        print("Error encoding the token for UserDefualts: \(String(describing: error)) \(error.localizedDescription))")
                    }
                }
                
                fetch.fetchRecordZoneChangesCompletionBlock = { error in
                    if let error = error {
                        print("An Error fetching updates from CK has occured. \(error), \(error.localizedDescription)")
                        completion(false, updatedRecords,deletedRecordIDs)
                        return
                    } else {
                        completion(true, updatedRecords,deletedRecordIDs)
                    }
                }
                
                self?.privateDB.add(fetch)
                
            } else {
                completion(false,updatedRecords,deletedRecordIDs)
            }
        }
    }
    
    /// Updates the record if the record exists in the source of truth.
    /// - parameter record: The record that needs updating.
    /// - parameter completion: Handler for when the record has been updated.
    /// - parameter isSuccess: Confirms the new record was updated.
    /// - parameter updatedRecord: The updated record or nil if the record could not be updated in CloudKit.
    func update(record: CKRecord, completion: @escaping (_ isSuccess: Bool, _ updatedRecord: CKRecord?) -> Void) {
        
        saveChangestoCK(recordsToUpdate: [record], purchasesToDelete: []) { (isSuccess, savedRecords, _) in
            if isSuccess {
                guard let updatedRecord = savedRecords?.first , updatedRecord.recordID == updatedRecord.recordID else {
                        completion(false, nil)
                        return
                }
                completion(true,updatedRecord)
            } else {
                completion(false, nil)
            }
        }
    }
    
    /// Deletes the record if the record exists in the source of truth.
    /// - parameter record: The record that needs deleting
    /// - parameter completion: Handler for when the record has been deleted
    /// - parameter isSuccess: Confirms the record was deleted.
    func delete(record: CKRecord, completion: @escaping (_ isSuccess: Bool) -> Void) {
    
        saveChangestoCK(recordsToUpdate: [], purchasesToDelete: [record.recordID]) { (isSuccess, _, deletedRecordIDs) in
            if isSuccess {
                guard let recordID = deletedRecordIDs?.first , recordID == record.recordID else {
                    completion(false)
                    return
                }
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    //MARK: - Subscribtion
    ///Subscribes to all new changes in the given CKRecordZone.
    /// - parameter zone: The zone to subrscribe to changes to.
    func subscribeToNewChanges(forRecodZone zone: CKRecordZone) {
        let privateZoneID = CKRecordZone.ID(zoneName: Purchase.privateRecordZoneName, ownerName: CKCurrentUserDefaultName)
        
        let subscription = CKRecordZoneSubscription(zoneID: zone.zoneID, subscriptionID: CloudKitController.privateSubID)
        
        
        let notificationInfo = CKSubscription.NotificationInfo()
        notificationInfo.title = "New Record"
        notificationInfo.alertBody = "New Record available"
        
        subscription.notificationInfo = notificationInfo
        
        privateDB.save(subscription) { (_, error) in
            if let error = error {
                print("An Error signing up for a subscribtion has occured: \(error), \(error.localizedDescription)")
                return
            }
        }
    }
    
    ///Removes Subscribtion with given ID.
    /// - parameter subscribtionID: The zone to subrscribe to changes to.
    func removeSubscribtion(withSubscribtionID subscribtionID: String) {
        
//        let modifyOperation = CKModifySubscriptionsOperation(subscriptionsToSave: <#T##[CKSubscription]?#>, subscriptionIDsToDelete: <#T##[CKSubscription.ID]?#>)
//
//        modifyOperation.modifySubscriptionsCompletionBlock = { (_,_,_) in
//
//        }
//
//        privateDB.add(modifyOperation)
        
    }
    
    //MARK: - Save
    /// Updates and Deletes changes to CloudKit.
    /// - parameter records: Records that where updated or created.
    /// - parameter recordIDs: RecordIDs of record that need deleted.
    /// - parameter completion: Handler for when the Record has been deleted or updated/saved.
    /// - parameter isSuccess: Confirms that the change has synced to CloudKit.
    /// - parameter savedRecords: The saved records (can be nil).
    /// - parameter deletedRecordIDs: The deleted recordIDs (can be nil).
    func saveChangestoCK(recordsToUpdate records: [CKRecord], purchasesToDelete recordIDs: [CKRecord.ID], completion: @escaping (_ isSuccess: Bool,_ savedRecords: [CKRecord]?, _ deletedRecordIDs: [CKRecord.ID]?) -> Void) {
        let operation = CKModifyRecordsOperation(recordsToSave: records, recordIDsToDelete: recordIDs)
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
