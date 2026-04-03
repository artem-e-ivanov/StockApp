//
//  StockProviderWeb.swift
//  StockApp
//
//  Created by developer on 1/4/26.
//

import os
import Foundation
import Combine
import Starscream

actor StockProviderWeb: StockProvider {
    var endpoint: URL

    var status: AnyPublisher<StockProviderStatus, Never> { $_status.eraseToAnyPublisher() }
    @Published private var _status: StockProviderStatus = .offline

    private var webSocket: WebSocket
    private var bufferLock = OSAllocatedUnfairLock(initialState: [String: Stock]())
    private var cacheLock = OSAllocatedUnfairLock(initialState: [String: Double]())
    private var senderTask: Task<Void, Never>?
    
    init(endpoint: URL) async {
        self.endpoint = endpoint

        var request = URLRequest(url: endpoint)
        request.timeoutInterval = 3

        self.webSocket = WebSocket(request: request, engine: WSEngine(transport: FoundationTransport()))
        webSocket.onEvent = { [weak self] event in
            Task {
                await self?.onEvent(event)
            }
        }
    }
    
    deinit {
        webSocket.forceDisconnect()
    }
    
    func start() async {
        guard _status == .offline else { return }
        
        _status = .connecting

        webSocket.connect()
    }
    
    func stop() async {
        guard _status != .offline else { return }
        
        _status = .connecting

        senderTask?.cancel()
        senderTask = nil
        
        webSocket.disconnect(closeCode: CloseCode.normal.rawValue)
        
        // TODO: Start a timed check for no server reaction
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
        } else if case .text(let string) = event {
            onText(string)
        } else {
            _status = .connecting
            senderTask?.cancel()
            senderTask = nil

            if case .disconnected(_, _) = event {
                onDisconnected()
            }
            if case .error(_) = event {
                onDisconnected()
            }
            if case .cancelled = event {
                onDisconnected()
            }
        }
    }
    
    private func onConnected() {
        _status = .online
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
                await self?.webSocket.write(string: message)

                try? await Task.sleep(for: .milliseconds(100))
            }
        }
    }
    
    private func onDisconnected() {
        _status = .offline
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
