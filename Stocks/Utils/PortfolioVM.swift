//
//  PortfolioVM.swift
//  Stocks
//
//  Created by Ankita Gupta on 29/11/20.
//

import Foundation
import Foundation
import SwiftyJSON
import Alamofire

class PortfolioVM: ObservableObject {
    
    @Published var BookMarkState: [String]
    @Published var BookMarks: [String: String]
    @Published var PurchasesState: [String]
    @Published var Purchases: [String: [String: Any]]
    
    @Published var PortfolioData: [String: portfolio]
    @Published var isLoading: Bool

    
    init(){
        
        self.BookMarkState = DefaultsStorage.getBookMarkStateArray()
        self.BookMarks =  DefaultsStorage.getBookMarks()
        self.PurchasesState = DefaultsStorage.getPurchasesStateArray()
        self.Purchases = DefaultsStorage.getPurchases()
        self.isLoading=true
        self.PortfolioData = ["ticker" : portfolio(ticker: "ticker", last: 0.0, change: 0.0)]
    
    }
    
    func fetchPortfolio(){
        
        self.BookMarkState = DefaultsStorage.getBookMarkStateArray()
        self.BookMarks =  DefaultsStorage.getBookMarks()
        self.PurchasesState = DefaultsStorage.getPurchasesStateArray()
        self.Purchases = DefaultsStorage.getPurchases()
        
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
                self.isLoading=false
                debugPrint("Portfolio data fetched!")
                debugPrint(self.PortfolioData)
                
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
}


struct portfolio{
    
    var ticker: String
    var last: Float
    var change: Float
    
}
