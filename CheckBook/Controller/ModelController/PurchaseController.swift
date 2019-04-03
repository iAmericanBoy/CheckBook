//
//  PurchaseController.swift
//  CheckBook
//
//  Created by Dominic Lanzillotta on 3/5/19.
//  Copyright © 2019 Dominic Lanzillotta. All rights reserved.
//

import Foundation
import CloudKit

class PurchaseController {
    
    //MARK: - Singleton
    /// The shared Instance of PurchaseController.
    static let shared = PurchaseController()
    
    //MARK: - CRUD
    /// Creates new Purchase using the convenience initilizer inside the CoredataStack.context and tries to uploads it to CloudKit. If the upload fails the new Purchase gets added to the CacheContext for a later try.
    /// - parameter amount: The amount of the purchase.
    /// - parameter date: The date of the purchase.
    /// - parameter item: The itemName of the purchase.
    /// - parameter storeName: The storeName of the purchase.
    /// - parameter method: The method of payment of the purchase.
    /// - parameter ledger: The leger of the purchase.
    func createNewPurchaseWith(amount: Double, date: Date, item: String, storeName:String, purchaseMethod: PurchaseMethod, ledger: Ledger) {
        let purchase = Purchase(amount: amount, date: date, item: item, storeName: storeName, purchaseMethod: purchaseMethod, ledger: ledger)
        CoreDataController.shared.saveToPersistentStore()
        
        guard let recordToCreate = CKRecord(purchase: purchase) else {return}
        CloudKitController.shared.create(record: recordToCreate) { (isSuccess, newRecord) in
            if !isSuccess {
                guard let uuid = purchase.uuid else {return}
                SyncController.shared.saveFailedUpload(withFailedPurchaseUUID: uuid)
            }
        }
    }
    
    /// Updates the Purchase and resets the last modified parameter and updates the object in the CoredataStack.context. It tries to upload it to CloudKit.If the upload fails the new Purchase gets added to the CacheContext for a later try.
    /// - parameter purchase: The purchase to update.
    /// - parameter amount: The updated amount of the purchase.
    /// - parameter date: The updated date of the purchase.
    /// - parameter item: The updated itemName of the purchase.
    /// - parameter storeName: updated The storeName of the purchase.
    /// - parameter method: The updated method of payment of the purchase.
    func update(purchase: Purchase, amount:Double?, date: Date?, item: String?, storeName: String?, purchaseMethod: PurchaseMethod?) {
        if let amount = amount {purchase.amount = amount}
        if let date = date {purchase.date = date}
        if let item = item {purchase.item = item}
        if let storeName = storeName {purchase.storeName = storeName}
        if let purchaseMethod = purchaseMethod {purchase.purchaseMethod = purchaseMethod}
        purchase.lastModified = Date()
        CoreDataController.shared.saveToPersistentStore()
        guard let recordToUpdate = CKRecord(purchase: purchase) else {return}
        CloudKitController.shared.update(record: recordToUpdate) { (isSuccess, updatedPurchase) in
            if !isSuccess {
                guard let uuid = purchase.uuid else {return}
                SyncController.shared.saveFailedUpload(withFailedPurchaseUUID: uuid)
            }
        }
    }
    
    /// Deletes the Purchase, deletes it from Cotext and CloudKit. If the CK delete Fails the puchease gets added to the cache for uploading at a later date.
    /// - parameter purchase: The purchase to delete.
    func delete(purchase: Purchase) {
        guard let recordToDelete = CKRecord(purchase: purchase) else {return}
        CloudKitController.shared.delete(record: recordToDelete) { (isSuccess) in
            if !isSuccess {
                guard let uuid = purchase.uuid else {return}
                SyncController.shared.saveFailedUpload(withFailedPurchaseUUID: uuid)
            }
        }
        CoreDataController.shared.remove(object: purchase)
    }
}
