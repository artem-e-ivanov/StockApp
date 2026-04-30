//
//  FeatureModulesProvider.swift
//  StockApp
//
//  Created by developer on 1/4/26.
//

protocol FeatureModulesProvider {
    func start() async
    func getFeatureModules() -> [FeatureModule]
    func getFeature(feature: Feature) -> FeatureModule?
}
