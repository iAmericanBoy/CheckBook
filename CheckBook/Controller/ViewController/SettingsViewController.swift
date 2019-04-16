//
//  SettingsViewController.swift
//  CheckBook
//
//  Created by Dominic Lanzillotta on 4/9/19.
//  Copyright © 2019 Dominic Lanzillotta. All rights reserved.
//

import UIKit
import CloudKit

class SettingsViewController: UIViewController {
    
    //MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()

    }
    //MARK: - Actions
    @IBAction func backButtonTapped(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
}

//MARK: - UITableViewDataSource, UITableViewDelegate
extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Setting.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "settingsCell", for: indexPath) as? SettingsTableViewCell
        cell?.setting = Setting.allCases[indexPath.row]
        cell?.delegate = self
        return cell ?? UITableViewCell()
    }
}

//MARK: - SettingsDelegate
extension SettingsViewController: SettingsDelegate {
    func shareLedger() {
        CoreDataController.shared.findPersonalLedger()
        
        if let share = CloudKitController.shared.currentShare {
            let sharingViewController = UICloudSharingController(share: share, container: CKContainer.default())
            sharingViewController.delegate = self
            
            self.present(sharingViewController, animated: true)
            
        } else {
            guard let ledger = CoreDataController.shared.personalLedger, let record = CKRecord(ledger: ledger) else {return}
            
            let share = CKShare(rootRecord: record)
            share.publicPermission = .readWrite
            
            let sharingViewController = UICloudSharingController(preparationHandler: {(UICloudSharingController, handler: @escaping (CKShare?, CKContainer?, Error?) -> Void) in
                let operation = CKModifyRecordsOperation(recordsToSave: [record,share], recordIDsToDelete: nil)
                operation.savePolicy = .changedKeys
                
                operation.modifyRecordsCompletionBlock = { (savedRecord, _,error) in
                    handler(share, CKContainer.default(), error)
                }
                
                operation.perRecordCompletionBlock = { (savedRecord,error) in
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

//MARK: - UICloudSharingControllerDelegate
extension SettingsViewController: UICloudSharingControllerDelegate {
    func cloudSharingControllerDidSaveShare(_ csc: UICloudSharingController) {
        print("Succesfully added Url to Challenge")
        print(csc.share?.url)
    }
    
    func cloudSharingController(_ csc: UICloudSharingController, failedToSaveShareWithError error: Error) {
        print("failed to save ckshare: \(error),\(error.localizedDescription)")
    }
    
    func itemThumbnailData(for csc: UICloudSharingController) -> Data? {
        return nil //You can set a hero image in your share sheet. Nil uses the default.
    }
    
    func itemTitle(for csc: UICloudSharingController) -> String? {
        return CoreDataController.shared.personalLedger?.name
    }
}

