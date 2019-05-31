//
//  PurchaseMethodController.swift
//  CheckBook
//
//  Created by Dominic Lanzillotta on 3/9/19.
//  Copyright © 2019 Dominic Lanzillotta. All rights reserved.
//

import CloudKit
import Foundation

class PurchaseMethodController {
    // MARK: - Singleton
    
    /// The shared Instance of PurchaseMethodController.
    static let shared = PurchaseMethodController()
    
    // MARK: - CRUD
    
    /// Creates new PurchaseMethod using the convenience initilizer inside the CoredataStack.context and tries to uploads it to CloudKit. If the upload fails the new PurchaseMethod gets added to the CacheContext for a later try.
    /// - parameter name: The name of the purchaseMethod.
    /// - parameter ledger: The parent ledger.
    func createNewPurchaseMethodWith(name: String, withParentLedger ledger: Ledger) -> PurchaseMethod {
        let newPurchaseMethod = PurchaseMethod(name: name, ledger: ledger)
        CoreDataController.shared.saveToPersistentStore()
        
        guard let newRecord = CKRecord(purchaseMethod: newPurchaseMethod) else { return newPurchaseMethod }
        
        let dataBase: CKDatabase
        if UserDefaults(suiteName: "group.com.oskman.DaysInARowGroup")?.bool(forKey: "isParticipant") ?? false {
            dataBase = CloudKitController.shared.shareDB
        } else {
            dataBase = CloudKitController.shared.privateDB
        }
        
        CloudKitController.shared.create(record: newRecord, inDataBase: dataBase) { isSuccess, _ in
            if !isSuccess {
                guard let uuid = newPurchaseMethod.uuid else { return }
                SyncController.shared.saveFailedUpload(ofType: .method, withFailedPurchaseUUID: uuid)
            }
        }
        return newPurchaseMethod
    }
    
    /// Updates the PurchaseMethod and resets the last modified parameter and updates the object in the CoredataStack.context. It tries to upload it to CloudKit.If the upload fails the new PurchaseMethod gets added to the CacheContext for a later try.
    /// - parameter purchaseMethod: The PurchaseMethod to update.
    /// - parameter name: The updated name of the purchaseMethod.
    func update(purchaseMethod: PurchaseMethod, name: String?) {
        if let name = name { purchaseMethod.name = name }
        purchaseMethod.lastModified = Date()
        CoreDataController.shared.saveToPersistentStore()
        
        guard let recordToUpdate = CKRecord(purchaseMethod: purchaseMethod) else { return }
        
        let dataBase: CKDatabase
        if UserDefaults(suiteName: "group.com.oskman.DaysInARowGroup")?.bool(forKey: "isParticipant") ?? false {
            dataBase = CloudKitController.shared.shareDB
        } else {
            dataBase = CloudKitController.shared.privateDB
        }
        
        CloudKitController.shared.update(record: recordToUpdate, inDataBase: dataBase) { isSuccess, _ in
            if !isSuccess {
                guard let uuid = purchaseMethod.uuid else { return }
                SyncController.shared.saveFailedUpload(ofType: .method, withFailedPurchaseUUID: uuid)
            }
        }
    }
    
    /// Changes to current PurchaseMethod reference to a different PurchaseMethod and saves the change to CloudKit.
    /// - parameter oldPurchaseMethod: The old purchaseMethod.
    /// - parameter purchase: The purchase to update.
    /// - parameter newPurchaseMethod: The new purchaseMethod.
    func change(purchaseMethod oldPurchaseMethod: PurchaseMethod, ofPurchase purchase: Purchase, toPurchaseMethod newPurchaseMethod: PurchaseMethod) {
        oldPurchaseMethod.removeFromPurchases(purchase)
        purchase.purchaseMethod = newPurchaseMethod
        newPurchaseMethod.addToPurchases(purchase)
        purchase.lastModified = Date() as NSDate
        newPurchaseMethod.lastModified = Date()
        oldPurchaseMethod.lastModified = Date()
        
        guard let oldPurchaseMethodRecord = CKRecord(purchaseMethod: oldPurchaseMethod),
            let newPurchaseMethodRecord = CKRecord(purchaseMethod: newPurchaseMethod),
            let purchaseRecord = CKRecord(purchase: purchase) else { return }
        
        let dataBase: CKDatabase
        if UserDefaults(suiteName: "group.com.oskman.DaysInARowGroup")?.bool(forKey: "isParticipant") ?? false {
            dataBase = CloudKitController.shared.shareDB
        } else {
            dataBase = CloudKitController.shared.privateDB
        }
        
        CloudKitController.shared.saveChangestoCK(recordsToUpdate: [oldPurchaseMethodRecord, newPurchaseMethodRecord, purchaseRecord], purchasesToDelete: [], toDataBase: dataBase) { isSuccess, _, _ in
            if !isSuccess {
                guard let uuid = purchase.uuid else { return }
                SyncController.shared.saveFailedUpload(ofType: .purchase, withFailedPurchaseUUID: uuid)
                guard let uuidOfOld = oldPurchaseMethod.uuid else { return }
                SyncController.shared.saveFailedUpload(ofType: .method, withFailedPurchaseUUID: uuidOfOld)
                guard let uuidOfNew = newPurchaseMethod.uuid else { return }
                SyncController.shared.saveFailedUpload(ofType: .method, withFailedPurchaseUUID: uuidOfNew)
            }
        }
        CoreDataController.shared.saveToPersistentStore()
    }
    
    /// Deletes the PurchaseMethod, deletes it from Cotext and CloudKit. If the CK delete Fails the PurchaseMethod gets added to the cache for uploading at a later date.
    /// - parameter purchase: The purchaseMethod to delete.
    func delete(purchaseMethod: PurchaseMethod) {
        guard let recordToDelete = CKRecord(purchaseMethod: purchaseMethod) else { return }
        
        let dataBase: CKDatabase
        if UserDefaults(suiteName: "group.com.oskman.DaysInARowGroup")?.bool(forKey: "isParticipant") ?? false {
            dataBase = CloudKitController.shared.shareDB
        } else {
            dataBase = CloudKitController.shared.privateDB
        }
        
        CloudKitController.shared.delete(record: recordToDelete, inDataBase: dataBase) { isSuccess in
            if !isSuccess {
                guard let uuid = purchaseMethod.uuid else { return }
                SyncController.shared.saveFailedUpload(ofType: .method, withFailedPurchaseUUID: uuid)
            }
        }
        CoreDataController.shared.remove(object: purchaseMethod)
    }
}
