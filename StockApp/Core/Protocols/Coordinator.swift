//
//  Coordinator.swift
//  StockApp
//
//  Created by developer on 1/4/26.
//

import UIKit

// Provides visual presentation of UI elements and coordination with provided path.
protocol Coordinator {
    // Represents current segment of a navigation path.
    var route: String { get }
    // Provides visual representation of UI element.
    var viewController: UIViewController? { get }

    // Starts the coordinator's lifecycle.
    func start()
    // Handles a request for presenting new nested UI element.
    func coordinate(with path: String)
}
