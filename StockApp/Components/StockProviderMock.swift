//
//  StockProviderMock.swift
//  StockApp
//
//  Created by developer on 1/4/26.
//

import os
import Foundation

actor StockProviderMock: StockProvider {
    private var bufferLock = OSAllocatedUnfairLock(initialState: [Stock]())
    private var task: Task<Void, Never>?
    
    func start() async {
        guard task == nil else { return }
        
        bufferLock.withLock {
            $0 = StockListProvider.stockList.map {
                Stock(symbol: $0,
                      price: Decimal(Double.random(in: 0...1000)),
                      change: 0)
            }
        }
        
        task = Task {
            while !Task.isCancelled {
                bufferLock.withLock { stock in
                    stock = StockListProvider.stockList.enumerated().map { (index, symbol) in
                        let change = Decimal(Double.random(in: -1...1))
                        return Stock(symbol: symbol,
                                     price: max(0, stock[index].price + change),
                                     change: change)
                    }
                }
                try? await Task.sleep(for: .milliseconds(50))
            }
        }
    }
    
    func stop() async {
        task?.cancel()
        task = nil
    }
    
    func get() async -> [Stock] {
        bufferLock.withLock { buffer in
            return buffer
        }
    }
}
