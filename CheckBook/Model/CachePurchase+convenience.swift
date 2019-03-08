//
//  CachePurchase.swift
//  CheckBook
//
//  Created by Dominic Lanzillotta on 3/7/19.
//  Copyright © 2019 Dominic Lanzillotta. All rights reserved.
//

import Foundation
import  CoreData


extension CachePurchase {
    @discardableResult
    convenience init(uuid: UUID, lastUploadDate: Date = Date(), context: NSManagedObjectContext = CoreDataStack.cacheContext) {
        self.init(context: context)
        self.uuid = uuid
        self.lastUploadDate = lastUploadDate
    }
}
