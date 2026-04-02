//
//  StockProviderWeb.swift
//  StockApp
//
//  Created by developer on 1/4/26.
//

import os
import Foundation
import Starscream

actor StockProviderWeb: StockProvider {
    var endpoint: URL
    private var webSocket: WebSocket?
    private var bufferLock = OSAllocatedUnfairLock(initialState: [String: Stock]())
    private var cacheLock = OSAllocatedUnfairLock(initialState: [String: Double]())
    private var senderTask: Task<Void, Never>?
    
    init(endpoint: URL) {
        self.endpoint = endpoint
    }
    
    deinit {
        webSocket?.disconnect()
    }
    
    func start() async {
        guard webSocket == nil else { return }
        
        var request = URLRequest(url: endpoint)
        request.timeoutInterval = 3
        webSocket = WebSocket(request: request, engine: WSEngine(transport: FoundationTransport()))
        webSocket?.onEvent = { [weak self] event in
            Task {
                await self?.onEvent(event)
            }
        }
        webSocket?.connect()
    }
    
    func stop() async {
        senderTask?.cancel()
        senderTask = nil
        
        webSocket?.disconnect()
        webSocket = nil
    }
    
    func get() async -> [Stock] {
        bufferLock.withLock { buffer in
            defer { buffer.removeAll() }
            return Array(buffer.values)
        }
    }
    
    private func onEvent(_ event: WebSocketEvent) async {
        if case .connected(_) = event {
            onConnected()
        }
        if case .disconnected(_, _) = event {
            onDisconnected()
        }
        if case .text(let string) = event {
            onText(string)
        }
        if case .error(let error) = event {
            print("socker error: \(error)")
        }
        // TODO: Handle reconnection
    }
    
    private func onConnected() {
        senderTask = Task { [weak self] in
            while !Task.isCancelled {
                guard let randomSymbol = StockSymbolListProvider.symbols.randomElement() else {
                    continue
                }
                
                let stock = await self?.cacheLock.withLock { cache in
                    let change = Double.random(in: -1...1)
                    let price = cache[randomSymbol] ?? Double.random(in: 100...1000)
                    cache[randomSymbol] = price + change

                    return Stock(symbol: randomSymbol,
                                 price: price,
                                 change: change)
                }
                guard let stock = stock else { continue }

                let message = randomSymbol + ":\(stock.price)"
                await self?.webSocket?.write(string: message)

                try? await Task.sleep(for: .milliseconds(100))
            }
        }
    }
    
    private func onDisconnected() {
        senderTask?.cancel()
        senderTask = nil
    }
    
    private func onText(_ string: String) {
        let components = string.split(separator: ":")
        
        guard components.count == 2,
              let price = Double(components[1]) else { return }

        let symbol = String(components[0])
        let stock = cacheLock.withLock { cache in
            let change = price - (cache[symbol] ?? price)

            return Stock(symbol: symbol,
                         price: price,
                         change: change)
        }

        bufferLock.withLock { buffer in
            buffer[symbol] = stock
        }
    }
}
