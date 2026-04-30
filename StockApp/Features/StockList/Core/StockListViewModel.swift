//
//  StockListViewModel.swift
//  StockApp
//
//  Created by developer on 1/4/26.
//

import Foundation
import Observation
import Combine

@MainActor
@Observable
final class StockListViewModel {
    var stockProviderStatus: StockProviderStatus = .offline
    var stockItems: [Stock] = []
    var stockItemsVersion: Int = 0
    var onStockSelected: ((Stock) -> Void)?
    
    private let stockProvider: StockProvider!
    private var stockBuffer: [String: Stock] = [:]
    private var sortOrder: StockListSortOrder = .title
    private var bag: Set<AnyCancellable> = []
    
    init() {
        stockProvider = AppDIContainer.shared.resolve(StockProvider.self)
        Task {
            (await stockProvider.status)
                .receive(on: DispatchQueue.main)
                .assign(to: \.stockProviderStatus, on: self)
                .store(in: &bag)
        }
        startObserving()
    }
    
    func startStopUpdates() async {
        if stockProviderStatus == .offline {
            await stockProvider.start()
        } else {
            await stockProvider.stop()
        }
    }

    // Starts the data processing flow. Requests a list of buffered stock symbols.
    // Detects the difference and passes it to the sorting procedure.
    func viewNeedsData() async {
        let stockItems = await stockProvider.get()
        await applyUpdatesAndSort(stockItems)
    }
    
    func setSortOrder(_ sortOrder: StockListSortOrder) async {
        AppDIContainer.shared.resolve(Logger.self)?.log("StockList sort order changed \(sortOrder.rawValue)")

        self.sortOrder = sortOrder
        
        await applyUpdatesAndSort(Array(stockBuffer.values))
    }

    func viewTapsOnStock(_ stock: Stock) {
        onStockSelected?(stock)
    }

    private func applyUpdatesAndSort(_ stockItems: [Stock]) async {
        stockItems.forEach {
            stockBuffer[$0.symbol] = $0
        }
        let sorter: (Stock, Stock) -> Bool
        switch sortOrder {
            case .title:
                sorter = { $0.symbol < $1.symbol }
            case .price:
                sorter = { $0.price > $1.price }
            case .change:
                sorter = { $0.change > $1.change }
        }
        self.stockItems = stockBuffer.values.sorted(by: sorter)
        stockItemsVersion += 1
    }
    
    private func startObserving() {
        withObservationTracking { [weak self] in
            _ = self?.stockProviderStatus
        } onChange: { [weak self] in
            Task {
                await Task.yield()
                let status = await self?.stockProviderStatus
                if status == .online {
                    await self?.viewNeedsData()
                }
                await self?.startObserving()
            }
        }
    }
}
