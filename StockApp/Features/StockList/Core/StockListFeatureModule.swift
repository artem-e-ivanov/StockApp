//
//  StockListFeatureModule.swift
//  StockApp
//
//  Created by developer on 1/4/26.
//


final class StockListFeatureModule: FeatureModule {
    var feature: Feature { .stockList }
    
    func makeCoordinator() -> any Coordinator {
        AppDIContainer.shared.resolve(Logger.self)?.log("StockList feature activated")

        return StockListCoordinator()
    }
}
