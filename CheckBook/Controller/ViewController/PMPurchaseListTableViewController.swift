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
        didSet{
            loadViewIfNeeded()
            updateViews()
        }
    }
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        CoreDataController.shared.purchaseFetchResultsController.delegate = self
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
        
        cell.textLabel?.text =
        cell.detailTextLabel?.text =
        
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
        if segue.identifier == "toDetailVC" {
            guard let index = tableView.indexPathForSelectedRow else {return}
            if let destinationVC = segue.destination as? PurchaseDetailViewController {
                destinationVC.purchase = purchaseMethod?.purchases?.object(at: index.row) as? Purchase
            }
        }
    }
    
    //MARK: - Private Functions
    func updateViews() {
        guard let purchaseMethod = purchaseMethod else {return}
        
        self.title = purchaseMethod.name
    }
}

//MARK: - NSFetchResultsControllerDelegate
extension PMPurchaseListTableViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            guard let newIndexPath = newIndexPath else {return}
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        case .delete:
            guard let indexPath = indexPath else {return}
            tableView.deleteRows(at: [indexPath], with: .automatic)
        case .move:
            guard let newIndexPath = newIndexPath, let indexPath = indexPath else {return}
            tableView.moveRow(at: indexPath, to: newIndexPath)
        case .update:
            guard let indexPath = indexPath else {return}
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        let indexSet = IndexSet(integer: sectionIndex)
        switch type{
        case .insert:
            tableView.insertSections(indexSet, with: .automatic)
        case .delete:
            tableView.deleteSections(indexSet, with: .automatic)
        default:
            break
        }
    }
}
