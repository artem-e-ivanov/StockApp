//
//  StockListFeatureModule.swift
//  StockApp
//
//  Created by developer on 1/4/26.
//

import SwiftUI

final class StockListFeatureModule: FeatureModule {
    var feature: Feature { .stockList }
    
    func makeCoordinator(path: Binding<StockAppPath>) -> any Coordinator {
        AppDIContainer.shared.resolve(Logger.self)?.log("StockList feature activated")

        return StockListCoordinator(path: path)
    }
}
