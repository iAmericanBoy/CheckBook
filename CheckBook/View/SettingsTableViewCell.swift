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
    func deleteUserData()
}

class SettingsTableViewCell: UITableViewCell {

    //MARK: - Outlets
    @IBOutlet weak var cellLabel: UILabel!
    @IBOutlet weak var cellSwitch: UISwitch!
    @IBOutlet weak var cellButton: UIButton!
    
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
            case .deletePersonalData:
                ()
            }
        } else {
            
        }
    }
    @IBAction func cellButtonTapped(_ sender: UIButton) {
        guard let setting = setting else {return}

        switch setting {
        case .share:
            ()
        case .deletePersonalData:
            delegate?.deleteUserData()
        }
    }
    
    //MARK: - Private Functions
    fileprivate func updateViews() {
        cellButton.layer.borderWidth = 1
        cellButton.layer.borderColor = UIColor(red: (4/255),green: (122/255),blue: (255/255),alpha: 1).cgColor
        cellButton.layer.cornerRadius = 3

        guard let setting = setting else {return}
        switch setting {
        case .share:
            cellLabel.text = "Share Ledger"
            cellButton.isHidden = true
            cellSwitch.isHidden = false
        case .deletePersonalData:
            cellLabel.text = "Delete all User Data"
            cellButton.isHidden = false
            cellButton.setTitle(" Delete ", for: .normal)
            cellSwitch.isHidden = true
        }
    }
}
