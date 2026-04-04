//
//  IntegrationTests.swift
//  StockAppTests
//
//  Created by developer on 4/4/26.
//

import Testing

struct IntegrationTests {
    @Test func testSharedDI() async throws {
        let localContainer = AppDIContainer()
        let sharedContainer = AppDIContainer.shared
        
        let logger1 = AppLogger()
        let logger2 = AppLogger()
        
        _ = localContainer.register(Logger.self) { _ in
            logger1
        }
        _ = sharedContainer.register(Logger.self) { _ in
            logger2
        }
        
        let resolverLogger1 = localContainer.resolve(Logger.self)
        let resolverLogger2 = sharedContainer.resolve(Logger.self)
        
        #expect(resolverLogger1 != nil)
        #expect(resolverLogger2 != nil)
        #expect(resolverLogger1 !== resolverLogger2)
    }
    
    @MainActor @Test func testRootCoordinator() async throws {
        let rootCoordinator = RootCoordinator()
        
        let featureModulesProviderMock = FeatureModulesProviderMock()
        _ = AppDIContainer.shared.register(FeatureModulesProvider.self) { _ in
            featureModulesProviderMock
        }
        
        rootCoordinator.start()
        rootCoordinator.coordinate(with: featureModulesProviderMock.featureModuleMock.coordinatorMock.route)
        
        #expect(featureModulesProviderMock.getFeatureModulesCalled)
        #expect(featureModulesProviderMock.featureModuleMock.makeCoordinatorCalled)
        #expect(featureModulesProviderMock.featureModuleMock.coordinatorMock.startCalled)
        #expect(featureModulesProviderMock.featureModuleMock.coordinatorMock.coordinateCalled == "")
    }
}
