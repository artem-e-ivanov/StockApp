//
//  AppDIContainer.swift
//  StockApp
//
//  Created by developer on 1/4/26.
//

import Swinject

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

