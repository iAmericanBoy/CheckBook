//
//  SyncController.swift
//  CheckBook
//
//  Created by Dominic Lanzillotta on 3/6/19.
//  Copyright © 2019 Dominic Lanzillotta. All rights reserved.
//

import Foundation
import CloudKit
import CoreData

class SyncController {
    
    //MARK: - Singleton
    /// The shared Instance of SyncController.
    static let shared = SyncController()

    ///saves failed CK uploads to a local cache
    /// - parameter failedPurchaseUUID: The UUID of the purchase that was not able to be uploaded.
    func saveFailedUpload(failedPurchaseUUID: UUID) {
        CachePurchase(uuid: failedPurchaseUUID)
        do {
            if CoreDataStack.cacheContext.hasChanges {
                try CoreDataStack.cacheContext.save()
            }
        } catch {
            print("Error saving failed purchase to chache with error: \(String(describing: error)) \(error.localizedDescription))")
        }
    }
    
    ///update child MOC with objects from CK
    
    ///retry upload of cached objects
    
}
