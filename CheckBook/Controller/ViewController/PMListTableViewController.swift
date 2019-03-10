//
//  PurchaseMethodTableViewController.swift
//  CheckBook
//
//  Created by Dominic Lanzillotta on 3/10/19.
//  Copyright © 2019 Dominic Lanzillotta. All rights reserved.
//

import UIKit
import CoreData

class PMListTableViewController: UITableViewController {
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        CoreDataController.shared.purchaseMethodFetchResultsController.delegate = self
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CoreDataController.shared.purchaseMethodFetchResultsController.sections?[section].numberOfObjects ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "purchaseMethodCell", for: indexPath)

        cell.textLabel?.text = CoreDataController.shared.purchaseMethodFetchResultsController.object(at: indexPath).name
        cell.detailTextLabel?.text = CoreDataController.shared.purchaseMethodFetchResultsController.object(at: indexPath).lastModified?.description
        
        return cell
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let purchaseMethodToDelete = CoreDataController.shared.purchaseMethodFetchResultsController.object(at: indexPath)
            PurchaseMethodController.shared.delete(purchaseMethod: purchaseMethodToDelete)
        }
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let index = tableView.indexPathForSelectedRow else {return}

        switch segue.identifier {
        case "toPurchaseTVC":
            if let destinationVC = segue.destination as? PMPurchaseListTableViewController {
                destinationVC.purchaseMethod = CoreDataController.shared.purchaseMethodFetchResultsController.object(at: index)
            }
        case "toNewVC":
            if let destinationVC = segue.destination as? PMDetailViewController {
                destinationVC.purchaseMethod = CoreDataController.shared.purchaseMethodFetchResultsController.object(at: index)
            }
        default:
            break
        }
    }
}

//MARK: - NSFetchResultsControllerDelegate
extension PMListTableViewController: NSFetchedResultsControllerDelegate {
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

