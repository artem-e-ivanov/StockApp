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
        
        let splashViewController = UIStoryboard(name: "LaunchScreen", bundle: nil).instantiateInitialViewController()

        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = splashViewController
        window?.makeKeyAndVisible()

        appDelegate.$startupState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                guard case .ready = state else { return }
                
                self?.startRootCordinator()
            }.store(in: &bag)
    }
    
    func startRootCordinator() {
        rootCoordinator = RootCoordinator()
        rootCoordinator?.start()
        rootCoordinator?.coordinate(with: Feature.stockList.rawValue)

        window?.rootViewController = rootCoordinator?.viewController
    }
}

