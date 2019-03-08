//
//  CoreDataController.swift
//  CheckBook
//
//  Created by Dominic Lanzillotta on 3/6/19.
//  Copyright © 2019 Dominic Lanzillotta. All rights reserved.
//

import Foundation
import CoreData

class CoreDataController {

    //MARK: - Singleton
    /// The shared Instance of CoreDataController.
    static let shared = CoreDataController()
    
    //MARK: - FetchResultsController
    ///Simple FetchController to fetch all the Purchases.
    let purchaseFetchResultsController: NSFetchedResultsController<Purchase> = {
        let fetchRequest: NSFetchRequest<Purchase> = Purchase.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "item", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        return NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataStack.context, sectionNameKeyPath: nil, cacheName: nil)
    }()
    
    //MARK: - init
    ///Simple initializer to set up the fetchResultsController.
    init() {
        do{
            try purchaseFetchResultsController.performFetch()
        } catch {
            print("Error loading fetchResultsController. \(String(describing: error)), \(error.localizedDescription)")
        }
    }
    
    //MARK: Read
    /// Looks in the Context for a Purchase with a given UUID.
    /// - parameter uuid: The UUID of the Puchease that is being searched for.
    /// - parameter context: The context where we should check for the Object with the given UUID.
    /// - parameter completion: Handler for when the purchase has been found.
    /// - parameter foundPurchase: The purchase that was found or nil.
    func findPurchaseWith(uuid: UUID?, inContext context: NSManagedObjectContext = CoreDataStack.context, completion: @escaping (_ foundPurchase:Purchase?) -> Void ) {
        guard let uuid = uuid else {
            completion(nil)
            return
        }
        let request: NSFetchRequest<Purchase> = Purchase.fetchRequest()
        request.fetchLimit = 1
        request.predicate = NSPredicate(format: "%K == %@", #keyPath(Purchase.uuid), uuid as CVarArg)
        do {
            let purchases = try CoreDataStack.context.fetch(request)
            completion(purchases.first)
        } catch {
            print("No Purchase with UUID fouund: \(error), \(error.localizedDescription)")
            completion(nil)
        }
    }
    
    //MARK: - Delete
    /// Removes the Purchase from the Context.
    /// - parameter purchase: The purchase to remove.
    func remove(purchase: Purchase) {
        if let moc = purchase.managedObjectContext {
            moc.delete(purchase)
            saveToPersistentStore()
        }
    }
    
    //MARK: - Save
    func saveToPersistentStore() {
        do {
            if CoreDataStack.context.hasChanges {
                try CoreDataStack.context.save()
            }
        } catch {
            print("Error saving: \(String(describing: error)) \(error.localizedDescription))")
        }
    }
}
