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
    /// - parameter category: The category of the purchase.
    func createNewPurchaseWith(amount: NSDecimalNumber, date: Date, item: String, storeName:String, purchaseMethod: PurchaseMethod, ledger: Ledger, category: Category) {
        let purchase = Purchase(amount: amount, date: date, item: item, storeName: storeName, purchaseMethod: purchaseMethod, category: category, appleUserRecordName: CloudKitController.shared.appleUserID?.recordName, ledger: ledger)
        CoreDataController.shared.saveToPersistentStore()
        
        let dataBase: CKDatabase
        if UserDefaults(suiteName: "group.com.oskman.DaysInARowGroup")?.bool(forKey: "isParticipant") ?? false {
            dataBase = CloudKitController.shared.shareDB
        } else {
            dataBase = CloudKitController.shared.privateDB
        }

        guard let recordToCreate = CKRecord(purchase: purchase) else {return}
        CloudKitController.shared.create(record: recordToCreate, inDataBase: dataBase) { (isSuccess, newRecord) in
            if !isSuccess {
                guard let uuid = purchase.uuid else {return}
                SyncController.shared.saveFailedUpload(ofType: .purchase, withFailedPurchaseUUID: uuid)
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
    /// - parameter category: The updated category of the purchase.
    func update(purchase: Purchase, amount:Decimal?, date: Date?, item: String?, storeName: String?, purchaseMethod: PurchaseMethod?, category: Category?) {
        if let amount = amount {purchase.amount = amount as NSDecimalNumber}
        if let date = date {purchase.date = date as NSDate}
        if let item = item {purchase.item = item}
        if let storeName = storeName {purchase.storeName = storeName}
        if let purchaseMethod = purchaseMethod {purchase.purchaseMethod = purchaseMethod}
        if let category = category {purchase.category = category}

        purchase.lastModified = Date() as NSDate
        CoreDataController.shared.saveToPersistentStore()
        
        let dataBase: CKDatabase
        if UserDefaults(suiteName: "group.com.oskman.DaysInARowGroup")?.bool(forKey: "isParticipant") ?? false {
            dataBase = CloudKitController.shared.shareDB
        } else {
            dataBase = CloudKitController.shared.privateDB
        }
        
        
        guard let recordToUpdate = CKRecord(purchase: purchase) else {return}
        CloudKitController.shared.update(record: recordToUpdate, inDataBase: dataBase) { (isSuccess, updatedPurchase) in
            if !isSuccess {
                guard let uuid = purchase.uuid else {return}
                SyncController.shared.saveFailedUpload(ofType: .method, withFailedPurchaseUUID: uuid)
            }
        }
    }
    
    /// Deletes the Purchase, deletes it from Cotext and CloudKit. If the CK delete Fails the puchease gets added to the cache for uploading at a later date.
    /// - parameter purchase: The purchase to delete.
    func delete(purchase: Purchase) {
        
        let dataBase: CKDatabase
        if UserDefaults(suiteName: "group.com.oskman.DaysInARowGroup")?.bool(forKey: "isParticipant") ?? false {
            dataBase = CloudKitController.shared.shareDB
        } else {
            dataBase = CloudKitController.shared.privateDB
        }
        
        guard let recordToDelete = CKRecord(purchase: purchase) else {return}
        
        CloudKitController.shared.delete(record: recordToDelete, inDataBase: dataBase) { (isSuccess) in
            if !isSuccess {
                guard let uuid = purchase.uuid else {return}
                SyncController.shared.saveFailedUpload(ofType: .purchase, withFailedPurchaseUUID: uuid)
            }
        }
        CoreDataController.shared.remove(object: purchase)
    }
}
