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
    ///FetchController to fetch all the Purchases.
    let purchaseFetchResultsController: NSFetchedResultsController<Purchase> = {
        let fetchRequest: NSFetchRequest<Purchase> = Purchase.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        return NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataStack.context, sectionNameKeyPath: "day", cacheName: nil)
    }()
    
    ///FetchController to fetch all the PurchaseMethods.
    let purchaseMethodFetchResultsController: NSFetchedResultsController<PurchaseMethod> = {
        let fetchRequest: NSFetchRequest<PurchaseMethod> = PurchaseMethod.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        return NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataStack.context, sectionNameKeyPath: nil, cacheName: nil)
    }()
    
    ///FetchController to fetch all the Categories.
    let categoryFetchResultsController: NSFetchedResultsController<Category> = {
        let fetchRequest: NSFetchRequest<Category> = Category.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        return NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataStack.context, sectionNameKeyPath: nil, cacheName: nil)
    }()
    
    ///FetchController to fetch all the PurchaseMethods.
    let purchasesOfPurchaseMethodFetchResultsController: NSFetchedResultsController<Purchase> = {
        let fetchRequest: NSFetchRequest<Purchase> = Purchase.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        return NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataStack.context, sectionNameKeyPath: nil, cacheName: nil)
    }()
    
    ///FetchController to fetch all the Ledgers.
    let ledgersFetchResultsController: NSFetchedResultsController<Ledger> = {
        let fetchRequest: NSFetchRequest<Ledger> = Ledger.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        return NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataStack.context, sectionNameKeyPath: nil, cacheName: nil)
    }()
    
    var personalLedger: Ledger?
    
    //MARK: - init
    ///Simple initializer to set up the fetchResultsController.
    init() {
        do{
            try purchaseFetchResultsController.performFetch()
            try purchaseMethodFetchResultsController.performFetch()
            try ledgersFetchResultsController.performFetch()
            try categoryFetchResultsController.performFetch()

        } catch {
            print("Error loading fetchResultsControllers. \(String(describing: error)), \(error.localizedDescription)")
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
    
    /// Looks in the Context for a PurchaseMethod with a given UUID.
    /// - parameter uuid: The UUID of the PurchaseMethod that is being searched for.
    /// - parameter context: The context where we should check for the Object with the given UUID.
    /// - parameter completion: Handler for when the purchaseMethod has been found.
    /// - parameter foundPurchaseMethod: The purchaseMethod that was found or nil.
    func findPurchaseMethodWith(uuid: UUID?, inContext context: NSManagedObjectContext = CoreDataStack.context, completion: @escaping (_ foundPurchaseMethod:PurchaseMethod?) -> Void ) {
        guard let uuid = uuid else {
            completion(nil)
            return
        }
        let request: NSFetchRequest<PurchaseMethod> = PurchaseMethod.fetchRequest()
        request.fetchLimit = 1
        request.predicate = NSPredicate(format: "%K == %@", #keyPath(PurchaseMethod.uuid), uuid as CVarArg)
        do {
            let purchaseMethods = try CoreDataStack.context.fetch(request)
            completion(purchaseMethods.first)
        } catch {
            print("No PurchaseMethod with UUID found: \(error), \(error.localizedDescription)")
            completion(nil)
        }
    }
    
    /// Looks in the Context for a Ledger with a given UUID.
    /// - parameter uuid: The UUID of the ledger that is being searched for.
    /// - parameter context: The context where we should check for the Object with the given UUID.
    /// - parameter completion: Handler for when the ledger has been found.
    /// - parameter foundLedger: The ledger that was found or nil.
    func findLedgerWith(uuid: UUID?, inContext context: NSManagedObjectContext = CoreDataStack.context, completion: @escaping (_ foundLedger:Ledger?) -> Void ) {
        guard let uuid = uuid else {
            completion(nil)
            return
        }
        let request: NSFetchRequest<Ledger> = Ledger.fetchRequest()
        request.fetchLimit = 1
        request.predicate = NSPredicate(format: "%K == %@", #keyPath(Ledger.uuid), uuid as CVarArg)
        do {
            let ledgers = try CoreDataStack.context.fetch(request)
            completion(ledgers.first)
        } catch {
            print("No Ledger with UUID found: \(error), \(error.localizedDescription)")
            completion(nil)
        }
    }
    func findPersonalLedger(){
        guard let recordName = CloudKitController.shared.appleUserID?.recordName else {return }
        let request: NSFetchRequest<Ledger> = Ledger.fetchRequest()
        request.fetchLimit = 1
        request.predicate = NSPredicate(format: "%K == %@", #keyPath(Ledger.appleUserRecordName), "__defaultOwner__")
        
        do {
            let ledger = try CoreDataStack.context.fetch(request)
            personalLedger = ledger.first
        } catch {
            print("Error fetching personal Ledger has occured: \(error.localizedDescription)")
        }
    }
    
    /// Looks in the Context for a Cacheobject with a given UUID.
    /// - parameter uuid: The UUID of the ledger that is being searched for.
    /// - parameter context: The context where we should check for the Object with the given UUID.
    /// - parameter completion: Handler for when the ledger has been found.
    /// - parameter foundLedger: The ledger that was found or nil.
    func findCacheWith(uuid: UUID?, inContext context: NSManagedObjectContext = CoreDataStack.context, completion: @escaping (_ foundLedger:CachePurchase?) -> Void ) {
        guard let uuid = uuid else {
            completion(nil)
            return
        }
        let request: NSFetchRequest<CachePurchase> = CachePurchase.fetchRequest()
        request.fetchLimit = 1
        request.predicate = NSPredicate(format: "%K == %@", #keyPath(CachePurchase.uuid), uuid as CVarArg)
        do {
            let caches = try CoreDataStack.context.fetch(request)
            completion(caches.first)
        } catch {
            print("No Cache with UUID found: \(error), \(error.localizedDescription)")
            completion(nil)
        }
    }
    
    /// Looks in the Context for a Category with a given UUID.
    /// - parameter uuid: The UUID of the category that is being searched for.
    /// - parameter context: The context where we should check for the Object with the given UUID.
    /// - parameter completion: Handler for when the Category has been found.
    /// - parameter foundCategory: The Category that was found or nil.
    func findCategoryWith(uuid: UUID?, inContext context: NSManagedObjectContext = CoreDataStack.context, completion: @escaping (_ foundCategory: Category?) -> Void ) {
        guard let uuid = uuid else {
            completion(nil)
            return
        }
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        request.fetchLimit = 1
        request.predicate = NSPredicate(format: "%K == %@", #keyPath(Category.uuid), uuid as CVarArg)
        do {
            let categories = try CoreDataStack.context.fetch(request)
            completion(categories.first)
        } catch {
            print("No Categorie with UUID found: \(error), \(error.localizedDescription)")
            completion(nil)
        }
    }
    
    //MARK: - Delete
    /// Removes the Object from the Context.
    /// - parameter object: The object to remove.
    func remove(object: NSManagedObject) {
        if let moc = object.managedObjectContext {
            moc.delete(object)
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
