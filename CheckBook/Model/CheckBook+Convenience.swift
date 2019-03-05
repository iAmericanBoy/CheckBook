//
//  CheckBook+Convenience.swift
//  CheckBook
//
//  Created by Dominic Lanzillotta on 3/5/19.
//  Copyright © 2019 Dominic Lanzillotta. All rights reserved.
//

import Foundation
import CoreData

extension Purchase {
    @discardableResult
    convenience init(amount: Double, date: Date, item: String, storeName: String, method: String?, person: String?, uuid: UUID = UUID(), lastModified: Date = Date(), context: NSManagedObjectContext = CoreDataStack.context) {
        self.init(context: context)
        
        self.amount = amount
        self.date = date
        self.item = item
        self.method = method
        self.person = person
        self.storeName = storeName
        
        self.lastModified = lastModified
        self.uuid = uuid
    }
}
