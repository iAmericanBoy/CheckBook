//
//  PMPurchaseDetailTableViewController.swift
//  CheckBook
//
//  Created by Dominic Lanzillotta on 3/10/19.
//  Copyright © 2019 Dominic Lanzillotta. All rights reserved.
//

import UIKit

class PMPurchaseDetailViewController: UIViewController {
    
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
    
    var purchaseMethod: PurchaseMethod? {
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
            if purchase.purchaseMethod?.name != method {
                let newMethod = PurchaseMethodController.shared.createNewPurchaseWith(name: method)
                PurchaseMethodController.shared.change(purchaseMethod: purchase.purchaseMethod!, ofPurchase: purchase, toPurchaseMethod: newMethod)
            }
            
            PurchaseController.shared.update(purchase: purchase, amount: Double(amount)!, date: Date(), item: item, storeName: storeName, purchaseMethod: purchase.purchaseMethod)
            
            self.navigationController?.popViewController(animated: true)
        } else {
            //saveNew
            if purchaseMethod?.name != method {
                let newMethod = PurchaseMethodController.shared.createNewPurchaseWith(name: method)
                PurchaseController.shared.createNewPurchaseWith(amount: Double(amount)!, date: Date(), item: item, storeName: storeName, purchaseMethod: newMethod)
            } else {
                PurchaseController.shared.createNewPurchaseWith(amount: Double(amount)!, date: Date(), item: item, storeName: storeName, purchaseMethod: purchaseMethod!)
            }
            
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    //MARK: - Private Functions
    func updateViews(){
        guard let purchaseMethod = purchaseMethod else {return }

        methodTextField?.text = purchaseMethod.name
        dateTextField?.text = Date().description
        
        guard let purchase = purchase else {return }
        amountTextField.text = "\(purchase.amount)"
        storeNameTextField.text = purchase.storeName
        itemTextField.text = purchase.item
        dateTextField.text = "\(String(describing: purchase.date))"
    }
}
