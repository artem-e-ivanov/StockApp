//
//  AppDelegate.swift
//  StockApp
//
//  Created by developer on 1/4/26.
//

import SwiftUI
import Combine


@Observable
final class StockAppPath {
    var path: [String] = []
}

@Observable
final class StockAppState {
    var startupState: AppStartupState = .none
    var path: StockAppPath = StockAppPath()
    fileprivate var rootCoordinator: RootCoordinator?
}

@main
struct StockApp: App {
    @State private var state: StockAppState = StockAppState()
    
    var body: some Scene {
        WindowGroup {
            if self.state.startupState != .ready {
                SplashView()
                    .task(name: "AppStart", {
                        await self.setup(DevBuilder())
                    })
            } else {
                self.state.rootCoordinator?.buildView()
            }
        }
    }
    
    private func setup(_ builder: AppBuilder) async {
        let appLogger = AppLogger()
        _ = AppDIContainer.shared.register(Logger.self) { _ in
            appLogger
        }

        state.path.path.append(Feature.stockList.rawValue)

        // Simulates fetching a remote app config
        state.startupState = .configuring
        await builder.build()

        state.rootCoordinator = RootCoordinator(path: $state.path)

        state.startupState = .ready
    }
}
