//
//  MagicStrings.swift
//  CheckBook
//
//  Created by Dominic Lanzillotta on 4/10/19.
//  Copyright © 2019 Dominic Lanzillotta. All rights reserved.
//

import Foundation


extension Notification {
    static let syncFinished = Notification(name: Notification.Name("syncFinished"))
    static let appleIdFound = Notification(name: Notification.Name("appleIDFound"))
    static let ledgerAlreadyExists = Notification(name: Notification.Name("ledgerAlreadyExists"))

}
