//
//  StockDetailsViewModel.swift
//  StockApp
//
//  Created by developer on 1/4/26.
//

import UIKit
import Combine

@MainActor
final class StockDetailsViewModel {
    public var symbol: String!
    private var stockProvider: StockProvider!
    
    func configure(_ symbol: String) {
        self.symbol = symbol
        stockProvider = AppDIContainer.shared.resolve(StockProvider.self)
        
        AppDIContainer.shared.resolve(Logger.self)?.log("StockDetails avtivated with symbol \(symbol)")
    }
    
    func viewNeedsData() async -> Stock? {
        await stockProvider.get(symbol: symbol)
    }
}
