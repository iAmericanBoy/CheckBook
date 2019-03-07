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
    
    //compare both Stores(uuid and lastUpdated) 
    
    ///When CoreData has an update this function notifies CloudKit and deals with the updated Purchase.
    func syncCloudKitWithCoreData() {
        
    }
    ///When CloudKit has an update this function notifies CoreData and deals with the updated Purchase.

    //if CK not available
}
