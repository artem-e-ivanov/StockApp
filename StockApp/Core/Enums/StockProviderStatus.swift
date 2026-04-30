//
//  StockProviderStatus.swift
//  StockApp
//
//  Created by developer on 1/4/26.
//

import SwiftUI

nonisolated enum StockProviderStatus {
    case offline
    case connecting
    case online
}

extension StockProviderStatus {
    var color: Color {
        switch self {
            case .offline:
                .gray
            case .connecting:
                .yellow
            case .online:
                .green
        }
    }
}
