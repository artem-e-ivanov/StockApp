//
//  FeatureModule.swift
//  StockApp
//
//  Created by developer on 1/4/26.
//

protocol FeatureModule {
    var feature: Feature { get }
    func makeCoordinator() -> Coordinator
}
