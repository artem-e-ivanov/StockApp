//
//  StockListViewModelTests.swift
//  StockAppTests
//
//  Created by developer on 4/4/26.
//

import Testing
import UIKit
import Combine
@testable import StockApp

nonisolated class StockAccumulator {
    var stock = [Stock]()
}

@MainActor struct StockListViewModelTests {
    let viewModel: StockListViewModel
    let tableView: UITableView
    static let stockProviderMock = StockProviderMock()
    var stockAccumulator = StockAccumulator()
    
    init() async throws {
        viewModel = StockListViewModel()
        
        _ = AppDIContainer.shared.register(StockProvider.self) { _ in
            Self.stockProviderMock
        }
        
        // Simulate full view tree in order for table view to proceed with cells.
        let window = UIWindow()
        let vc = UIViewController()
        tableView = UITableView()
        window.rootViewController = vc
        window.makeKeyAndVisible()
        vc.view.addSubview(tableView)
        tableView.frame = vc.view.bounds
        tableView.layoutIfNeeded()
        
        let stockAccumulator = self.stockAccumulator
        viewModel.configure(tableView: tableView) { tableView, indexPath, stock in
            stockAccumulator.stock.append(stock)
            return UITableViewCell()
        }
    }
    
    @Test func testProvider() async throws {
        let mirror = Mirror(reflecting: viewModel)
        
        let viewModelStockProvider = mirror.children.first(where: { $0.label == "stockProvider" })?.value as? StockProviderMock
        #expect(viewModelStockProvider != nil)
    }
    
    @Test func testStart() async throws {
        await viewModel.startStopUpdates()
        let status1 = await Self.stockProviderMock.status.values.first { _ in true }
        let status2 = await viewModel.$stockProviderStatus.values.first { _ in true }
        #expect(status1 == .online && status2 == .online)
    }
    
    @Test func testNeedData() async throws {
        stockAccumulator.stock.removeAll()
        await viewModel.viewNeedsData()
        // Need to force table view to deal with its cells
        tableView.layoutIfNeeded()
        #expect(await Self.stockProviderMock.getCalled)
        #expect(stockAccumulator.stock.count == 2)
    }
    
    @Test func testSort() async throws {
        stockAccumulator.stock.removeAll()
        await viewModel.viewNeedsData()
        await viewModel.setSortOrder(.price)
        tableView.layoutIfNeeded()
        #expect(stockAccumulator.stock[0].symbol == "B")
        #expect(stockAccumulator.stock[1].symbol == "A")
        
        stockAccumulator.stock.removeAll()
        await viewModel.setSortOrder(.change)
        tableView.layoutIfNeeded()
        #expect(stockAccumulator.stock[0].symbol == "A")
        #expect(stockAccumulator.stock[1].symbol == "B")
    }
}
