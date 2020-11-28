//
//  DefaultsStorage.swift
//  Stocks
//
//  Created by Ankita Gupta on 26/11/20.
//

import Foundation

class DefaultsStorage{
  
    static func initBalance(){
        
        let defaults = UserDefaults.standard
        defaults.set(20000, forKey: "BALANCE")
    }
    
    static func getBalance()->Float{
        
        let defaults = UserDefaults.standard
        return defaults.float(forKey: "BALANCE") as? Float ?? 0.00
        
    }
    
    static func setBalance(value: Float){
        
        let defaults = UserDefaults.standard
        defaults.set(value, forKey: "BALANCE")
        
    }
    
    
    static func getWorth()->Float{
        
        let defaults = UserDefaults.standard
        return defaults.float(forKey: "WORTH") as? Float ?? 0.00
        
        
    }
    
    static func setWorth(value: Float){
        
        let defaults = UserDefaults.standard
        defaults.set(value, forKey: "WORTH")
        
    }
    
    static func setBookmark(ticker: String, name: String) -> Bool{
        
        let defaults = UserDefaults.standard
        var Bookmarks: [String: String] = defaults.dictionary(forKey: "BOOKMARKS") as? [String : String] ?? [:]
        
        Bookmarks[ticker]=name
        defaults.set(Bookmarks, forKey: "BOOKMARKS")
        return true
    }
    
    static func getBookMarks() -> [String: String]{
        
        let defaults = UserDefaults.standard
        let Bookmarks: [String: String] = defaults.dictionary(forKey: "BOOKMARKS") as? [String : String] ?? [:]
        
        return Bookmarks
    }
    static func isBookMarked(ticker: String)-> Bool{
        
        let defaults = UserDefaults.standard
        let Bookmarks: [String: String] = defaults.dictionary(forKey: "BOOKMARKS") as? [String : String] ?? [:]
        
        if Bookmarks[ticker] != nil{
            return true
        }else{
            return false
        }
    }
    

    static func getPortfolio()-> [String: [String: String]]{
        
        let defaults = UserDefaults.standard
        let Portfolio: [String: [String: String]] = defaults.dictionary(forKey: "PORTFOLIO") as? [String: [String: String]] ?? [:]
        
        return Portfolio
    }
    
    static func buy(ticker: String, name: String, qty: Float, price: Float)-> Bool{
        
        let defaults = UserDefaults.standard
        var Portfolio: [String: [String: Any]] = defaults.dictionary(forKey: "PORTFOLIO") as? [String: [String: Any]] ?? [:]
        
        if let stock:[String: Any] = Portfolio[ticker]{
            
            let Quantity:Float = stock["qty"] as! Float + qty
            let Price:Float = stock["price"] as! Float + price*qty
            let Name:String = name
            
            let stock:[String: Any] = ["qty": Quantity, "price": Price, "name": Name]
            Portfolio[ticker] = stock
            
        }else{
            
            let Quantity:Float = qty
            let Price:Float = price*qty
            let Name:String = name
            
            let stock:[String: Any] = ["qty": Quantity, "price": Price, "name": Name]
            Portfolio[ticker] = stock
            
        }
        
        defaults.set(Portfolio, forKey: "PORTFOLIO")
        return true
        
    }
    
    
    static func sell(ticker: String, qty: Float, name: String)->Bool{
        
        let defaults = UserDefaults.standard
        var Portfolio: [String: [String: Any]] = defaults.dictionary(forKey: "PORTFOLIO") as? [String: [String: Any]] ?? [:]
        
        if let stock:[String: Any] = Portfolio[ticker]{
            
            let leftQty = stock["qty"] as! Float - qty
            if leftQty.isZero{
                
                Portfolio.removeValue(forKey: ticker)
            
            }else{
                let Price:Float = stock["price"] as! Float
                let Quantity:Float = stock["qty"] as! Float
                let Avg:Float =  Price / Quantity
                
                let NewQuantity = leftQty
                let NewPrice = Price - qty*Avg
                let Name:String = name
                
                let stock:[String: Any] = ["qty": NewQuantity, "price": NewPrice, "name": Name]
                Portfolio[ticker] = stock
                
            }
            
            defaults.set(Portfolio, forKey: "PORTFOLIO")
            return true
        }
        return false
    }
}
