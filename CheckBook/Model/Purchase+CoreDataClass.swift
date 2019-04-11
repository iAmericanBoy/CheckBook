//
//  Purchase+CoreDataClass.swift
//  CheckBook
//
//  Created by Dominic Lanzillotta on 4/10/19.
//  Copyright © 2019 Dominic Lanzillotta. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Purchase)
public class Purchase: NSManagedObject {
    
    public var day: NSDate? {
        get {
            let dateComponents = Calendar.current.dateComponents([.day,.month,.year], from: self.date! as Date)
            let newdate = dateComponents.date as NSDate?
            print(newdate)
            return newdate
        }
    }
}
