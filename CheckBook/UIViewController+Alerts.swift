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
                guard let ledgerUUID = CoreDataController.shared.ledgersFetchResultsController.fetchedObjects?.first?.uuid else {return}
                _ = PurchaseMethodController.shared.createNewPurchaseMethodWith(name: name, withLedgerUUID: ledgerUUID)
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
                guard let ledgerUUID = CoreDataController.shared.ledgersFetchResultsController.fetchedObjects?.first?.uuid else {return}

                _ = CategoryController.shared.createNewCategoryWith(name: name, ledgerUUID: ledgerUUID)
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
    
    func tooManyLedgers(_ completion: @escaping () -> Void) {
        
        let alertController = UIAlertController(title: "Subscribe to new Ledger", message: "You can only be part of 1 ledger at a time", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) in
            completion()
        }

        alertController.addAction(cancelAction)
        alertController.addAction(settingsAction)
        self.present(alertController, animated: true)
    }
    
    func deleteUserData(_ completion: @escaping () -> Void) {
        
        let alertController = UIAlertController(title: "Warning", message: "Do you really want to delete all of your data? This can't be undone and will also delete the shared Ledger if your are sharing with your Partner", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let settingsAction = UIAlertAction(title: "Confirm Delete", style: .destructive) { (_) in
            completion()
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(settingsAction)
        self.present(alertController, animated: true)
    }
    
    
}
