//
//  StockFeatureProvider.swift
//  StockApp
//
//  Created by developer on 1/4/26.
//

final class StockFeatureProvider: FeatureProvider {
    private var features = [Feature]()
    
    func start() async {
        try? await Task.sleep(for: .seconds(1))

        let stockListFeature = StockListFeature()
        features = [stockListFeature]
    }
    
    func getFeatures() -> [Feature] {
        return features
    }
}

