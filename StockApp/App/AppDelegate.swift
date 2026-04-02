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
    @Published private(set) var startupState: AppStartupState = .configuring
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        setup()
        
        return true
    }
    
    private func setup() {
        Task { [weak self] in
            // Setup stock provider
            let stockProvider = StockProviderMock()
            _ = AppDIContainer.shared.register(StockProvider.self) { _ in
                stockProvider
            }

            // Setup features provider and start it
            let featureProvider = StockFeatureProvider()
            _ = AppDIContainer.shared.register(FeatureProvider.self) { _ in
                featureProvider
            }
            self?.startupState = .loadingFeatures(false)
            await featureProvider.start()
            self?.startupState = .loadingFeatures(true)

            // App startup is completed
            self?.startupState = .ready
        }
    }
}

