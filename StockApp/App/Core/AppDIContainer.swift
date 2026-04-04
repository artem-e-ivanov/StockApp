//
//  AppDIContainer.swift
//  StockApp
//
//  Created by developer on 1/4/26.
//

import Swinject

// Provides dependency registration and resolving over Swinject.
// Implements shared (singletone) container.
// Swinject's inObjectScope was not used because shared instance allow more precise control and single point of entry.
nonisolated final class AppDIContainer {
    static let shared = AppDIContainer()
    private let container = Container()
    
    public func register<Service>(
        _ serviceType: Service.Type,
        factory: @escaping (Resolver) -> Service
    ) -> ServiceEntry<Service> {
        container.register(serviceType, factory: factory)
    }
    
    public func resolve<Service>(_ serviceType: Service.Type) -> Service? {
        container.resolve(serviceType)
    }
}

