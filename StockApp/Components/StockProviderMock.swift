//
//  StockProviderMock.swift
//  StockApp
//
//  Created by developer on 1/4/26.
//

import os
import Foundation
import Combine

actor StockProviderMock: StockProvider {
    var status: AnyPublisher<StockProviderStatus, Never> { $_status.eraseToAnyPublisher() }
    @Published private var _status: StockProviderStatus = .offline

    private var bufferLock = OSAllocatedUnfairLock(initialState: [String: Stock]())
    private var cacheLock = OSAllocatedUnfairLock(initialState: [String: Double]())
    private var task: Task<Void, Never>?

    deinit {
        task?.cancel()
    }
    
    func start() async {
        guard task == nil else { return }
        
        _status = .connecting
        try? await Task.sleep(for: .milliseconds(500))
        _status = .online

        task = Task { [weak self] in
            while !Task.isCancelled {
                guard let randomSymbol = StockSymbolListProvider.symbols.randomElement() else { continue }

                let stock = await self?.cacheLock.withLock { cache in
                    let change = Double.random(in: -1...1)
                    let price = cache[randomSymbol] ?? Double.random(in: 100...1000)
                    cache[randomSymbol] = price + change

                    return Stock(symbol: randomSymbol,
                                 price: price,
                                 change: change)
                }
                guard let stock = stock else { continue }

                await self?.bufferLock.withLock { buffer in
                    buffer[randomSymbol] = stock
                }
                
                try? await Task.sleep(for: .milliseconds(50))
            }
        }
    }
    
    func stop() async {
        task?.cancel()
        task = nil
        _status = .offline
    }
    
    func get() async -> [Stock] {
        bufferLock.withLock { buffer in
            defer { buffer.removeAll() }
            return Array(buffer.values)
        }
    }
}
