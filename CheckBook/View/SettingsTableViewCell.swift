//
//  SettingsTableViewCell.swift
//  CheckBook
//
//  Created by Dominic Lanzillotta on 4/9/19.
//  Copyright © 2019 Dominic Lanzillotta. All rights reserved.
//

import UIKit

protocol SettingsDelegate: NSObject {
    func shareLedger()
}

class SettingsTableViewCell: UITableViewCell {

    //MARK: - Outlets
    @IBOutlet weak var nameLabel: UILabel!
    
    //MARK: - Properties
    var setting: Setting? {
        didSet {
            updateViews()
        }
    }
    var delegate: SettingsDelegate?
    
    //MARK: - Actions
    @IBAction func switchValueChanged(_ sender: UISwitch) {
        guard let setting = setting else {return}
        
        if sender.isOn {
            switch setting {
            case .share:
                delegate?.shareLedger()
            }
        } else {
            
        }
    }
    
    //MARK: - Private Functions
    fileprivate func updateViews() {
        guard let setting = setting else {return}
        switch setting {
        case .share:
            nameLabel.text = "Share Ledger"
        }
    }
}
