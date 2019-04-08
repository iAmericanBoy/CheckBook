//
//  UserController.swift
//  CheckBook
//
//  Created by Dominic Lanzillotta on 4/8/19.
//  Copyright © 2019 Dominic Lanzillotta. All rights reserved.
//

import Foundation
import CloudKit

class UserController {
    
    //MARK: - Singleton
    /// The shared Instance of CategoryController.
    static let shared = UserController()
    
    //MARK: - CRUD
    /// Creates new User using the convenience initilizer inside the CoredataStack.context and tries to uploads it to CloudKit. If the upload fails the new User gets added to the CacheContext for a later try.
    /// - parameter name: The name of the User.
    func createNewUserWith(name: String) {
        guard let appleUserID = CloudKitController.shared.appleUserID else {return}
        let newUser = User(name: name, appleUserUUID: appleUserID.recordName)
        CoreDataController.shared.saveToPersistentStore()
        
        guard let newRecord = CKRecord(user: newUser) else {return}
        
        CloudKitController.shared.create(record: newRecord) { (isSuccess, newPurchase) in
            if !isSuccess {
                guard let uuid = newUser.uuid else {return}
                SyncController.shared.saveFailedUpload(withFailedPurchaseUUID: uuid)
            }
        }
    }
    
    /// Updates the User and resets the last modified parameter and updates the object in the CoredataStack.context. It tries to upload it to CloudKit.If the upload fails the Category gets added to the CacheContext for a later try.
    /// - parameter user: The User to update.
    /// - parameter name: The updated name of the user.
    /// - parameter color: The updated color of the user.
    func update(user: User, withNewName name:String?, andWithNewColor color:String?) {
        if let name = name {user.name = name}
        if let color = color {user.color = color}
        user.lastModified = Date()
        CoreDataController.shared.saveToPersistentStore()
        
        guard let recordToUpdate = CKRecord(user: user) else {return}
        
        CloudKitController.shared.update(record: recordToUpdate) { (isSuccess, updatedPurchase) in
            if !isSuccess {
                guard let uuid = user.uuid else {return}
                SyncController.shared.saveFailedUpload(withFailedPurchaseUUID: uuid)
            }
        }
    }
    
    /// Deletes the User, deletes it from Cotext and CloudKit. If the CK delete Fails the User gets added to the cache for uploading at a later date.
    /// - parameter user: The user to delete.
    func delete(user: User) {
        
        guard let recordToDelete = CKRecord(user: user) else {return}
        
        CloudKitController.shared.delete(record: recordToDelete) { (isSuccess) in
            if !isSuccess {
                guard let uuid = user.uuid else {return}
                SyncController.shared.saveFailedUpload(withFailedPurchaseUUID: uuid)
            }
        }
        CoreDataController.shared.remove(object: user)
    }
}

