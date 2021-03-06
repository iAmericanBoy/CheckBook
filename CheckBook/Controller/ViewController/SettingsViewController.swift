//
//  SettingsViewController.swift
//  CheckBook
//
//  Created by Dominic Lanzillotta on 4/9/19.
//  Copyright © 2019 Dominic Lanzillotta. All rights reserved.
//

import CloudKit
import UIKit

class SettingsViewController: UIViewController {
    // MARK: - Outlets
    
    @IBOutlet var tableView: UITableView!
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.tableFooterView = UIView()
    }
    
    // MARK: - Actions
    
    @IBAction func backButtonTapped(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Setting.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "settingsCell", for: indexPath) as? SettingsTableViewCell
        switch Setting.allCases[indexPath.row] {
        case .share(let defaultValue):
            let savedBool = UserDefaults(suiteName: "group.com.oskman.DaysInARowGroup")?.bool(forKey: "isSharing")
            cell?.setting = .share(savedBool ?? defaultValue)
        case .deletePersonalData:
            cell?.setting = .deletePersonalData
        }
        cell?.delegate = self
        return cell ?? UITableViewCell()
    }
}

// MARK: - SettingsDelegate

extension SettingsViewController: SettingsDelegate {
    func deleteUserData() {
        self.deleteUserData {
            CoreDataController.shared.clearCoreDataStore()
            CoreDataController.shared.clearCoreDataStore()
            UserDefaults.standard.removePersistentDomain(forName: "group.com.oskman.DaysInARowGroup")
            CloudKitController.shared.deleteRecordZones()
        }
    }
    
    func shareLedger() {
        if let share = CloudKitController.shared.currentShare {
            let sharingViewController = UICloudSharingController(share: share, container: CKContainer.default())
            sharingViewController.delegate = self
            
            self.present(sharingViewController, animated: true)
            
        } else {
            guard let ledger = CoreDataController.shared.ledgersFetchResultsController.fetchedObjects?.first, let record = CKRecord(ledger: ledger) else { return }
            
            let share = CKShare(rootRecord: record)
            share.publicPermission = .readWrite
            
            let sharingViewController = UICloudSharingController(preparationHandler: { (_, handler: @escaping (CKShare?, CKContainer?, Error?) -> Void) in
                let operation = CKModifyRecordsOperation(recordsToSave: [record, share], recordIDsToDelete: nil)
                operation.savePolicy = .changedKeys
                
                operation.modifyRecordsCompletionBlock = { _, _, error in
                    handler(share, CKContainer.default(), error)
                }
                
                operation.perRecordCompletionBlock = { _, error in
                    if let error = error {
                        print(error)
                    }
                }
                CloudKitController.shared.privateDB.add(operation)
            })
            
            sharingViewController.delegate = self
            
            self.present(sharingViewController, animated: true)
        }
    }
}

// MARK: - UICloudSharingControllerDelegate

extension SettingsViewController: UICloudSharingControllerDelegate {
    func cloudSharingControllerDidSaveShare(_ csc: UICloudSharingController) {
        guard let ledger = CoreDataController.shared.ledgersFetchResultsController.fetchedObjects?.first, let url = csc.share?.url else { return }
        
        LedgerController.shared.add(stringURL: url.absoluteString, toLedger: ledger) { isSuccess in
            if isSuccess {
                print("Succesfully added Url to Ledger")
                print(url)
            }
        }
        UserDefaults(suiteName: "group.com.oskman.DaysInARowGroup")?.set(true, forKey: "isSharing")
    }
    
    func cloudSharingController(_ csc: UICloudSharingController, failedToSaveShareWithError error: Error) {
        print("failed to save ckshare: \(error),\(error.localizedDescription)")
    }
    
    func itemThumbnailData(for csc: UICloudSharingController) -> Data? {
        return nil // You can set a hero image in your share sheet. Nil uses the default.
    }
    
    func itemTitle(for csc: UICloudSharingController) -> String? {
        return CoreDataController.shared.ledgersFetchResultsController.fetchedObjects?.first?.name
    }
}
