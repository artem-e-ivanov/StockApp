//
//  IntegrationMocks.swift
//  StockAppTests
//
//  Created by developer on 4/4/26.
//

import UIKit
import Combine

final class CoordinatorMock: Coordinator {
    var route: String { "route" }
    var startCalled = false
    var coordinateCalled: String? = nil
    
    var viewController: UIViewController? = UIViewController()
    
    func start() {
        startCalled = true
    }
    
    func coordinate(with path: String) {
        coordinateCalled = path
    }
}

final class FeatureModuleMock: FeatureModule {
    var feature: Feature { .stockList }
    
    var makeCoordinatorCalled = false
    let coordinatorMock = CoordinatorMock()
    
    func makeCoordinator() -> any Coordinator {
        makeCoordinatorCalled = true
        return coordinatorMock
    }
}

final class FeatureModulesProviderMock: FeatureModulesProvider {
    var getFeatureModulesCalled = false
    let featureModuleMock = FeatureModuleMock()
    
    func start() async {}
    
    func getFeatureModules() -> [any FeatureModule] {
        getFeatureModulesCalled = true
        return [featureModuleMock]
    }
}

actor StockProviderMock: StockProvider {
    var status: AnyPublisher<StockProviderStatus, Never> { $_status.eraseToAnyPublisher() }
    @Published private var _status: StockProviderStatus = .offline
    
    var stock1 = Stock(symbol: "A", price: 1, change: 1)
    var stock2 = Stock(symbol: "B", price: 2, change: -1)
    var getCalled = false

    func start() async {
        _status = .online
    }
    
    func stop() async {
        _status = .offline
    }
    
    func get() async -> [Stock] {
        getCalled = true
        return [stock1, stock2]
    }
    
    func get(symbol: String) async -> Stock? {
        nil
    }
}
