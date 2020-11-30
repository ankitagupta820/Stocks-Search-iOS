//
//  StocksApp.swift
//  Stocks
//
//  Created by Ankita Gupta on 25/11/20.
//

import SwiftUI

@main
struct StocksApp: App {
  
    @ObservedObject var Portfolio: PortfolioVM = PortfolioVM()
    @State var isLoading: Bool = true
    var body: some Scene{
        
            WindowGroup {
                PortfolioView(Portfolio: Portfolio)
            }
    }
}
