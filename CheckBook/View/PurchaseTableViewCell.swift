//
//  PurchaseCellTableViewCell.swift
//  CheckBook
//
//  Created by Dominic Lanzillotta on 4/5/19.
//  Copyright © 2019 Dominic Lanzillotta. All rights reserved.
//

import UIKit

class PurchaseTableViewCell: UITableViewCell {
    // MARK: - Outlets

    @IBOutlet var amountLabel: UILabel!
    @IBOutlet var storeNameLabel: UILabel!
    @IBOutlet var categoryLabel: UILabel!
    @IBOutlet var methodLabel: UILabel!

    // MARK: - Properties

    var purchase: Purchase? {
        didSet {
            updateViews()
        }
    }

    let numberFormatter = NumberFormatter()

    // MARK: - Private Functions

    fileprivate func updateViews() {
        guard let purchase = purchase else { return }
        numberFormatter.locale = Locale.autoupdatingCurrent
        numberFormatter.numberStyle = .currency
        amountLabel.text = numberFormatter.string(from: purchase.amount!)
        storeNameLabel.text = purchase.storeName
        categoryLabel.text = purchase.category?.name
        methodLabel.text = purchase.purchaseMethod?.name
    }
}
