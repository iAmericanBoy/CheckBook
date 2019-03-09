//
//  AppDelegate.swift
//  CheckBook
//
//  Created by Dominic Lanzillotta on 3/5/19.
//  Copyright © 2019 Dominic Lanzillotta. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        //Check for updates from Ck
        //-> If there are updates update Context
        //-> after that try to upload cached Purchases to CK
        CloudKitController.shared.fetchUpdatedRecordsFromCK { (isSuccess, recordsToUpdate, recordIDsToDelete) in
            if isSuccess {
                SyncController.shared.updateContextWith(fetchedRecordsToUpdate: recordsToUpdate, deletedRecordIDs: recordIDsToDelete)
                while CoreDataStack.cacheContext.registeredObjects.count > 0 {
                    SyncController.shared.saveCachedPurchasesToCK()
                }
            }
        }
        return true
    }
}

