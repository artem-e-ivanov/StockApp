//
//  StockListSortOrder.swift
//  StockApp
//
//  Created by developer on 1/4/26.
//

import Foundation

enum StockListSortOrder: String, CaseIterable {
    case title
    case price
    case change
    
    var localized: String { String(localized: LocalizedStringResource(stringLiteral: self.rawValue)) }
}
