//
//  StockListFeature.swift
//  StockApp
//
//  Created by developer on 1/4/26.
//


final class StockListFeature: Feature {
    func makeCoordinator() -> any Coordinator {
        StockListCoordinator()
    }
}
