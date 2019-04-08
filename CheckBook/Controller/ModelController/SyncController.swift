//
//  SyncController.swift
//  CheckBook
//
//  Created by Dominic Lanzillotta on 3/6/19.
//  Copyright © 2019 Dominic Lanzillotta. All rights reserved.
//

import Foundation
import CloudKit
import CoreData

class SyncController {
    
    //MARK: - Singleton
    /// The shared Instance of SyncController.
    static let shared = SyncController()
    
    ///Saves failed CK object to a local cache.
    /// - parameter uuid: The UUID of the purchase that was not able to be uploaded.
    func saveFailedUpload(withFailedPurchaseUUID uuid: UUID) {
        CachePurchase(uuid: uuid)
        CoreDataController.shared.saveToPersistentStore()
    }
    
    ///Updates child MOC with objects from CK
    /// - parameter records: The records that need to be updated or created in the local Store
    /// - parameter recordIDs: The recordIDs of records that need to be deleted from the local Store.
    func updateContextWith(fetchedRecordsToUpdate records: [CKRecord], deletedRecordIDs recordIDs: [CKRecord.ID]) {
        records.forEach { recordFromCK in
            
            guard let uuid = UUID(uuidString: recordFromCK.recordID.recordName) else {return}

            if recordFromCK.recordType == Purchase.typeKey {
                CoreDataController.shared.findPurchaseWith(uuid: uuid,inContext: CoreDataStack.childContext, completion: { purchaseFromCD in
                    
                    guard let amount = recordFromCK[Purchase.amountKey] as? Double,
                        let date = recordFromCK[Purchase.dateKey] as? Date,
                        let item = recordFromCK[Purchase.itemKey] as? String,
                        let methodUUID = recordFromCK[Purchase.methodKey] as? String,
                        let ledgerUUID = recordFromCK[Purchase.ledgerKey] as? String,
                        let categoryUUID = recordFromCK[Purchase.categoryKey] as? String,
                        let userUUID = recordFromCK[Purchase.userKey] as? String,
                        let methodName = recordFromCK[Purchase.methodNameKey] as? String,
                        let appleUserUUID = recordFromCK[Purchase.appleUserKey] as? String,
                        let lastModified = recordFromCK[Purchase.lastModifiedKey] as? Date,
                        let storeName = recordFromCK[Purchase.storeNameKey] as? String else {return}
                    
                    CoreDataController.shared.findPurchaseMethodWith(uuid: UUID(uuidString: methodUUID)!, inContext: CoreDataStack.childContext, completion: { (foundPurchaseMethod) in
                        let purchaseMethod: PurchaseMethod?

                        if let foundPurchaseMethod = foundPurchaseMethod {
                            purchaseMethod  = foundPurchaseMethod
                        } else {
                            purchaseMethod = PurchaseMethod(name: methodName, uuid: UUID(uuidString: methodUUID)!, context: CoreDataStack.childContext)
                        }
                        
                        guard let method = purchaseMethod else {return}
                        
                        CoreDataController.shared.findLedgerWith(uuid: UUID(uuidString: ledgerUUID)!, inContext: CoreDataStack.childContext, completion: { (foundLedger) in
                            
                            let ledgerOfPurchase: Ledger?
                            
                            if let foundLedger = foundLedger {
                                ledgerOfPurchase = foundLedger
                            } else {
                                ledgerOfPurchase = Ledger(name: "", uuid: UUID(uuidString: ledgerUUID)!, context: CoreDataStack.childContext)
                            }
                            
                            guard let ledger = ledgerOfPurchase else {return}
                            
                            CoreDataController.shared.findCategoryWith(uuid: UUID(uuidString: categoryUUID)!, inContext: CoreDataStack.childContext, completion: { (foundCategory) in
                                let categoryOfPurchase: Category?
                                
                                if let foundCategory = foundCategory {
                                    categoryOfPurchase = foundCategory
                                } else {
                                    categoryOfPurchase = Category(name: "", uuid: UUID(uuidString: categoryUUID)!, context: CoreDataStack.childContext)
                                }
                                
                                guard let category = categoryOfPurchase else {return}
                                
                                
                                CoreDataController.shared.findUserWith(uuid: UUID(uuidString: userUUID)!, inContext: CoreDataStack.childContext, completion: { (foundUser) in
                                    let userOfOPurchase: User?
                                    
                                    if let foundUser = foundUser {
                                        userOfOPurchase = foundUser
                                    } else {
                                        userOfOPurchase = User(name: "", appleUserUUID: appleUserUUID, uuid: UUID(uuidString: userUUID)!, context: CoreDataStack.childContext)
                                    }
                                    
                                    
                                    guard let user = userOfOPurchase else {return}
                                    
                                    if let purchaseFromCD = purchaseFromCD {
                                        //update
                                        if Calendar.current.compare(lastModified, to: purchaseFromCD.lastModified!, toGranularity: Calendar.Component.second).rawValue > 0 {
                                            
                                            purchaseFromCD.amount = NSDecimalNumber(value: amount)
                                            purchaseFromCD.date = date
                                            purchaseFromCD.item = item
                                            purchaseFromCD.storeName = storeName
                                            purchaseFromCD.uuid = uuid
                                            purchaseFromCD.purchaseMethod = method
                                            purchaseFromCD.methodName = method.name
                                            purchaseFromCD.methodUUID = method.uuid
                                            purchaseFromCD.ledger = ledger
                                            purchaseFromCD.ledgerUUID = ledger.uuid
                                            purchaseFromCD.category = category
                                            purchaseFromCD.categoryUUID = category.uuid
                                            purchaseFromCD.user = user
                                            purchaseFromCD.userUUID = user.uuid
                                            purchaseFromCD.appleUser = user.appleUser
                                            purchaseFromCD.lastModified = lastModified
                                        }
                                    } else {
                                        //create new Purchase in ChildContext
                                        Purchase(amount: NSDecimalNumber(value: amount), date: date, item: item, storeName: storeName, uuid: uuid, lastModified: lastModified, purchaseMethod: method, category: category, user: user, ledger: ledger, context: CoreDataStack.childContext)
                                    }
                                })
                            })
                        })
                    })
                })
            } else if recordFromCK.recordType == PurchaseMethod.typeKey {
                CoreDataController.shared.findPurchaseMethodWith(uuid: uuid, completion: { (foundPurchaseMethod) in
                    
                    guard let name = recordFromCK[PurchaseMethod.nameKey] as? String,
                        let lastModified = recordFromCK[PurchaseMethod.lastModifiedKey] as? Date else {return}
                    
                    if let foundPurchaseMethod = foundPurchaseMethod {
                        //update
                        if Calendar.current.compare(lastModified, to: foundPurchaseMethod.lastModified!, toGranularity: Calendar.Component.second).rawValue > 0 {
                            
                            foundPurchaseMethod.name = name
                            foundPurchaseMethod.uuid = uuid
                            foundPurchaseMethod.lastModified = lastModified
                        }
                    } else {
                        //create new Purchase in ChildContext
                        PurchaseMethod(name: name, uuid: uuid, lastModified: lastModified, context: CoreDataStack.childContext)
                    }
                })
            } else if recordFromCK.recordType == Ledger.typeKey {
                CoreDataController.shared.findLedgerWith(uuid: uuid, completion: { (foundLedger) in
                    
                    guard let name = recordFromCK[Ledger.nameKey] as? String,
                        let lastModified = recordFromCK[Ledger.lastModifiedKey] as? Date else {return}
                    
                    if let foundLedger = foundLedger {
                        //update foundLedger
                        if Calendar.current.compare(lastModified, to: foundLedger.lastModified!, toGranularity: Calendar.Component.second).rawValue > 0 {
                            
                            foundLedger.name = name
                            foundLedger.uuid = uuid
                            foundLedger.lastModified = lastModified
                        }
                    } else {
                        //create new Ledger in ChildContext
                        Ledger(name: name, uuid: uuid, lastModified: lastModified, context: CoreDataStack.childContext)
                    }
                })
            } else if recordFromCK.recordType == Category.typeKey {
                CoreDataController.shared.findCategoryWith(uuid: uuid, completion: { (foundCategory) in
                    
                    guard let name = recordFromCK[Category.nameKey] as? String,
                        let color = recordFromCK[Category.colorKey] as? String?,
                        let lastModified = recordFromCK[Category.lastModifiedKey] as? Date else {return}
                    
                    if let foundCategory = foundCategory {
                        //update foundCategory
                        if Calendar.current.compare(lastModified, to: foundCategory.lastModified!, toGranularity: Calendar.Component.second).rawValue > 0 {
                            
                            foundCategory.name = name
                            foundCategory.uuid = uuid
                            foundCategory.color = color
                            foundCategory.lastModified = lastModified
                        }
                    } else {
                        //create new Category in ChildContext
                        Category(name: name, color: color, uuid: uuid, lastModified: lastModified, context: CoreDataStack.childContext)
                    }
                })
            } else if recordFromCK.recordType == User.typeKey {
                CoreDataController.shared.findUserWith(uuid: uuid, completion: { (foundUser) in
                    
                    guard let name = recordFromCK[User.nameKey] as? String,
                        let color = recordFromCK[User.colorKey] as? String?,
                        let lastModified = recordFromCK[User.lastModifiedKey] as? Date else {return}
                    
                    if let foundUser = foundUser {
                        //update foundUser
                        if Calendar.current.compare(lastModified, to: foundUser.lastModified!, toGranularity: Calendar.Component.second).rawValue > 0 {
                            
                            foundUser.name = name
                            foundUser.color = color
                            foundUser.lastModified = lastModified
                        }
                    } else {
                        //create new User in ChildContext
                        User(record: recordFromCK, context: CoreDataStack.childContext)
                    }
                })
            }
        }
        
        //delete
        recordIDs.forEach { (recordID) in
            CoreDataController.shared.findPurchaseWith(uuid: UUID(uuidString: recordID.recordName)!, inContext: CoreDataStack.childContext, completion: { (purchaseToDelete) in
                if let purchase = purchaseToDelete {
                    CoreDataController.shared.remove(object: purchase)
                }
            })
            CoreDataController.shared.findPurchaseMethodWith(uuid: UUID(uuidString: recordID.recordName)!, inContext: CoreDataStack.childContext, completion: { (purchaseMethodToDelete) in
                if let purchaseMethod = purchaseMethodToDelete {
                    CoreDataController.shared.remove(object: purchaseMethod)
                }
            })
            CoreDataController.shared.findLedgerWith(uuid: UUID(uuidString: recordID.recordName)!, inContext: CoreDataStack.childContext, completion: { (ledgerToDelete) in
                if let ledger = ledgerToDelete {
                    CoreDataController.shared.remove(object: ledger)
                }
            })
            CoreDataController.shared.findCategoryWith(uuid: UUID(uuidString: recordID.recordName)!, inContext: CoreDataStack.childContext, completion: { (categoryToDelete) in
                if let category = categoryToDelete {
                    CoreDataController.shared.remove(object: category)
                }
            })
            CoreDataController.shared.findUserWith(uuid: UUID(uuidString: recordID.recordName)!, inContext: CoreDataStack.childContext, completion: { (userToDelete) in
                if let user = userToDelete {
                    CoreDataController.shared.remove(object: user)
                }
            })
        }
        
        //save
        do {
            if CoreDataStack.childContext.hasChanges {
                try CoreDataStack.childContext.save()
            }
        } catch {
            print("Error saving updated Objects to childContext with error: \(String(describing: error)) \(error.localizedDescription))")
        }
        CoreDataController.shared.saveToPersistentStore()
    }
    
