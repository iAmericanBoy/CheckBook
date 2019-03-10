//
//  PMDetailViewController.swift
//  CheckBook
//
//  Created by Dominic Lanzillotta on 3/10/19.
//  Copyright © 2019 Dominic Lanzillotta. All rights reserved.
//

import UIKit

class PMDetailViewController: UIViewController {
    
    //MARK: - Outlets
    @IBOutlet weak var nameTextField: UITextField!
    
    //MARK: - Properties
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
    @IBAction func saveButtontapped(_ sender: UIBarButtonItem) {
        guard let name = nameTextField.text, !name.isEmpty else {return }
        
        if let purchaseMethod = purchaseMethod {
            //update
            
            self.navigationController?.popViewController(animated: true)
        } else {
            //saveNew
            
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    //MARK: - Private Functions
    func updateViews() {
        guard let purchaseMethod = purchaseMethod else {return}
        
        self.title = "Purchase"
        nameTextField.text = purchaseMethod.name
    }
}
