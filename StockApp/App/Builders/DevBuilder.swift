//
//  DevBuilder.swift
//  StockApp
//
//  Created by developer on 1/4/26.
//

class DevBuilder: AppBuilder {
    func build() async {
        // Create an outer instance and retain it to make it a singleton
        // Setup stock provider mock
        let stockProviderMock = StockProviderMock()
        _ = AppDIContainer.shared.register(StockProvider.self) { _ in
            stockProviderMock
        }

        let featureModulesProvider = StockFeatureModulesProvider()
        _ = AppDIContainer.shared.register(FeatureModulesProvider.self) { _ in
            featureModulesProvider
        }

        await featureModulesProvider.start()
    }
}

