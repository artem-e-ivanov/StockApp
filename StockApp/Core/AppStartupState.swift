//
//  AppStartupState.swift
//  StockApp
//
//  Created by developer on 1/4/26.
//

// Represents the sequential app's launch state.
enum AppStartupState {
    case configuring
    case loadingFeatures(Bool)
    case ready
}

