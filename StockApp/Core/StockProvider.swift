//
//  StockProvider.swift
//  StockApp
//
//  Created by developer on 1/4/26.
//

protocol StockProvider: Sendable {
    func start() async
    func stop() async
    func get() async -> [Stock]
}
