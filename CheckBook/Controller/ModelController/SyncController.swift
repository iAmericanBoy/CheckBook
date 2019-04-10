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
                CoreDataController.shared.findPurchaseWith(uuid: uuid,inContext: CoreDataStack.context, completion: { purchaseFromCD in
                    
                    guard let amount = recordFromCK[Purchase.amountKey] as? Double,
                        let date = recordFromCK[Purchase.dateKey] as? Date,
                        let item = recordFromCK[Purchase.itemKey] as? String,
                        let methodUUID = recordFromCK[Purchase.methodKey] as? String,
                        let ledgerUUID = recordFromCK[Purchase.ledgerKey] as? String,
                        let categoryUUID = recordFromCK[Purchase.categoryKey] as? String,
                        let lastModified = recordFromCK[Purchase.lastModifiedKey] as? Date,
                        let storeName = recordFromCK[Purchase.storeNameKey] as? String else {return}
                    
                    CoreDataController.shared.findPurchaseMethodWith(uuid: UUID(uuidString: methodUUID)!, inContext: CoreDataStack.context, completion: { (foundPurchaseMethod) in
                        let purchaseMethod: PurchaseMethod?
                        
                        if let foundPurchaseMethod = foundPurchaseMethod {
                            purchaseMethod  = foundPurchaseMethod
                        } else {
                            purchaseMethod = PurchaseMethod(name: "", uuid: UUID(uuidString: methodUUID)!, lastModified: Date(timeIntervalSince1970: 0), context: CoreDataStack.context)
                        }

                        
                        guard let method = purchaseMethod else {return}
                        
                        CoreDataController.shared.findLedgerWith(uuid: UUID(uuidString: ledgerUUID)!, inContext: CoreDataStack.context, completion: { (foundLedger) in
                            
                            let ledgerOfPurchase: Ledger?
                            
                            if let foundLedger = foundLedger {
                                ledgerOfPurchase = foundLedger
                            } else {
                                ledgerOfPurchase = Ledger(name: "", uuid: UUID(uuidString: ledgerUUID)!, appleUserRecordName: nil, lastModified: Date(timeIntervalSince1970: 0), context: CoreDataStack.context)
                            }

                            
                            guard let ledger = ledgerOfPurchase else {return}
                            
                            CoreDataController.shared.findCategoryWith(uuid: UUID(uuidString: categoryUUID)!, inContext: CoreDataStack.context, completion: { (foundCategory) in
                                let categoryOfPurchase: Category?
                                
                                if let foundCategory = foundCategory {
                                    categoryOfPurchase = foundCategory
                                } else {
                                    categoryOfPurchase = Category(name: "", uuid: UUID(uuidString: categoryUUID)!, lastModified: Date(timeIntervalSince1970: 0), context: CoreDataStack.context)
                                }

                                
                                guard let category = categoryOfPurchase else {return}
                                
                                
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
                                        purchaseFromCD.appleUserRecordName = recordFromCK.creatorUserRecordID?.recordName
                                        purchaseFromCD.lastModified = lastModified
                                    }
                                } else {
                                    //create new Purchase in ChildContext
                                    Purchase(amount: NSDecimalNumber(value: amount), date: date, item: item, storeName: storeName, uuid: uuid, lastModified: lastModified, purchaseMethod: method, category: category, appleUserRecordName: recordFromCK.creatorUserRecordID?.recordName, ledger: ledger)
                                }
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
                            foundPurchaseMethod.color = recordFromCK[PurchaseMethod.colorKey] as? String
                            foundPurchaseMethod.lastModified = lastModified
                        }
                    } else {
                        //create new PurchaseMethod in ChildContext
                        PurchaseMethod(record: recordFromCK, context: CoreDataStack.context)
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
                        Ledger(record: recordFromCK, context: CoreDataStack.context)
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
                        Category(record: recordFromCK, context: CoreDataStack.context)
                    }
                })
            }
        }
        
        //delete
        recordIDs.forEach { (recordID) in
            CoreDataController.shared.findPurchaseWith(uuid: UUID(uuidString: recordID.recordName)!, inContext: CoreDataStack.context, completion: { (purchaseToDelete) in
                if let purchase = purchaseToDelete {
                    CoreDataController.shared.remove(object: purchase)
                }
            })
            CoreDataController.shared.findPurchaseMethodWith(uuid: UUID(uuidString: recordID.recordName)!, inContext: CoreDataStack.context, completion: { (purchaseMethodToDelete) in
                if let purchaseMethod = purchaseMethodToDelete {
                    CoreDataController.shared.remove(object: purchaseMethod)
                }
            })
            CoreDataController.shared.findLedgerWith(uuid: UUID(uuidString: recordID.recordName)!, inContext: CoreDataStack.context, completion: { (ledgerToDelete) in
                if let ledger = ledgerToDelete {
                    CoreDataController.shared.remove(object: ledger)
                }
            })
            CoreDataController.shared.findCategoryWith(uuid: UUID(uuidString: recordID.recordName)!, inContext: CoreDataStack.context, completion: { (categoryToDelete) in
                if let category = categoryToDelete {
                    CoreDataController.shared.remove(object: category)
                }
            })
        }
        
        saveObjectsInContexts()
        
        NotificationCenter.default.post(Notification.syncFinished)
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
            
            CoreDataController.shared.findLedgerWith(uuid: cachedPurchase.uuid, completion: { (ledgerFromCD) in
                if let ledger = ledgerFromCD {
                    //sent update to CK
                    recordsToUpdate.append(CKRecord(ledger: ledger)!)
                } else {
                    //sentdeleteToCK
                    if let uuid = cachedPurchase.uuid?.uuidString {
                        recordsToDelete.append(CKRecord.ID(recordName: uuid))
                    }
                }
            })
            
            CoreDataController.shared.findCategoryWith(uuid: cachedPurchase.uuid, completion: { (categoryFromCD) in
                if let category = categoryFromCD {
                    //sent update to CK
                    recordsToUpdate.append(CKRecord(category: category)!)
                } else {
                    //sentdeleteToCK
                    if let uuid = cachedPurchase.uuid?.uuidString {
                        recordsToDelete.append(CKRecord.ID(recordName: uuid))
                    }
                }
            })
            
            CoreDataController.shared.findPurchaseMethodWith(uuid: cachedPurchase.uuid, completion: { (methodFromCD) in
                if let method = methodFromCD {
                    //sent update to CK
                    recordsToUpdate.append(CKRecord(purchaseMethod: method)!)
                } else {
                    //sentdeleteToCK
                    if let uuid = cachedPurchase.uuid?.uuidString {
                        recordsToDelete.append(CKRecord.ID(recordName: uuid))
                    }
                }
            })
        }
        
        CloudKitController.shared.saveChangestoCK(recordsToUpdate: recordsToUpdate, purchasesToDelete: recordsToDelete) { (isSuccess, savedRecords, deletedRecordIDs) in
            guard let savedRecords = savedRecords, let deletedRecordIDs = deletedRecordIDs, isSuccess else {return}
            savedRecords.forEach({ (record) in
                
                CoreDataController.shared.findCacheWith(uuid: UUID(uuidString: record.recordID.recordName), completion: { (foundCache) in
                    guard let cacheObject = foundCache else {return}
                    CoreDataController.shared.remove(object: cacheObject)
                })
            })
            
            deletedRecordIDs.forEach({ (recordID) in
                CoreDataController.shared.findCacheWith(uuid: UUID(uuidString: recordID.recordName), completion: { (foundCache) in
                    guard let cacheObject = foundCache else {return}
                    CoreDataController.shared.remove(object: cacheObject)
                })
            })
        }
    }
    
    fileprivate func saveObjectsInContexts() {
        //save
        do {
//            if CoreDataStack.childContext.hasChanges {
//                try CoreDataStack.childContext.save()
//            }
        } catch {
            print("Error saving updated Objects to childContext with error: \(String(describing: error)) \(error.localizedDescription))")
        }
        CoreDataController.shared.saveToPersistentStore()
    }
}
