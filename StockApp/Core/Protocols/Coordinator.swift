//
//  Coordinator.swift
//  StockApp
//
//  Created by developer on 1/4/26.
//

import SwiftUI
import Observation

// Provides visual presentation of UI elements and coordination with provided path.
protocol Coordinator: Observable, AnyObject {
    associatedtype CoordinatorView: View

    init(path: Binding<StockAppPath>)

    var path: Binding<StockAppPath> { get }
    
    var parent: (any Coordinator)? { get set }
    var children: [any Coordinator] { get }
    
    @ViewBuilder func buildView() -> CoordinatorView

    func canCoordinate(for item: String) -> Bool
}

extension Coordinator {
    var level: Int {
        var coordinator: (any Coordinator)? = parent
        var level = 0
        while coordinator != nil {
            level += 1
            coordinator = coordinator?.parent
        }
        return level
    }
}
