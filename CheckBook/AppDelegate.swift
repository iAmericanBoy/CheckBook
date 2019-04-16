//
//  AppDelegate.swift
//  CheckBook
//
//  Created by Dominic Lanzillotta on 3/5/19.
//  Copyright © 2019 Dominic Lanzillotta. All rights reserved.
//

import UIKit
import CloudKit
import UserNotifications


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    var window: UIWindow?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        registerForPushNotifications()
        UNUserNotificationCenter.current().delegate = self
        
        return true
    }
    
    
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        //Check for updates from Ck
        //-> If there are updates update Context
        CloudKitController.shared.fetchUpdatedRecordsFromCK { (isSuccess, recordsToUpdate, recordIDsToDelete) in
            if isSuccess {
                SyncController.shared.updateContextWith(fetchedRecordsToUpdate: recordsToUpdate, deletedRecordIDs: recordIDsToDelete)
                completionHandler(.newData)
                
            } else {
                completionHandler(.failed)
            }
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("yay")
        CloudKitController.shared.subscribeToNewChanges(forRecodZone: nil)
    }
    
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("adsf")
    }
    
    func registerForPushNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert]) {
            granted, error in
            print("Permission granted: \(granted)")
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        //show alert to the user
        completionHandler([.alert])
    }
    
    func application(_ application: UIApplication, userDidAcceptCloudKitShareWith cloudKitShareMetadata: CKShare.Metadata) {
        if CoreDataController.shared.ledgersFetchResultsController.fetchedObjects?.count == 0 {
            
            let acceptSharing: CKAcceptSharesOperation = CKAcceptSharesOperation(shareMetadatas: [cloudKitShareMetadata])
            
            acceptSharing.qualityOfService = .userInteractive
            acceptSharing.perShareCompletionBlock = { meta, share, error in
                if let error = error {
                    print("An error accepting a CKShare has occured: \(error), \(error.localizedDescription)")
                }
                
                CloudKitController.shared.currentShare = share
                
                //download everything
                CloudKitController.shared.fetchUpdatedRecordsFromCK(inDataBase: CloudKitController.shared.shareDB) { (isSuccess, recordsToUpdate, recordIDsToDelete) in
                    if isSuccess {
                        SyncController.shared.updateContextWith(fetchedRecordsToUpdate: recordsToUpdate, deletedRecordIDs: recordIDsToDelete)
                    }
                }
                
                
                //subscribe to changes
                CloudKitController.shared.subscribeToNewChanges(forRecodZone: cloudKitShareMetadata.rootRecordID.zoneID, inDataBase: CloudKitController.shared.shareDB)
                
            }
            
            acceptSharing.acceptSharesCompletionBlock = { error in
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                }
            }
            CKContainer(identifier: cloudKitShareMetadata.containerIdentifier).add(acceptSharing)
        } else {
            NotificationCenter.default.post(Notification.ledgerAlreadyExists)
        }
    }
}
