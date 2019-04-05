//
//  PurchaseCellTableViewCell.swift
//  CheckBook
//
//  Created by Dominic Lanzillotta on 4/5/19.
//  Copyright © 2019 Dominic Lanzillotta. All rights reserved.
//

import UIKit

class PurchaseTableViewCell: UITableViewCell {
    
    //MARK: - Outlets
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var storeNameLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    
    //MARK: - Properties
    var purchase: Purchase? {
        didSet {
            updateViews()
        }
    }
    let numberFormatter = NumberFormatter()

    
    //MARK: - Private Functions
    fileprivate func updateViews() {
        guard let purchase = purchase else {return}
        numberFormatter.locale = Locale.autoupdatingCurrent
        numberFormatter.numberStyle = .currency
        amountLabel.text = numberFormatter.string(from: NSNumber(value: purchase.amount))
        storeNameLabel.text = purchase.storeName
    }
}
