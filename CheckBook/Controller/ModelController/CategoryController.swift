//
//  CategoryController.swift
//  CheckBook
//
//  Created by Dominic Lanzillotta on 4/8/19.
//  Copyright © 2019 Dominic Lanzillotta. All rights reserved.
//

import Foundation
import CloudKit

class CategoryController {
    
    //MARK: - Singleton
    /// The shared Instance of CategoryController.
    static let shared = CategoryController()
    
    //MARK: - CRUD
    /// Creates new Category using the convenience initilizer inside the CoredataStack.context and tries to uploads it to CloudKit. If the upload fails the new Category gets added to the CacheContext for a later try.
    /// - parameter name: The name of the Category.
    /// - parameter ledgerUUID: The uuid of the parent.
    func createNewCategoryWith(name: String, ledgerUUID: UUID) -> Category {
        let newCategory = Category(name: name, ledgerUUID: ledgerUUID)
        CoreDataController.shared.saveToPersistentStore()
        
        let zoneID: CKRecordZone.ID
        if let currentZoneID = CloudKitController.shared.currentRecordZoneID {
            zoneID = currentZoneID
        } else {
            zoneID = CKRecordZone.ID(zoneName: Purchase.privateRecordZoneName, ownerName: CKCurrentUserDefaultName)
        }
        
        guard let newRecord = CKRecord(category: newCategory, zoneID: zoneID) else {return newCategory}
        
        let dataBase: CKDatabase
        if UserDefaults(suiteName: "group.com.oskman.DaysInARowGroup")?.bool(forKey: "isParticipant") ?? false {
            dataBase = CloudKitController.shared.shareDB
        } else {
            dataBase = CloudKitController.shared.privateDB
        }
        
        CloudKitController.shared.create(record: newRecord, inDataBase: dataBase) { (isSuccess, newPurchase) in
            if !isSuccess {
                guard let uuid = newCategory.uuid else {return}
                SyncController.shared.saveFailedUpload(withFailedPurchaseUUID: uuid)
            }
        }
        return newCategory
    }
    
    /// Updates the Category and resets the last modified parameter and updates the object in the CoredataStack.context. It tries to upload it to CloudKit.If the upload fails the Category gets added to the CacheContext for a later try.
    /// - parameter category: The Category to update.
    /// - parameter name: The updated name of the category.
    /// - parameter color: The updated color of the category.
    func update(category: Category, withNewName name:String?, andWithNewColor color:String?) {
        if let name = name {category.name = name}
        if let color = color {category.color = color}
        category.lastModified = Date()
        CoreDataController.shared.saveToPersistentStore()
        
        let zoneID: CKRecordZone.ID
        if let currentZoneID = CloudKitController.shared.currentRecordZoneID {
            zoneID = currentZoneID
        } else {
            zoneID = CKRecordZone.ID(zoneName: Purchase.privateRecordZoneName, ownerName: CKCurrentUserDefaultName)
        }
        
        guard let recordToUpdate = CKRecord(category: category, zoneID: zoneID) else {return}
        
        let dataBase: CKDatabase
        if UserDefaults(suiteName: "group.com.oskman.DaysInARowGroup")?.bool(forKey: "isParticipant") ?? false {
            dataBase = CloudKitController.shared.shareDB
        } else {
            dataBase = CloudKitController.shared.privateDB
        }
        
        CloudKitController.shared.update(record: recordToUpdate, inDataBase: dataBase) { (isSuccess, updatedPurchase) in
            if !isSuccess {
                guard let uuid = category.uuid else {return}
                SyncController.shared.saveFailedUpload(withFailedPurchaseUUID: uuid)
            }
        }
    }
    
    ///Changes to current Category reference to a different Category and saves the change to CloudKit.
    /// - parameter oldCategory: The old Category.
    /// - parameter purchase: The purchase to update.
    /// - parameter newCategory: The new Category.
    func change(category oldCategory: Category, ofPurchase purchase: Purchase, toCategory newCategory: Category) {
        
        oldCategory.removeFromPurchases(purchase)
        purchase.category = newCategory
        newCategory.addToPurchases(purchase)
        purchase.lastModified = Date() as NSDate
        newCategory.lastModified = Date()
        oldCategory.lastModified = Date()
        
        let zoneID: CKRecordZone.ID
        if let currentZoneID = CloudKitController.shared.currentRecordZoneID {
            zoneID = currentZoneID
        } else {
            zoneID = CKRecordZone.ID(zoneName: Purchase.privateRecordZoneName, ownerName: CKCurrentUserDefaultName)
        }
                
        guard let oldCategoryRecord = CKRecord(category: oldCategory, zoneID: zoneID),
            let newCategoryRecord = CKRecord(category: newCategory, zoneID: zoneID),
            let purchaseRecord = CKRecord(purchase: purchase, zoneID: zoneID) else {return}
        
        let dataBase: CKDatabase
        if UserDefaults(suiteName: "group.com.oskman.DaysInARowGroup")?.bool(forKey: "isParticipant") ?? false {
            dataBase = CloudKitController.shared.shareDB
        } else {
            dataBase = CloudKitController.shared.privateDB
        }
        
        CloudKitController.shared.saveChangestoCK(recordsToUpdate: [oldCategoryRecord,newCategoryRecord,purchaseRecord], purchasesToDelete: [], toDataBase: dataBase) { (isSuccess, updatedRecords, _) in
            if !isSuccess {
                guard let uuid = purchase.uuid else {return}
                SyncController.shared.saveFailedUpload(withFailedPurchaseUUID: uuid)
                guard let uuidOfOld = oldCategory.uuid else {return}
                SyncController.shared.saveFailedUpload(withFailedPurchaseUUID: uuidOfOld)
                guard let uuidOfNew = newCategory.uuid else {return}
                SyncController.shared.saveFailedUpload(withFailedPurchaseUUID: uuidOfNew)
            }
        }
        CoreDataController.shared.saveToPersistentStore()
    }
    
    /// Deletes the Category, deletes it from Cotext and CloudKit. If the CK delete Fails the Category gets added to the cache for uploading at a later date.
    /// - parameter category: The category to delete.
    func delete(category: Category) {
        let zoneID: CKRecordZone.ID
        if let currentZoneID = CloudKitController.shared.currentRecordZoneID {
            zoneID = currentZoneID
        } else {
            zoneID = CKRecordZone.ID(zoneName: Purchase.privateRecordZoneName, ownerName: CKCurrentUserDefaultName)
        }
        
        guard let recordToDelete = CKRecord(category: category, zoneID: zoneID) else {return}
        
        let dataBase: CKDatabase
        if UserDefaults(suiteName: "group.com.oskman.DaysInARowGroup")?.bool(forKey: "isParticipant") ?? false {
            dataBase = CloudKitController.shared.shareDB
        } else {
            dataBase = CloudKitController.shared.privateDB
        }
        
        CloudKitController.shared.delete(record: recordToDelete, inDataBase: dataBase) { (isSuccess) in
            if !isSuccess {
                guard let uuid = category.uuid else {return}
                SyncController.shared.saveFailedUpload(withFailedPurchaseUUID: uuid)
            }
        }
        CoreDataController.shared.remove(object: category)
    }
}
