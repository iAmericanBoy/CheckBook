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
    convenience init(uuid: UUID, lastUploadDate: Date = Date(), cacheType: CacheType, context: NSManagedObjectContext = CoreDataStack.context) {
        self.init(context: context)
        self.uuid = uuid
        self.type = cacheType.rawValue
        self.lastUploadDate = lastUploadDate
    }
}

enum CacheType: String {
    case purchase
    case method
    case category
    case ledger
}
