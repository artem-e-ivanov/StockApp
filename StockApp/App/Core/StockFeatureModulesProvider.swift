//
//  StockFeatureModulesProvider.swift
//  StockApp
//
//  Created by developer on 1/4/26.
//

// This provider is the source of features.
// It is responsible for getting the configuration locally or from the remote source.
final class StockFeatureModulesProvider: FeatureModulesProvider {
    private var featureModules = [FeatureModule]()
    
    func start() async {
        // IMPROVEMENT: Make a configuration provider as a dependency.

        // Simulates a remote request for features configuration.
        try? await Task.sleep(for: .seconds(1))

        // For the MVP the features are hardcoded.
        let stockListFeatureModule = StockListFeatureModule()
        let stockDetailsFeatureModule = StockDetailsFeatureModule()
        featureModules = [
            stockListFeatureModule,
            stockDetailsFeatureModule
        ]
    }
    
    func getFeatureModules() -> [FeatureModule] {
        return featureModules
    }
}

