//
//  FeatureModule.swift
//  StockApp
//
//  Created by developer on 1/4/26.
//

import SwiftUI

protocol FeatureModule {
    var feature: Feature { get }
    func makeCoordinator(path: Binding<StockAppPath>) -> any Coordinator
}
