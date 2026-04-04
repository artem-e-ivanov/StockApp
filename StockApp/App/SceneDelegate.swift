//
//  SceneDelegate.swift
//  StockApp
//
//  Created by developer on 1/4/26.
//

import UIKit
import Combine

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    private(set) var rootCoordinator: Coordinator?
    var window: UIWindow?
    private var bag = Set<AnyCancellable>()

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
              let windowScene = scene as? UIWindowScene else {
            return
        }
        
        // Display splash screen again in order to wit for the app's configuration
        // and startup routines to complete their async operations.
        let splashViewController = UIStoryboard(name: "LaunchScreen", bundle: nil).instantiateInitialViewController()

        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = splashViewController
        window?.makeKeyAndVisible()

        // Wait for the startup to complete and start the root coordinator.
        appDelegate.$startupState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                guard case .ready = state else { return }
                
                self?.startRootCordinator()
            }.store(in: &bag)
    }
    
    func startRootCordinator() {
        AppDIContainer.shared.resolve(Logger.self)?.log("Starting root coordinator")
        
        rootCoordinator = RootCoordinator()
        rootCoordinator?.start()
        rootCoordinator?.coordinate(with: Feature.stockList.rawValue)

        window?.rootViewController = rootCoordinator?.viewController
    }
}

