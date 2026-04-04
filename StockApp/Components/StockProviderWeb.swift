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

// Proovides real-time data taken from the remote websocket.
// Logically has the same buffer as the mock version.
actor StockProviderWeb: StockProvider {
    var endpoint: URL

    var status: AnyPublisher<StockProviderStatus, Never> { $_status.eraseToAnyPublisher() }
    @Published private var _status: StockProviderStatus = .offline {
        didSet {
            AppDIContainer.shared.resolve(Logger.self)?.log("StockProviderMock status \(_status)")
        }
    }

    private var webSocket: WebSocket
    private var bufferLock = OSAllocatedUnfairLock(initialState: [String: Stock]())
    private var cacheLock = OSAllocatedUnfairLock(initialState: [String: Stock]())
    // Built-in periodic task for generatin random price change and sending them into the websocket.
    // IMPROVEMENT: Better to be moved outside and used as a dependency.
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
        
        senderTask?.cancel()
        senderTask = nil
        
        // If user don't want to wait and wants to disconnect during the connection/disconnection flow,
        // then close the connection forcibly.
        if _status == .connecting {
            _status = .offline
            webSocket.forceDisconnect()
        } else {
            // Try to disconnect gracefully.
            _status = .connecting
            webSocket.disconnect(closeCode: CloseCode.normal.rawValue)
        }
    }
    
    func get() async -> [Stock] {
        bufferLock.withLock { buffer in
            defer { buffer.removeAll() }
            return Array(buffer.values)
        }
    }
    
    func get(symbol: String) async -> Stock? {
        cacheLock.withLock { cache in
            cache[symbol]
        }
    }
    
    // Handle incoming data and connection status.
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
        // Starts a sender task which generates random price changes according to their previous state.
        senderTask = Task { [weak self] in
            while !Task.isCancelled {
                guard let randomSymbol = StockSymbolListProvider.symbols.randomElement() else {
                    continue
                }
                
                let price = await self?.cacheLock.withLock { cache in
                    let change = Double.random(in: -1...1)
                    let price = cache[randomSymbol]?.price ?? Double.random(in: 100...1000)
                    
                    return price + change
                }
                guard let price = price else { continue }

                let message = randomSymbol + ":\(price)"
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

        // Update cache and detect price difference
        let stock = cacheLock.withLock { cache in
            let change = price - (cache[symbol]?.price ?? price)
            cache[symbol] = Stock(symbol: symbol,
                                  price: price,
                                  change: change)

            return cache[symbol]
        }
        
        guard let stock = stock else { return }

        // Add an event into the buffer
        bufferLock.withLock { buffer in
            buffer[symbol] = stock
        }
    }
}
