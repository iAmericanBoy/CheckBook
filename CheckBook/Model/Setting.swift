//
//  Settings.swift
//  CheckBook
//
//  Created by Dominic Lanzillotta on 4/9/19.
//  Copyright © 2019 Dominic Lanzillotta. All rights reserved.
//

import Foundation

enum Setting: CaseIterable {
    static var allCases: [Setting] = [.share(false), .deletePersonalData]
    typealias AllCases = [Setting]

    case share(Bool)
    case deletePersonalData
}
