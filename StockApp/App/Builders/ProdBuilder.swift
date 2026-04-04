//
//  ProdBuilder.swift
//  StockApp
//
//  Created by developer on 1/4/26.
//

import Foundation

// Configures app's DI with external dependencies.
class ProdBuilder: AppBuilder {
    func build() async {
        // Create an outer instance and retain it to make it a singleton
        // Setup stock provider mock
        if let endpoint = URL(string: "wss://ws.postman-echo.com/raw") {
            let stockProvider = await StockProviderWeb(endpoint: endpoint)
            _ = AppDIContainer.shared.register(StockProvider.self) { _ in
                stockProvider
            }
        }

        let featureModulesProvider = StockFeatureModulesProvider()
        _ = AppDIContainer.shared.register(FeatureModulesProvider.self) { _ in
            featureModulesProvider
        }

        await featureModulesProvider.start()
    }
}

