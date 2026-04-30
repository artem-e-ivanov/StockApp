//
//  StockListCoordinator.swift
//  StockApp
//
//  Created by developer on 1/4/26.
//

import SwiftUI

final class StockListCoordinator: Coordinator {
    var path: Binding<StockAppPath>

    var parent: (any Coordinator)? = nil
    private(set) var children: [any Coordinator] = []

    private var viewModel: StockListViewModel
    
    init(path: Binding<StockAppPath>) {
        self.path = path

        viewModel = StockListViewModel()
        viewModel.onStockSelected = { [weak self] stock in
            self?.path.wrappedValue.path.append(Feature.stockDetails.rawValue + "=" + stock.symbol)
        }
        if let stockDetailsCoordinator = AppDIContainer.shared.resolve(FeatureModulesProvider.self)?.getFeature(feature: .stockDetails)?.makeCoordinator(path: path) {
            children.append(stockDetailsCoordinator)
            stockDetailsCoordinator.parent = self
        }
    }
    
    @ViewBuilder func buildView() -> StockListView {
        StockListView(viewModel: viewModel)
    }
    
    func canCoordinate(for path: String) -> Bool {
        path == Feature.stockList.rawValue
    }
}

