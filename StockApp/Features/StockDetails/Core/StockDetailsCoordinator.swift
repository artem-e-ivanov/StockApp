//
//  StockDetailsCoordinator.swift
//  StockApp
//
//  Created by developer on 1/4/26.
//

import UIKit
import SwiftUI

final class StockDetailsCoordinator: Coordinator {
    var path: Binding<StockAppPath>

    var parent: (any Coordinator)? = nil
    private(set) var children: [any Coordinator] = []
    
    init(path: Binding<StockAppPath>) {
        self.path = path
    }
    
    @ViewBuilder func buildView() -> some View {
        let stockSymbol = path.wrappedValue.path.last?.components(separatedBy: "=").last ?? ""
        StockDetailsView(stockSymbol: stockSymbol)
    }
    
    func canCoordinate(for item: String) -> Bool {
        item.hasPrefix(Feature.stockDetails.rawValue)
    }
}

struct StockDetailsView: UIViewControllerRepresentable {
    var stockSymbol: String
    @State var viewModel: StockDetailsViewModel = StockDetailsViewModel()

    func makeUIViewController(context: Context) -> some UIViewController {
        viewModel.configure(context.coordinator)
        return StockDetailsViewController(viewModel: viewModel)
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
    }
    
    func makeCoordinator() -> String {
        stockSymbol
    }
}
