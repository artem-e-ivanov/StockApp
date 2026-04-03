//
//  StockListViewModel.swift
//  StockApp
//
//  Created by developer on 1/4/26.
//

import UIKit
import Combine

@MainActor
final class StockListViewModel {
    typealias DataSource = UITableViewDiffableDataSource<Int, Stock>

    @Published var sortOrder = StockListSortOrder.title
    @Published var stockProviderStatus = StockProviderStatus.offline
    var onStockSelected: ((Stock) -> Void)?
    
    private var stockProvider: StockProvider!
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Int, Stock>
    private var dataSource: DataSource!
    
    func configure(tableView: UITableView, cellProvider: @escaping DataSource.CellProvider) {
        dataSource = DataSource(tableView: tableView, cellProvider: cellProvider)
        stockProvider = AppDIContainer.shared.resolve(StockProvider.self)
        
        Task { [weak self] in
            guard let self = self else { return }

            let status = await self.stockProvider?.status
            status?.assign(to: &self.$stockProviderStatus)
        }
    }
    
    func startStopUpdates() async {
        if stockProviderStatus == .offline {
            await stockProvider?.start()
        } else {
            await stockProvider?.stop()
        }
    }
    
    func viewNeedsData() async {
        let stock = await stockProvider.get()
        var snapshot = dataSource.snapshot()
        if snapshot.numberOfSections == 0 {
            snapshot = Snapshot()
            snapshot.appendSections([0])
            snapshot.appendItems(stock)
        } else {
            var toAdd = [Stock]()
            var toChange = [Stock]()
            stock.forEach { newStock in
                if let oldStock = snapshot.itemIdentifiers.first(where: { $0.symbol == newStock.symbol }) {
                    snapshot.insertItems([newStock], afterItem: oldStock)
                    snapshot.deleteItems([oldStock])
                    toChange.append(newStock)
                } else {
                    toAdd.append(newStock)
                }
            }
            snapshot.reconfigureItems(toChange)
            snapshot.appendItems(toAdd)
        }
        
        await applyUpdatesAndSort(snapshot)
    }
    
    func viewTapsOnStock(_ indexPath: IndexPath) {
        guard let stock = dataSource.itemIdentifier(for: indexPath) else { return }
        
        onStockSelected?(stock)
    }
    
    private func applyUpdatesAndSort(_ snapshot: Snapshot) async {
        let sorter: (Stock, Stock) -> Bool
        switch sortOrder {
            case .title:
                sorter = { $0.symbol < $1.symbol }
            case .price:
                sorter = { $0.price > $1.price }
            case .change:
                sorter = { $0.change > $1.change }
        }
        var stock = snapshot.itemIdentifiers
        stock.sort(by: sorter)
        
        var snapshot = Snapshot()
        snapshot.appendSections([0])
        snapshot.appendItems(stock)

        await dataSource.apply(snapshot, animatingDifferences: false)
    }
}
