//
//  PurchaseController.swift
//  CheckBook
//
//  Created by Dominic Lanzillotta on 3/5/19.
//  Copyright © 2019 Dominic Lanzillotta. All rights reserved.
//

import Foundation

class PurchaseController {
    
    //MARK: - Singleton
    /// The shared Instance of PurchaseController.
    static let shared = PurchaseController()
    
    //MARK: - CRUD
    /// Creates new Purchase using the convenience initilizer inside the CoredataStack.context and
    /// - parameter amount: The amount of the purchase.
    /// - parameter date: The date of the purchase.
    /// - parameter item: The itemName of the purchase.
    /// - parameter storeName: The storeName of the purchase.
    /// - parameter method: The method of payment of the purchase.
    func createNewPurchaseWith(amount: Double, date: Date, item: String, storeName:String, method: String) {
        Purchase(amount: amount, date: date, item: item , storeName: storeName, method: method)
        CoreDataController.shared.saveToPersistentStore()
    }
    
    /// Updates the Purchase and resets the last modified parameter.
    /// - parameter purchase: The purchase to update.
    /// - parameter amount: The updated amount of the purchase.
    /// - parameter date: The updated date of the purchase.
    /// - parameter item: The updated itemName of the purchase.
    /// - parameter storeName: updated The storeName of the purchase.
    /// - parameter method: The updated method of payment of the purchase.
    func update(purchase: Purchase, amount:Double?, date: Date?, item: String?, storeName: String?, method: String?) {
        if let amount = amount {purchase.amount = amount}
        if let date = date {purchase.date = date}
        if let item = item {purchase.item = item}
        if let storeName = storeName {purchase.storeName = storeName}
        if let method = method {purchase.method = method}
        purchase.lastModified = Date()
        CoreDataController.shared.saveToPersistentStore()
    }
    
    /// Deletes the Purchase.
    /// - parameter purchase: The purchase to delete.
    func delete(purchase: Purchase) {
        CoreDataController.shared.remove(purchase: purchase)
        //TODO: Delete from CloudKit
    }
}
