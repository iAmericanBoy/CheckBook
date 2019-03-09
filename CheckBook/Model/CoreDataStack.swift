//
//  CoreDataStack.swift
//  Task
//
//  Created by Dominic Lanzillotta on 1/30/19.
//  Copyright © 2019 Dominic Lanzillotta. All rights reserved.
//

import Foundation
import CoreData

enum CoreDataStack {
    
    static let container: NSPersistentContainer = {
        
        let appName = Bundle.main.object(forInfoDictionaryKey: (kCFBundleNameKey as String)) as! String
        let container = NSPersistentContainer(name: appName)
        
        container.persistentStoreDescriptions = [NSPersistentStoreDescription(url:  FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.oskman.CheckBookGroup")!.appendingPathComponent("CheckBook.sqlite"))]
        
        container.loadPersistentStores() { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        
        return container
    }()
    
    static var context: NSManagedObjectContext { return container.viewContext }
    
    static var childContext: NSManagedObjectContext {
        let childContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        childContext.parent = context
        
        return childContext
    }
    
    static var cacheContext: NSManagedObjectContext {
        return container.newBackgroundContext()
    }
}
