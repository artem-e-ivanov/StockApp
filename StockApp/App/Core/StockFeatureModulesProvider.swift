//
//  StockFeatureModulesProvider.swift
//  StockApp
//
//  Created by developer on 1/4/26.
//

final class StockFeatureModulesProvider: FeatureModulesProvider {
    private var featureModules = [FeatureModule]()
    
    func start() async {
        try? await Task.sleep(for: .seconds(1))

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

