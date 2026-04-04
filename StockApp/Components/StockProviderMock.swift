//
//  StockProviderMock.swift
//  StockApp
//
//  Created by developer on 1/4/26.
//

import os
import Foundation
import Combine

// Simulates data changes using random symbol updates.
actor StockProviderMock: StockProvider {
    var status: AnyPublisher<StockProviderStatus, Never> { $_status.eraseToAnyPublisher() }
    @Published private var _status: StockProviderStatus = .offline {
        didSet {
            AppDIContainer.shared.resolve(Logger.self)?.log("StockProviderMock status \(_status)")
        }
    }

    // Buffer accumulates changed symmbols.
    private var bufferLock = OSAllocatedUnfairLock(initialState: [String: Stock]())
    // Stores the list of stock symbols in order to calculate price change.
    private var cacheLock = OSAllocatedUnfairLock(initialState: [String: Stock]())
    private var task: Task<Void, Never>?

    deinit {
        task?.cancel()
    }
    
    func start() async {
        guard task == nil else { return }
        
        _status = .online
        task = Task { [weak self] in
            while !Task.isCancelled {
                guard let randomSymbol = StockSymbolListProvider.symbols.randomElement() else { continue }

                // Generates random price change according to the previous value.
                let stock = await self?.cacheLock.withLock { cache in
                    let change = Double.random(in: -1...1)
                    let price = cache[randomSymbol]?.price ?? Double.random(in: 100...1000)
                    cache[randomSymbol] = Stock(symbol: randomSymbol,
                                                price: price + change,
                                                change: change)

                    return cache[randomSymbol]
                }
                if let stock = stock {
                    // Adds a new change to the buffer.
                    await self?.bufferLock.withLock { buffer in
                        buffer[randomSymbol] = stock
                    }
                }
                
                await Task.yield()
                try? await Task.sleep(for: .milliseconds(50))
            }
        }
    }
    
    func stop() async {
        task?.cancel()
        task = nil
        _status = .offline
    }
    
    // Returns current buffer contents and drains the buffer.
    func get() async -> [Stock] {
        bufferLock.withLock { buffer in
            defer { buffer.removeAll() }
            return Array(buffer.values)
        }
    }
    
    // Returns current state of a specific symbol.
    func get(symbol: String) async -> Stock? {
        cacheLock.withLock { cache in
            cache[symbol]
        }
    }
}
