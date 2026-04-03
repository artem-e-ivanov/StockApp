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
            // Create an outer instance and retain it to make it a singleton

            // Setup stock provider mock
            /*let stockProviderMock = StockProviderMock()
            _ = AppDIContainer.shared.register(StockProvider.self) { _ in
                stockProviderMock
            }*/
            
            // Setup stock provider from web
            if let endpoint = URL(string: "wss://ws.postman-echo.com/raw") {
                let stockProvider = await StockProviderWeb(endpoint: endpoint)
                _ = AppDIContainer.shared.register(StockProvider.self) { _ in
                    stockProvider
                }
            }

            // Setup features provider and start it
            let featureModulesProvider = StockFeatureModulesProvider()
            _ = AppDIContainer.shared.register(FeatureModulesProvider.self) { _ in
                featureModulesProvider
            }
            self?.startupState = .loadingFeatures(false)
            await featureModulesProvider.start()
            self?.startupState = .loadingFeatures(true)

            // App startup is completed
            self?.startupState = .ready
        }
    }
}

