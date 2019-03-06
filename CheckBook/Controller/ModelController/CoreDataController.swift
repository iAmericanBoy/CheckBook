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
