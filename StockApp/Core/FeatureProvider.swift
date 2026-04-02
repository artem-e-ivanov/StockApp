//
//  FeatureProvider.swift
//  StockApp
//
//  Created by developer on 1/4/26.
//

protocol FeatureProvider {
    func start() async
    func getFeatures() -> [Feature]
}
