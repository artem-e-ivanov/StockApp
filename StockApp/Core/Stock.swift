//
//  Stock.swift
//  StockApp
//
//  Created by developer on 1/4/26.
//

import Foundation

nonisolated struct Stock: Hashable, Sendable {
    let symbol: String
    let price: Decimal
    let change: Decimal
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(symbol)
    }
    static func == (lhs: Stock, rhs: Stock) -> Bool {
        lhs.symbol == rhs.symbol && lhs.price == rhs.price && lhs.change == rhs.change
    }
}
