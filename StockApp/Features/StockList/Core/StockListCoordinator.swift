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
        guard let stockDetailsCoordinator = stockDetailsCoordinator else { return }

        let routes = path.components(separatedBy: "/")
        guard let firstRoute = routes.first,
              !firstRoute.isEmpty else { return }
        
        // TODO: Consider checking if child can coordinate
        // TODO: Consider passing parent in order for child to decide how to present itself

        stockDetailsCoordinator.start()
        guard let stockDetailsViewController = stockDetailsCoordinator.viewController else { return }

        stockDetailsCoordinator.coordinate(with: firstRoute)

        viewController?.present(stockDetailsViewController, animated: true)
    }
}

