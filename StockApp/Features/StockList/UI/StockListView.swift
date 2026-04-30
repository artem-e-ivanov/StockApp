//
//  StockListViewController.swift
//  StockApp
//
//  Created by developer on 1/4/26.
//

import SwiftUI
import Combine



@MainActor
struct StockListView: View {
    @State var viewModel: StockListViewModel
    @State private var sortOrder: StockListSortOrder = .title
    @State private var listPaused: Bool = true
    
    var body: some View {
        TimelineView(.animation) { context in
            List {
                Grid(alignment: .leading, verticalSpacing: 10) {
                    ForEach(viewModel.stockItems, id: \.symbol) { stock in
                        StockListCell(stock: stock)
                            .onTapGesture { _ in
                                viewModel.viewTapsOnStock(stock)
                            }
                    }
                }
                .frame(maxWidth: .infinity)
                .listRowSeparator(.hidden)
            }
            .listStyle(.plain)
            .onChange(of: context.date) { _, _ in
                guard !listPaused else { return }
                
                listPaused = true
                Task {
                    await self.viewModel.viewNeedsData()
                }
            }
            .onChange(of: viewModel.stockItemsVersion) {
                guard listPaused else { return }
                
                listPaused = false
            }
        }.toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Start/stop", systemImage: "power.circle.fill") {
                    self.listPaused = true
                    Task {
                        await self.viewModel.startStopUpdates()
                    }
                }.tint(viewModel.stockProviderStatus.color)
            }
            ToolbarItem(placement: .navigationBarLeading) {
                Picker("Sort order", selection: $sortOrder) {
                    ForEach(StockListSortOrder.allCases, id: \.self) {
                        Text($0.localized)
                    }
                }
                .pickerStyle(.segmented)
                .fixedSize()
                .onChange(of: sortOrder) { _, sortOrder in
                    Task {
                        await self.viewModel.setSortOrder(sortOrder)
                    }
                }
            }
        }.onAppear {
            guard viewModel.stockProviderStatus == .online else { return }
            
            listPaused = false
        }.onDisappear {
            listPaused = true
        }
    }
}
