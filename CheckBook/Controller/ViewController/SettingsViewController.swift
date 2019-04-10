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
        
    }
}
