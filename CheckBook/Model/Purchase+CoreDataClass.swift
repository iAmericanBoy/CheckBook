//
//  Purchase+CoreDataClass.swift
//  CheckBook
//
//  Created by Dominic Lanzillotta on 4/10/19.
//  Copyright © 2019 Dominic Lanzillotta. All rights reserved.
//
//

import CoreData
import Foundation

@objc(Purchase)
public class Purchase: NSManagedObject {
    @objc public var day: NSDate? {
        let dateComponents = Calendar.current.dateComponents([.day, .month, .year], from: self.date! as Date)
        return Calendar.current.date(from: dateComponents) as NSDate?
    }
}
