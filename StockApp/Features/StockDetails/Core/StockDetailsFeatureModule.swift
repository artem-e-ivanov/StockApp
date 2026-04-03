//
//  StockDetailsFeatureModule.swift
//  StockApp
//
//  Created by developer on 1/4/26.
//


final class StockDetailsFeatureModule: FeatureModule {
    var feature: Feature { .stockDetails }
    
    func makeCoordinator() -> any Coordinator {
        StockDetailsCoordinator()
    }
}
