//
//  PurchaseHeader.swift
//  CheckBook
//
//  Created by Dominic Lanzillotta on 4/17/19.
//  Copyright © 2019 Dominic Lanzillotta. All rights reserved.
//

import UIKit

class PurchaseListSectionView: UITableViewHeaderFooterView {
    // MARK: - Outlets
    
    let amountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .purple
        return label
    }()
    
    let boarderView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Properties
    
    static let reuseIdentifier = "PurchaseHeader"
    
    var purchases: [Purchase]? {
        didSet {
            updateViews()
        }
    }
    
    // MARK: - LifeCycle
    
    public override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private Functions
    
    func setupViews() {
        contentView.backgroundColor = UIColor.purple.withAlphaComponent(0.06)
        backgroundView?.backgroundColor = .clear
        
        contentView.addSubview(boarderView)
        boarderView.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor).isActive = true
        boarderView.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor).isActive = true
        boarderView.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor).isActive = true
        boarderView.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        
        contentView.addSubview(amountLabel)
        amountLabel.topAnchor.constraint(equalTo: boarderView.bottomAnchor).isActive = true
        amountLabel.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor, constant: 12).isActive = true
        amountLabel.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor, constant: -8).isActive = true
        
        contentView.addSubview(dateLabel)
        dateLabel.topAnchor.constraint(equalTo: boarderView.bottomAnchor).isActive = true
        dateLabel.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor, constant: 12).isActive = true
        dateLabel.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: 8).isActive = true
    }
    
    func updateViews() {
        guard let purchases = purchases else { return }
        let numberFormatter = NumberFormatter()
        numberFormatter.locale = Locale.autoupdatingCurrent
        numberFormatter.numberStyle = .currency
        
        var total: NSDecimalNumber = 0.0
        for purchase in purchases {
            total = total.adding(purchase.amount ?? 0)
        }
        amountLabel.text = numberFormatter.string(from: total)
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.autoupdatingCurrent
        dateFormatter.dateStyle = .medium
        let sectionDate = purchases.first?.day ?? Date() as NSDate
        
        dateLabel.text = dateFormatter.string(from: sectionDate as Date)
    }
}
