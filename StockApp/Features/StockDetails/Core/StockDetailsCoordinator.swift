//
//  StockDetailsCoordinator.swift
//  StockApp
//
//  Created by developer on 1/4/26.
//

import UIKit

final class StockDetailsCoordinator: Coordinator {
    let route = Feature.stockDetails.rawValue
    var viewController: UIViewController?
    // View controller must hold the model. If its life is over then there is no need to retain it.
    weak var viewModel: StockDetailsViewModel?
    
    func start() {
        let viewModel = StockDetailsViewModel()
        viewController = UINavigationController(rootViewController: StockDetailsViewController(viewModel: viewModel))
        self.viewModel = viewModel
    }
    
    func coordinate(with path: String) {
        AppDIContainer.shared.resolve(Logger.self)?.log("StockDetails coordinating to \(path)")

        viewModel?.configure(path)
    }
}
