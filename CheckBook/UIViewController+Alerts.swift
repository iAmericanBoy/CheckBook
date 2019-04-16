//
//  UIViewController+Alerts.swift
//  CheckBook
//
//  Created by Dominic Lanzillotta on 4/8/19.
//  Copyright © 2019 Dominic Lanzillotta. All rights reserved.
//

import UIKit


extension UIViewController {
    
    func addNewPurchaseMethodAlert(_ completion: @escaping () -> Void) {
        var nameTextField: UITextField?
        
        let alertController = UIAlertController(title: "New", message: "Add a new Purchase Method", preferredStyle: .alert)
        
        let addAction = UIAlertAction(title: "Add", style: .default) { (action) in
            if let name = nameTextField?.text {
                _ = PurchaseMethodController.shared.createNewPurchaseMethodWith(name: name)
                completion()
            }
        }
        addAction.isEnabled = false
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alertController.addTextField { textField in
            textField.placeholder = "Add Name"
            NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: textField, queue: .main) { notif in
                
                if let name = textField.text, !name.isEmpty {
                    addAction.isEnabled = true
                    nameTextField = textField
                } else {
                    addAction.isEnabled = false
                }
            }
            
            alertController.addAction(addAction)
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true)
        }
    }
    
    func addNewCategoryAlert(_ completion: @escaping () -> Void) {
        var nameTextField: UITextField?
        
        let alertController = UIAlertController(title: "New", message: "Add a new Category", preferredStyle: .alert)
        
        let addAction = UIAlertAction(title: "Add", style: .default) { (action) in
            if let name = nameTextField?.text {
                _ = CategoryController.shared.createNewCategoryWith(name: name, ledgerUUID: <#UUID#>)
                completion()
            }
        }
        addAction.isEnabled = false
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alertController.addTextField { textField in
            textField.placeholder = "Add Name"
            NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: textField, queue: .main) { notif in
                
                if let name = textField.text, !name.isEmpty {
                    addAction.isEnabled = true
                    nameTextField = textField
                } else {
                    addAction.isEnabled = false
                }
            }
            
            alertController.addAction(addAction)
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true)
        }
    }
    
    func addNewLedgerAlert(_ completion: @escaping () -> Void) {
        var nameTextField: UITextField?
        
        let alertController = UIAlertController(title: "New", message: "Add a new Ledger", preferredStyle: .alert)
        
        let addAction = UIAlertAction(title: "Add", style: .default) { (action) in
            if let name = nameTextField?.text {
                _ = LedgerController.shared.createNewLedgerWith(name: name)
                completion()
            }
        }
        addAction.isEnabled = false
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alertController.addTextField { textField in
            textField.placeholder = "Add Name"
            NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: textField, queue: .main) { notif in
                
                if let name = textField.text, !name.isEmpty {
                    addAction.isEnabled = true
                    nameTextField = textField
                } else {
                    addAction.isEnabled = false
                }
            }
            
            alertController.addAction(addAction)
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true)
        }
    }
}