    ///Retries upload of cached objects.
    func saveCachedPurchasesToCK() {
        var cachedPurchases: [CachePurchase] = []
        var recordsToUpdate: [CKRecord] = []
        var recordsToDelete: [CKRecord.ID] = []

        
        let dateSort = NSSortDescriptor(key: "\(CachePurchase.uploadKey)", ascending: false)
        let fetchRequest: NSFetchRequest<CachePurchase> = CachePurchase.fetchRequest()
        fetchRequest.sortDescriptors = [dateSort]
        do {
            cachedPurchases =  try CoreDataStack.context.fetch(fetchRequest)
        } catch {
            print("Error fetching cachedObjects with error: \(String(describing: error)) \(error.localizedDescription))")
        }
        
        
        cachedPurchases.forEach { (cachedPurchase) in
            //TODO: FIND PURCHASE METHOD
            //TODO: FIND LEDGER
            //TODO: FIND CATEGORY
            //TODO: FIND USER
            CoreDataController.shared.findPurchaseWith(uuid: cachedPurchase.uuid, completion: { (purchaseFromCD) in
                if let purchase = purchaseFromCD {
                    //sent update to CK
                    recordsToUpdate.append(CKRecord(purchase: purchase)!)
                } else {
                    //sentdeleteToCK
                    if let uuid = cachedPurchase.uuid?.uuidString {
                        recordsToDelete.append(CKRecord.ID(recordName: uuid))
                    }
                }
            })

        }
        
        //FIX THIS FUNCTION YOU NEED TO FIND THE CACHE

        CloudKitController.shared.saveChangestoCK(recordsToUpdate: recordsToUpdate, purchasesToDelete: recordsToDelete) { (isSuccess, savedRecords, deletedRecordIDs) in
            guard let savedRecords = savedRecords, let deletedRecordIDs = deletedRecordIDs, isSuccess else {return}
            savedRecords.forEach({ (record) in
                CoreDataController.shared.findPurchaseWith(uuid: UUID(uuidString: record.recordID.recordName), completion: { (cachePurchase) in
                    guard let cachePurchase = cachePurchase else {return}
                    CoreDataController.shared.remove(object: cachePurchase)
                })
            })
            deletedRecordIDs.forEach({ (recordID) in
                CoreDataController.shared.findPurchaseWith(uuid: UUID(uuidString: recordID.recordName), completion: { (cachePurchase) in
                    guard let cachePurchase = cachePurchase else {return}
                    CoreDataController.shared.remove(object: cachePurchase)
                })
            })
        }
    }
}
