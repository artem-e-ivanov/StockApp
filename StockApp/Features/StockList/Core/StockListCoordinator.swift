//
//  StockListCoordinator.swift
//  StockApp
//
//  Created by developer on 1/4/26.
//

import UIKit

final class StockListCoordinator: Coordinator {
    let route = Features.stockList.rawValue
    var viewController: UIViewController?
    
    func start() {
        viewController = StockListViewController(viewModel: StockListViewModel())
    }
    
    func coordinate(with path: String) {

    }
}

