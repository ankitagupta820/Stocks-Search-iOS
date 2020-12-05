//
//  PortfolioVM.swift
//  Stocks
//
//  Created by Ankita Gupta on 29/11/20.
//

import Foundation
import SwiftyJSON
import Alamofire

class PortfolioVM: ObservableObject {
    
    @Published var BookMarkState: [String]
    @Published var BookMarks: [String: String]
    @Published var PurchasesState: [String]
    @Published var Purchases: [String: [String: Any]]
    @Published var NetWorth: Float
    @Published var Balance: Float
    
    @Published var PortfolioData: [String: portfolio]
    @Published var autoComplete: [String: String]
    @Published var isLoading: Bool
 

    
    init(){
        
        self.BookMarkState = DefaultsStorage.getBookMarkStateArray()
        self.BookMarks =  DefaultsStorage.getBookMarks()
        self.PurchasesState = DefaultsStorage.getPurchasesStateArray()
        self.Purchases = DefaultsStorage.getPurchases()
        self.Balance = DefaultsStorage.getBalance()
        
        self.isLoading=true
        self.PortfolioData = ["ticker" : portfolio(ticker: "ticker", last: 0.0, change: 0.0)]
        self.autoComplete=[:]
        self.NetWorth = 0.0
       
    
    }
    
    func fetchPortfolio(){
        
        self.BookMarkState = DefaultsStorage.getBookMarkStateArray()
        self.BookMarks =  DefaultsStorage.getBookMarks()
        self.PurchasesState = DefaultsStorage.getPurchasesStateArray()
        self.Purchases = DefaultsStorage.getPurchases()
        self.Balance = DefaultsStorage.getBalance()
        
        let set = Set(self.BookMarkState)
        let tickers = set.union(self.PurchasesState)
        let tickerString = tickers.joined(separator: ",")
     
        let url: String = Constants.Host+"portfolio?tickers="+tickerString
        AF.request(url, encoding:JSONEncoding.default).validate().responseJSON { response in
            switch response.result{
            case .success(let value):
                let json = JSON(value)

                var PortfoliosDict: [String: portfolio] = [:]
                for item in json.arrayValue {
                    let portfolioObj = portfolio(
                        ticker: item["ticker"].stringValue,
                        last: item["last"].floatValue,
                        change: item["change"].floatValue
                    )
                    PortfoliosDict[item["ticker"].stringValue] = portfolioObj
                }
                self.PortfolioData=PortfoliosDict
                self.calculateNetWorth()
                self.isLoading=false
                debugPrint("Portfolio data fetched!")
                debugPrint(self.PortfolioData)
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func calculateNetWorth(){
        
        let Balance:Float = DefaultsStorage.getBalance()
        
        var Holdings:Float = 0.0
        for stock in self.Purchases.keys {
            
            let stockData: portfolio = self.PortfolioData[stock] ?? portfolio(ticker: "", last: 0.0, change: 0.0)
            let currentPrice: Float = stockData.last
            let qty: Float = self.Purchases[stock]?["qty"] as! Float
            Holdings = Holdings + (currentPrice*qty)
            
        }
        
        self.NetWorth = Holdings+Balance
        
    }
    
    func fetchAutoComplete(keywork: String){
        
        let url: String = Constants.Host+"autocomplete?tickers="+keywork
        AF.request(url, encoding:JSONEncoding.default).validate().responseJSON { response in
            switch response.result{
            case .success(let value):
                let json = JSON(value)

                var autocompleteArray: [String: String] = [:]
                for item in json.arrayValue {
                    autocompleteArray[item["ticker"].stringValue] = item["name"].stringValue
                }
                self.autoComplete = autocompleteArray
                debugPrint("Autocomplete data fetched!")
                debugPrint(self.autoComplete)
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    
    func reorder(type: String, source: IndexSet, destination: Int){
        
        DefaultsStorage.reorder(category: type, source: source, destination: destination)
        if(type == "BOOKMARKS_ARRAY"){
            self.BookMarkState = DefaultsStorage.getBookMarkStateArray()
        }else{
            self.PurchasesState = DefaultsStorage.getPurchasesStateArray()
        }
    }
    

    func deleteBookMark(offset: IndexSet){
        
        for eachIndex in offset {
            DefaultsStorage.deleteBookmark(from: eachIndex)
        }
        self.BookMarkState = DefaultsStorage.getBookMarkStateArray()
        self.BookMarks =  DefaultsStorage.getBookMarks()
        
    }
    
    func buyStock(ticker: String, name: String, qty: Float, price: Float){
        
        DefaultsStorage.buy(ticker: ticker, name: name, qty: qty, price: price)
        
        self.PurchasesState = DefaultsStorage.getPurchasesStateArray()
        self.Purchases = DefaultsStorage.getPurchases()
        self.Balance = DefaultsStorage.getBalance()
        self.calculateNetWorth()
     
    }
    
    func sellStock(ticker: String, qty: Float, price: Float){
        
        DefaultsStorage.sell(ticker: ticker, qty: qty, price: price)
        
        self.PurchasesState = DefaultsStorage.getPurchasesStateArray()
        self.Purchases = DefaultsStorage.getPurchases()
        self.Balance = DefaultsStorage.getBalance()
        self.calculateNetWorth()
        
        
    }
}


struct portfolio{
    
    var ticker: String
    var last: Float
    var change: Float
    
}
