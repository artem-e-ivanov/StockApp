//
//  StockListCell.swift
//  StockApp
//
//  Created by developer on 1/4/26.
//

import SwiftUI

struct StockListCell: View {
    var stock: Stock
    
    var body: some View {
        GridRow {
            Text(stock.symbol)
                .foregroundStyle(Color.gray)
                .font(.system(size: 25, weight: .bold))
                .gridColumnAlignment(.leading)
            Spacer()
            Text(stock.price.formatted(.number.precision(.fractionLength(2))))
                .foregroundStyle(Color.gray)
                .font(.system(size: 20))
            Text(stock.change.formatted(.number.precision(.fractionLength(2))))
                .foregroundStyle(changeColor(stock.change))
                .font(.system(size: 20))
                .gridColumnAlignment(.trailing)
        }
    }
    
    private func changeColor(_ change: Double) -> Color {
        if change > 0 {
            .green
        } else if change < 0 {
            .red
        } else {
            .gray
        }
    }
}
