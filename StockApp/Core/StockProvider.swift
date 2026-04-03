//
//  StockProvider.swift
//  StockApp
//
//  Created by developer on 1/4/26.
//

import Combine

protocol StockProvider: Sendable {
    var status: AnyPublisher<StockProviderStatus, Never> { get async }
    
    func start() async
    func stop() async
    func get() async -> [Stock]
}
