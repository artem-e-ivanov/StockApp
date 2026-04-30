//
//  RootCoordinator.swift
//  StockApp
//
//  Created by developer on 1/4/26.
//

import SwiftUI

// Privides top level coordination. Can be used for main screen feature switching using tab bar ot menu.
@MainActor
final class RootCoordinator: Coordinator {
    var path: Binding<StockAppPath>

    var parent: (any Coordinator)? = nil
    private(set) var children: [any Coordinator] = []

    init(path: Binding<StockAppPath>) {
        self.path = path
        if let stockListCoordinator = AppDIContainer.shared.resolve(FeatureModulesProvider.self)?.getFeature(feature: .stockList)?.makeCoordinator(path: path) {
            children.append(stockListCoordinator)
            stockListCoordinator.parent = self
        }
    }
    
    @ViewBuilder func buildView() -> some View {
        NavigationStack(path: path.path) {
            Color.clear
                .navigationDestination(for: String.self) { _ in
                    self.currentView()
                        .navigationBarBackButtonHidden(self.path.path.count == 1)
                }
        }
    }

    func canCoordinate(for item: String) -> Bool {
        true
    }
    
    private func coordinatorForPath(_ coordinator: any Coordinator) -> (any Coordinator)? {
        let level = coordinator.level
        let count = path.wrappedValue.path.count

        guard count > level else {
            return nil
        }
        
        let pathItem = path.wrappedValue.path[level]
        guard let child = coordinator.children.first(where: { $0.canCoordinate(for: pathItem) }) else {
            return nil
        }

        // Check that the child and the path are on the same level
        if child.level == count {
            return child
        }

        return coordinatorForPath(child)
    }

    @ViewBuilder private func currentView() -> some View {
        let coordinator = coordinatorForPath(self)

        if let coordinator = coordinator as? StockListCoordinator {
            coordinator.buildView()
        } else if let coordinator = coordinator as? StockDetailsCoordinator {
            coordinator.buildView()
        }
    }
}

