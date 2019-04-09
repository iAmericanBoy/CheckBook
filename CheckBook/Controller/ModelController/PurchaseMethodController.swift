//
//  PurchaseMethodController.swift
//  CheckBook
//
//  Created by Dominic Lanzillotta on 3/9/19.
//  Copyright © 2019 Dominic Lanzillotta. All rights reserved.
//

import Foundation
import CloudKit

class PurchaseMethodController {
    
    //MARK: - Singleton
    /// The shared Instance of PurchaseMethodController.
    static let shared = PurchaseMethodController()
    
    //MARK: - CRUD
    /// Creates new PurchaseMethod using the convenience initilizer inside the CoredataStack.context and tries to uploads it to CloudKit. If the upload fails the new PurchaseMethod gets added to the CacheContext for a later try.
    /// - parameter name: The name of the purchaseMethod.
    func createNewPurchaseMethodWith(name: String) -> PurchaseMethod {
        let newPurchaseMethod = PurchaseMethod(name: name)
        CoreDataController.shared.saveToPersistentStore()
        
        guard let newRecord = CKRecord(purchaseMethod: newPurchaseMethod) else {return newPurchaseMethod}

        CloudKitController.shared.create(record: newRecord) { (isSuccess, newPurchase) in
            if !isSuccess {
                guard let uuid = newPurchaseMethod.uuid else {return}
                SyncController.shared.saveFailedUpload(withFailedPurchaseUUID: uuid)
            }
        }
        return newPurchaseMethod
    }
    
    /// Updates the PurchaseMethod and resets the last modified parameter and updates the object in the CoredataStack.context. It tries to upload it to CloudKit.If the upload fails the new PurchaseMethod gets added to the CacheContext for a later try.
    /// - parameter purchaseMethod: The PurchaseMethod to update.
    /// - parameter name: The updated name of the purchaseMethod.
    func update(purchaseMethod: PurchaseMethod, name:String?) {
        if let name = name {purchaseMethod.name = name}
        purchaseMethod.lastModified = Date()
        CoreDataController.shared.saveToPersistentStore()
        
        guard let recordToUpdate = CKRecord(purchaseMethod: purchaseMethod) else {return}

        CloudKitController.shared.update(record: recordToUpdate) { (isSuccess, updatedPurchase) in
            if !isSuccess {
                guard let uuid = purchaseMethod.uuid else {return}
                SyncController.shared.saveFailedUpload(withFailedPurchaseUUID: uuid)
            }
        }
    }
    
    ///Changes to current PurchaseMethod reference to a different PurchaseMethod and saves the change to CloudKit.
    /// - parameter oldPurchaseMethod: The old purchaseMethod.
    /// - parameter purchase: The purchase to update.
    /// - parameter newPurchaseMethod: The new purchaseMethod.
    func change(purchaseMethod oldPurchaseMethod: PurchaseMethod, ofPurchase purchase: Purchase, toPurchaseMethod newPurchaseMethod: PurchaseMethod) {
        
        oldPurchaseMethod.removeFromPurchases(purchase)
        purchase.purchaseMethod = newPurchaseMethod
        newPurchaseMethod.addToPurchases(purchase)
        purchase.lastModified = Date()
        newPurchaseMethod.lastModified = Date()
        oldPurchaseMethod.lastModified = Date()

        guard let oldPurchaseMethodRecord = CKRecord(purchaseMethod: oldPurchaseMethod),
            let newPurchaseMethodRecord = CKRecord(purchaseMethod: newPurchaseMethod),
            let purchaseRecord = CKRecord(purchase: purchase) else {return}

        CloudKitController.shared.saveChangestoCK(recordsToUpdate: [oldPurchaseMethodRecord,newPurchaseMethodRecord,purchaseRecord], purchasesToDelete: []) { (isSuccess, updatedRecords, _) in
            if !isSuccess {
                guard let uuid = purchase.uuid else {return}
                SyncController.shared.saveFailedUpload(withFailedPurchaseUUID: uuid)
                guard let uuidOfOld = oldPurchaseMethod.uuid else {return}
                SyncController.shared.saveFailedUpload(withFailedPurchaseUUID: uuidOfOld)
                guard let uuidOfNew = newPurchaseMethod.uuid else {return}
                SyncController.shared.saveFailedUpload(withFailedPurchaseUUID: uuidOfNew)
            }
        }
        CoreDataController.shared.saveToPersistentStore()
    }
    
    /// Deletes the PurchaseMethod, deletes it from Cotext and CloudKit. If the CK delete Fails the PurchaseMethod gets added to the cache for uploading at a later date.
    /// - parameter purchase: The purchaseMethod to delete.
    func delete(purchaseMethod: PurchaseMethod) {
        
        guard let recordToDelete = CKRecord(purchaseMethod: purchaseMethod) else {return}

        CloudKitController.shared.delete(record: recordToDelete) { (isSuccess) in
            if !isSuccess {
                guard let uuid = purchaseMethod.uuid else {return}
                SyncController.shared.saveFailedUpload(withFailedPurchaseUUID: uuid)
            }
        }
        CoreDataController.shared.remove(object: purchaseMethod)
    }
}
