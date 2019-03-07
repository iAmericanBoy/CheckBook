//
//  PurchaseListTableViewController.swift
//  CheckBook
//
//  Created by Dominic Lanzillotta on 3/7/19.
//  Copyright © 2019 Dominic Lanzillotta. All rights reserved.
//

import UIKit

class PurchaseListTableViewController: UITableViewController {
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CoreDataController.shared.purchaseFetchResultsController.sections?[section].numberOfObjects ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "purchaseCell", for: indexPath)
        
        cell.textLabel?.text = CoreDataController.shared.purchaseFetchResultsController.object(at: indexPath).item
        cell.detailTextLabel?.text = CoreDataController.shared.purchaseFetchResultsController.object(at: indexPath).storeName
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let purchase = CoreDataController.shared.purchaseFetchResultsController.object(at: indexPath)
            PurchaseController.shared.delete(purchase: purchase)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
 
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //IIDOO
        if segue.identifier == "toDetailVC" {
            guard let index = tableView.indexPathForSelectedRow else {return}
            if let destinationVC = segue.destination as? PurchaseDetailViewController {
                destinationVC.purchase = CoreDataController.shared.purchaseFetchResultsController.object(at: index)
            }
        }
    }
}
