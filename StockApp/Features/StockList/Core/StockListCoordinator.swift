//
//  StockListCoordinator.swift
//  StockApp
//
//  Created by developer on 1/4/26.
//

import UIKit

final class StockListCoordinator: Coordinator {
    let route = Feature.stockList.rawValue
    var viewController: UIViewController?
    
    private var stockDetailsCoordinator: Coordinator?
    
    func start() {
        // Since stock list feature could theoretically know about it's sub-features this logical dependency is made.
        // Normally it is better to keep an array of features and have some sort of logical coupling mechanism
        // which will form the list of nested features.
        // stockDetailsFeatureModule is of generic type FeatureModule and could be used anonymously.
        let fatureModulesProvider = AppDIContainer.shared.resolve(FeatureModulesProvider.self)
        let stockDetailsFeatureModule = fatureModulesProvider?.getFeatureModules().first(where: { $0.feature == .stockDetails })
        stockDetailsCoordinator = stockDetailsFeatureModule?.makeCoordinator()
        
        let viewModel = StockListViewModel()
        viewModel.onStockSelected = { [weak self] stock in
            self?.coordinate(with: stock.symbol)
        }
        viewController = StockListViewController(viewModel: viewModel)
    }
    
    func coordinate(with path: String) {
        AppDIContainer.shared.resolve(Logger.self)?.log("StockList coordinating to \(path)")

        // IMPROVEMENT: Consider checking if child can coordinate

        // Same here - could be implemented using an array of coordinators and choosing whic of them
        // could coordinate to the provided route.
        guard let stockDetailsCoordinator = stockDetailsCoordinator else { return }

        let routes = path.components(separatedBy: "/")
        guard let firstRoute = routes.first,
              !firstRoute.isEmpty else { return }
        
        stockDetailsCoordinator.start()
        guard let stockDetailsViewController = stockDetailsCoordinator.viewController else { return }

        stockDetailsCoordinator.coordinate(with: firstRoute)

        // IMPROVEMENT: Consider passing parent in order for child to decide how to present itself
        viewController?.present(stockDetailsViewController, animated: true)
    }
}

