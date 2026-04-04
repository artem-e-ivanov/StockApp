//
//  AppDelegate.swift
//  StockApp
//
//  Created by developer on 1/4/26.
//

import UIKit
import Combine

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    @Published private(set) var startupState: AppStartupState = .none {
        didSet {
            AppDIContainer.shared.resolve(Logger.self)?.log("App startup state \(startupState)")
        }
    }
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        setup(ProdBuilder())
        return true
    }
    
    private func setup(_ builder: AppBuilder) {
        let appLogger = AppLogger()
        _ = AppDIContainer.shared.register(Logger.self) { _ in
            appLogger
        }

        Task { [weak self] in
            self?.startupState = .configuring
            await builder.build()
            self?.startupState = .ready
        }
    }
}

