//
//  TradeSheet.swift
//  Stocks
//
//  Created by Ankita Gupta on 30/11/20.
//

import Foundation
import SwiftUI

struct TradeSheet: View {
    
    
    @State var showCurrentSheet: Bool = true
    @Binding var showTradeSheet: Bool
    @ObservedObject var PortfolioVM: PortfolioVM
    @ObservedObject var DetailVM: DetailVM
    
    @State var shares: String = ""
    @State var Message: String = "Default Message"
    
    @State var showToast:Bool = false
    @State var ToastMessage:String = ""
    
    
    var body: some View {
        
        if showCurrentSheet {
            VStack(){
                //Cross button
                VStack(alignment: .leading){
                    HStack(alignment: .top){
                        Button(action: {
                            self.showTradeSheet = false
                        }) {
                            Image(systemName: "xmark")
                        }.buttonStyle(PlainButtonStyle())
                        Spacer()
                    }.offset(y: 0).padding()
                }
                
                //heading text
                Text("Trade \(DetailVM.Highlights.name) shares").bold()
            
        
                Spacer()
                HStack(){
                    TextField("0", text: $shares).font(.system(size: 100.0)).keyboardType(.decimalPad)
                    Text(Float(shares) ?? 0 > 1 ? "shares" : "share").font(.system(size: 50.0))
                }
                let price:Float = DetailVM.Highlights.last
                let qty:Float = Float(shares) ?? 0.0
                let total:Float = qty*price
                HStack(){
                    Spacer()
                    Text("x $\(DetailVM.Highlights.last, specifier:"%.2f")/share = $\(total, specifier:"%.2f")")
                }
                
                Spacer()
                Text("$\(PortfolioVM.Balance, specifier:"%.2f") available to buy \(DetailVM.ticker)").foregroundColor(.secondary).font(.system(size: 15))
                HStack{
                    Button(action: {
                        
                        if let qty = Float(shares) {
                            
                            let price:Float = DetailVM.Highlights.last
                            let total:Float = qty*price
                            
                            if(qty == 0.0 || qty < 0.0){
                                self.ToastMessage = "Cannot buy less than 0 share"
                                self.showToast = true
                            }else if (total > PortfolioVM.Balance){
                                self.ToastMessage = "Not enough money to buy"
                                self.showToast = true
                            }else{
                                PortfolioVM.buyStock(ticker: DetailVM.ticker, name: DetailVM.Highlights.name, qty: Float(shares) ?? 0.0, price: price)
                                DetailVM.getOwnedStocks()
                                self.Message = "You have successfully bought \(qty) shares of \(DetailVM.ticker)"
                                self.showCurrentSheet = false
                            }
                        }else {
                            self.ToastMessage = "Please enter a valid amount"
                            self.showToast=true
                        }
                    }){
                            Text("Buy").frame(width: 130)
                                .padding()
                                .foregroundColor(.white)
                                .background(Color.green)
                                .cornerRadius(30)
                    }
                    
                    Button(action: {
                        
                        if let qty = Float(shares) {
                            
                            if(qty == 0.0 || qty < 0.0){
                                self.ToastMessage = "Cannot sell less than 0 share"
                                self.showToast = true
                            }else if (DetailVM.Owned < qty){
                                self.ToastMessage = "Not enough shares to sell"
                                self.showToast = true
                            }else{
                                PortfolioVM.sellStock(ticker: DetailVM.ticker, qty: Float(shares) ?? 0.0, price: DetailVM.Highlights.last)
                                DetailVM.getOwnedStocks()
                                self.Message = "You have successfully sold \(qty) shares of \(DetailVM.ticker)"
                                self.showCurrentSheet = false
                            }
                        }else {
                            self.ToastMessage = "Please enter a valid amount"
                            self.showToast = true
                        }
                        
                    }){
                            Text("Sell").frame(width: 130)
                                .padding()
                                .foregroundColor(.white)
                                .background(Color.green)
                                .cornerRadius(30)
                    }
                    
                }
                
            } .padding()
            .toast(isPresented: self.$showToast) {
            HStack {
                Text(self.ToastMessage)
            }
        }
        }else{

            VStack(alignment: .center){
                Spacer()
                Text("Congratulations!").font(.system(size: 40)).bold()
                Text(self.Message)
                Spacer()
                Button(action: {
                    self.showTradeSheet = false
                }){
                    Text("Done").frame(width: 200)
                        .padding()
                        .foregroundColor(.green)
                        .background(Color.white)
                        .cornerRadius(30)
                }
            }
            .padding()
            .foregroundColor(.white)
            .background(Color.green)
            
           
        }
        
        
      
    }
   
}
