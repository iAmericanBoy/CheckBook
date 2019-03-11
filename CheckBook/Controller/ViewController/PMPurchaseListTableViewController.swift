//
//  PMPurchaseListTableViewController.swift
//  CheckBook
//
//  Created by Dominic Lanzillotta on 3/10/19.
//  Copyright © 2019 Dominic Lanzillotta. All rights reserved.
//

import UIKit
import CoreData

class PMPurchaseListTableViewController: UITableViewController {
    
    //MARK: - Properties
    var purchaseMethod: PurchaseMethod? {
        didSet {
            
            loadViewIfNeeded()
            updateViews()
        }
    }
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateViews()
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return purchaseMethod?.purchases?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "purchaseCell", for: indexPath)
        
        guard let purchase = purchaseMethod?.purchases?[indexPath.row] as? Purchase else {return cell}
        
        cell.textLabel?.text = purchase.item
        cell.detailTextLabel?.text = purchase.lastModified?.description
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard let purchaseToDelete = purchaseMethod?.purchases?.object(at: indexPath.row) as? Purchase else {return}
            PurchaseController.shared.delete(purchase: purchaseToDelete)
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //IIDOO
        if segue.identifier == "toDetailPurchaseVC" {
            guard let index = tableView.indexPathForSelectedRow else {return}
            if let destinationVC = segue.destination as? PMPurchaseDetailViewController {
                destinationVC.purchase = purchaseMethod?.purchases?.object(at: index.row) as? Purchase
                destinationVC.purchaseMethod = purchaseMethod
            }
        }
        if segue.identifier == "toDetailVC" {
            if let destinationVC = segue.destination as? PMDetailViewController {

                destinationVC.purchaseMethod = purchaseMethod
            }
        }
        if segue.identifier == "toNewVC" {
            if let destinationVC = segue.destination as? PMPurchaseDetailViewController {
                destinationVC.purchaseMethod = purchaseMethod
            }
        }
    }
    
    //MARK: - Private Functions
    func updateViews() {
        guard let purchaseMethod = purchaseMethod else {return}
        
        self.title = purchaseMethod.name
        tableView.reloadData()
    }
}
