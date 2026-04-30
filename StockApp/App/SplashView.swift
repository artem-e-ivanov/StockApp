//
//  SplashView.swift
//  StockApp
//
//  Created by developer on 1/4/26.
//

import SwiftUI

struct SplashView: View {
    var body: some View {
        VStack {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .resizable()
                .tint(.black)
                .scaledToFit()
                .frame(width: 64, height: 64)
                .offset(y: -14)
                .overlay {
                    ProgressView("")
                        .progressViewStyle(CircularProgressViewStyle())
                        .offset(y: 40)
                }
        }
    }
}

