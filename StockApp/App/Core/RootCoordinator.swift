//
//  RootCoordinator.swift
//  StockApp
//
//  Created by developer on 1/4/26.
//

import UIKit

final class RootCoordinator: Coordinator {
    let route = ""
    var viewController: UIViewController? {
        navController
    }

    private var navController: UINavigationController?
    private var coordinators = [Coordinator]()
    
    func start() {
        navController = UINavigationController()
        
        if let featureModulesProvider = AppDIContainer.shared.resolve(FeatureModulesProvider.self) {
            coordinators.append(contentsOf: featureModulesProvider.getFeatureModules().map({
                $0.makeCoordinator()
            }))
        }
    }
    
    func coordinate(with path: String) {
        let routes = path.components(separatedBy: "/")
        let remainingRoutes = routes.dropFirst()

        guard let firstRoute = routes.first,
              let coordinator = coordinators.first(where: { $0.route == firstRoute }) else {
            return
        }
        
        coordinator.start()
        guard let coordinatorViewController = coordinator.viewController else { return }

        navController?.setViewControllers([coordinatorViewController], animated: false)

        coordinator.coordinate(with: remainingRoutes.joined(separator: "/"))
    }
}

