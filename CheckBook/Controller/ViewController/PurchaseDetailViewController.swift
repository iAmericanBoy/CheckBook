//
//  PurchaseDetailViewController.swift
//  CheckBook
//
//  Created by Dominic Lanzillotta on 3/7/19.
//  Copyright © 2019 Dominic Lanzillotta. All rights reserved.
//

import UIKit

class PurchaseDetailViewController: UIViewController {
    
    //MARK: - Outlets
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var storeNameTextField: UITextField!
    @IBOutlet weak var methodTextField: UITextField!
    @IBOutlet weak var itemTextField: UITextField!
    @IBOutlet weak var dateTextField: UITextField!
    
    //MARK: - Properties
    var purchase: Purchase? {
        didSet{
            loadViewIfNeeded()
            updateViews()
        }
    }
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //MARK: - Actions
    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
        guard let amount = amountTextField.text, !amount.isEmpty,
            let storeName = storeNameTextField.text, !storeName.isEmpty,
            let method = methodTextField.text, !method.isEmpty,
            let item = itemTextField.text, !item.isEmpty,
            let date = dateTextField.text, !date.isEmpty else {return }
        
        if let purchase = purchase {
            //update
            PurchaseController.shared.update(purchase: purchase, amount: Double(amount), date: Date(), item: item, storeName: storeName, method: method)
            self.navigationController?.popViewController(animated: true)
        } else {
            //saveNew
            PurchaseController.shared.createNewPurchaseWith(amount: Double(amount)!, date: Date(), item: item, storeName: storeName, method: method)
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    //MARK: - Private Functions
    func updateViews(){
        guard let purchase = purchase else {dateTextField.text = Date().description;return }
        amountTextField.text = "\(purchase.amount)"
        storeNameTextField.text = purchase.storeName
        methodTextField.text = purchase.method
        itemTextField.text = purchase.item
        dateTextField.text = "\(String(describing: purchase.date))"
    }
}
