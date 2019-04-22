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
    let privateDB = CKContainer.default().privateCloudDatabase
    /// The public Database of the User.
    let publicDB = CKContainer.default().publicCloudDatabase
    /// The shared Database of the User.
    let shareDB = CKContainer.default().sharedCloudDatabase
    
    /// The current Share or nil if not used
    var currentShare: CKShare? {
        didSet {
            confirmShareSettings()
        }
    }
    var currentRecordZoneID: CKRecordZone.ID?

    ///The RecordID of the logged in iCloud user
    var appleUserID: CKRecord.ID? {
        didSet {
            NotificationCenter.default.post(Notification.appleIdFound)
        }
    }
    
    //MARK: - INIT
    init() {
        createZone(withName: Purchase.privateRecordZoneName) { (isSuccess, newZone) in
            if !isSuccess {
                print("private zone NOT available")
            } else {
                print("private zone available")
            }
            self.fetchUserRecordID { (isSuccess) in
                if isSuccess {
                    print("AppleUserID found")
                } else {
                    print("AppleUserID NOT found")
                }
            }
        }
    }
    
    //MARK: - CRUD
    /// Creates new Record in CloudKit.
    /// - parameter record: The record to be created
    /// - parameter database: The database where the record should be saved in
    /// - parameter completion: Handler for when the purchase has been created.
    /// - parameter isSuccess: Confirms the new purchase was created.
    /// - parameter newRecord: The new Record or nil.
    func create(record: CKRecord, inDataBase dataBase: CKDatabase = CloudKitController.shared.privateDB, completion: @escaping (_ isSuccess: Bool, _ newRecord: CKRecord?) -> Void) {
        saveChangestoCK(recordsToUpdate: [record], purchasesToDelete: [], toDataBase: dataBase) { (isSuccess, savedRecords, _) in
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
    
    ///Fetches the UserRecordID.
    /// - parameter completion: Handler for when the UserRecord could be found.
    /// - parameter isSuccess: Confirms the record could be found.
    /// - parameter newRecord: The recordID or nil.
    func fetchUserRecordID(_ completion: @escaping (_ isSuccess:Bool) -> Void) {
        CKContainer.default().fetchUserRecordID { (appleUserRecord, error) in
            if let error = error {
                print("There was an error fetching users appleID from cloudkit: \(error)")
                completion(false)
                return
            }
            guard let appleUserRecord = appleUserRecord else {completion(false); return}
            self.appleUserID = appleUserRecord

            completion(true)
        }
    }

    
    ///Function to fetch the updated RecordZone
    /// - parameter completion: Handler for the feched Zone.
    /// - parameter isSuccess: Confirms there was a zone with Updates.
    /// - parameter updatedZone: The updated Zone (can be nil).
    private func fetchUpdatedZone(inDataBase dataBase: CKDatabase = shared.privateDB , completion: @escaping (_ isSuccess: Bool, _ updatedZone: CKRecordZone.ID?) -> Void) {
        
        let key = dataBase == privateDB ? CloudKitController.privateServerChangeToken : CloudKitController.shareSubscribtionID
        
        let serverChangeTokenData = UserDefaults(suiteName: "group.com.oskman.DaysInARowGroup")?.data(forKey: key) ?? Data()
        
        let token: CKServerChangeToken?
        do {
            token = try NSKeyedUnarchiver.unarchivedObject(ofClass: CKServerChangeToken.self, from: serverChangeTokenData)
        } catch {
            token = nil
        }
        
        let fetch = CKFetchDatabaseChangesOperation(previousServerChangeToken: token)
        fetch.qualityOfService = .userInitiated
        
        fetch.changeTokenUpdatedBlock = { (newToken) in
            do {
                let data = try NSKeyedArchiver.archivedData(withRootObject: newToken, requiringSecureCoding: false)
                UserDefaults(suiteName: "group.com.oskman.DaysInARowGroup")?.set(data, forKey: key)
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
                UserDefaults(suiteName: "group.com.oskman.DaysInARowGroup")?.set(data, forKey: key)
            } catch {
                print("Error encoding the token for UserDefualts: \(String(describing: error)) \(error.localizedDescription))")
            }
        }
        
        fetch.recordZoneWithIDChangedBlock = { (recordZoneID) in
            completion(true,recordZoneID)
        }
        dataBase.add(fetch)
    }
    
    ///Gets all the updated records form CloudKit
    /// - parameter completion: Handler for the feched Records.
    /// - parameter isSuccess: Confirms that records where able to be fetched.
    /// - parameter updatedPurchases: The updated records (can be empty).
    /// - parameter updatedPurchases: The deleted recordIDS (can be empty).
    func fetchUpdatedRecordsFromCK(inDataBase database: CKDatabase = shared.privateDB ,completion: @escaping(_ isSuccess: Bool,_ updatedPurchases:[CKRecord], _ deletedPurchases: [CKRecord.ID])-> Void ) {
        var deletedRecordIDs: [CKRecord.ID] = []
        var updatedRecords: [CKRecord] = []
        
        let key = database == privateDB ? CloudKitController.updatesInPrivateZoneServerToken : CloudKitController.updatesInSharedZoneServerToken
        
        fetchUpdatedZone(inDataBase: database) { (isSuccess, updatedZoneID) in
            if isSuccess {
                guard let updatedZoneID = updatedZoneID else {return}
                
                
                let serverChangeTokenData = UserDefaults(suiteName: "group.com.oskman.DaysInARowGroup")?.data(forKey: key) ?? Data()
                
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
                        UserDefaults(suiteName: "group.com.oskman.DaysInARowGroup")?.set(data, forKey: key)
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
                
                database.add(fetch)
                
            } else {
                completion(false,updatedRecords,deletedRecordIDs)
            }
        }
    }
    
    ///Fetches the Metadata of a share for a given URL. Assigns the ZoneID of the RootRecord to the property in the CloudKitController. Assigns the Share to the currentshare Property.
    /// - parameter url: The URL for the CKShare.
    /// - parameter completion: Handler for when the Share.Meta was found.
    /// - parameter isSuccess: Confirms the Share.Meta was found.
    func fetchShareMetadata(forURL url: URL, _ completion: @escaping (_ isSuccess:Bool) -> Void) {
        
        let operation = CKFetchShareMetadataOperation(shareURLs: [url])
        operation.perShareMetadataBlock = { (shareUrl,fetchedMeta,error) in
            if let error = error {
                print("There was an error fetching the ShareMetaData for the URL: \(error)")
                completion(false)
                return
            }
            
            guard let meta = fetchedMeta, url == shareUrl else {completion(false); return}
            self.currentRecordZoneID =  meta.rootRecordID.zoneID
            self.currentShare = meta.share
            completion(true)
        }
        
        operation.fetchShareMetadataCompletionBlock = { error in
            if let error = error {
                print("There was an error fetching the ShareMetaData for the URL: \(error)")
                completion(false)
                return
            }
        }
        CKContainer.default().add(operation)
    }
    
    /// Updates the record if the record exists in the source of truth.
    /// - parameter record: The record that needs updating.
    /// - parameter database: The database where the record should be saved in
    /// - parameter completion: Handler for when the record has been updated.
    /// - parameter isSuccess: Confirms the new record was updated.
    /// - parameter updatedRecord: The updated record or nil if the record could not be updated in CloudKit.
    func update(record: CKRecord, inDataBase dataBase: CKDatabase = shared.privateDB, completion: @escaping (_ isSuccess: Bool, _ updatedRecord: CKRecord?) -> Void) {

        saveChangestoCK(recordsToUpdate: [record], purchasesToDelete: [], toDataBase: dataBase) { (isSuccess, savedRecords, _) in
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
    /// - parameter database: The database where the record should be saved in
    /// - parameter completion: Handler for when the record has been deleted
    /// - parameter isSuccess: Confirms the record was deleted.
    func delete(record: CKRecord, inDataBase dataBase: CKDatabase, completion: @escaping (_ isSuccess: Bool) -> Void) {

        saveChangestoCK(recordsToUpdate: [], purchasesToDelete: [record.recordID], toDataBase: dataBase) { (isSuccess, _, deletedRecordIDs) in
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
    
    /// Deletes all the recordZones and all of its contents in the private DataBase
    func deleteRecordZones() {
        privateDB.fetchAllRecordZones { (allZones, error) in
            if let error = error {
                print("An Error fetching all recordZones from CK has occured. \(error), \(error.localizedDescription)")
                return
            }
            let allZoneIDs = allZones?.compactMap({ $0.zoneID })
            let operation = CKModifyRecordZonesOperation(recordZonesToSave: [], recordZoneIDsToDelete: allZoneIDs)
            operation.modifyRecordZonesCompletionBlock = { (_,_,error) in
                if let error = error {
                    print("An Error deleteing all recordZones from CK has occured. \(error), \(error.localizedDescription)")
                    return
                }
            }
            
            self.privateDB.add(operation)
        }
    }
    
    //MARK: - Subscribtion
    ///Subscribes to all new changes in the given CKRecordZone.
    /// - parameter zone: The zone to subscribe to changes to.
    func subscribeToNewChanges(forRecodZone zone: CKRecordZone.ID? , inDataBase dataBase: CKDatabase = CloudKitController.shared.privateDB) {
        var subscription: CKSubscription
        
        if zone != nil {
            subscription = CKDatabaseSubscription(subscriptionID: CloudKitController.shareSubscribtionID)
        } else {
            let privateZoneID = CKRecordZone.ID(zoneName: Purchase.privateRecordZoneName, ownerName: CKCurrentUserDefaultName)
            subscription = CKRecordZoneSubscription(zoneID: privateZoneID, subscriptionID: CloudKitController.privateSubID)
        }
        
        let notificationInfo = CKSubscription.NotificationInfo()
        notificationInfo.title = "New Record"
        notificationInfo.alertBody = "New Record available"
        notificationInfo.shouldSendContentAvailable = true

        
        subscription.notificationInfo = notificationInfo
        
        dataBase.save(subscription) { (_, error) in
            if let error = error {
                print("An Error signing up for a subscribtion has occured: \(error), \(error.localizedDescription)")
                return
            }
        }
    }
    
    //MARK: - Save
    /// Updates and Deletes changes to CloudKit.
    /// - parameter records: Records that where updated or created.
    /// - parameter recordIDs: RecordIDs of record that need deleted.
    /// - parameter database: The database to save the changes to
    /// - parameter completion: Handler for when the Record has been deleted or updated/saved.
    /// - parameter isSuccess: Confirms that the change has synced to CloudKit.
    /// - parameter savedRecords: The saved records (can be nil).
    /// - parameter deletedRecordIDs: The deleted recordIDs (can be nil).
    func saveChangestoCK(recordsToUpdate records: [CKRecord], purchasesToDelete recordIDs: [CKRecord.ID], toDataBase dataBase: CKDatabase = CloudKitController.shared.privateDB, completion: @escaping (_ isSuccess: Bool,_ savedRecords: [CKRecord]?, _ deletedRecordIDs: [CKRecord.ID]?) -> Void) {
        let operation = CKModifyRecordsOperation(recordsToSave: records, recordIDsToDelete: recordIDs)
        operation.savePolicy = .changedKeys
        operation.isAtomic = true
        operation.qualityOfService = .userInitiated
        operation.modifyRecordsCompletionBlock = { (savedRecords,deletedRecords,error) in
            if let error = error {
                print("An Error updating CK with \(String(describing: records.first?.recordType)) has occured. \(error), \(error.localizedDescription)")
                completion(false, savedRecords,deletedRecords)
                return
            }
            guard let saved = savedRecords, let deleted = deletedRecords else {completion(false,savedRecords,deletedRecords); return}
            completion(true,saved,deleted)
        }

        dataBase.add(operation)
    }
    
    
    //MARK: -
    func confirmShareSettings() {
        if currentShare?.owner.userIdentity.userRecordID == appleUserID {
            //Current User is Owner of share
            UserDefaults(suiteName: "group.com.oskman.DaysInARowGroup")?.set(true, forKey: "isSharing")
            UserDefaults(suiteName: "group.com.oskman.DaysInARowGroup")?.set(false, forKey: "isParticipant")
        } else {
            //Current User is Participant
            UserDefaults(suiteName: "group.com.oskman.DaysInARowGroup")?.set(true, forKey: "isParticipant")
            UserDefaults(suiteName: "group.com.oskman.DaysInARowGroup")?.set(false, forKey: "isSharing")
        }
    }
}
