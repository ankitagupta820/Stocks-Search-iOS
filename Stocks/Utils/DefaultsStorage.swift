import Foundation

class DefaultsStorage{

    static func addDummy(){
        let defaults = UserDefaults.standard
        let Bookmarks = ["AAPL" : "Apple Inc."]
        let BookmarksArray = ["AAPL"]
   
        defaults.set(Bookmarks, forKey: "BOOKMARKS")
        defaults.set(BookmarksArray, forKey: "BOOKMARKS_ARRAY")
    }
    
  
    // functions on Edit button in portfolio section
    static func reorder(category: String, source: IndexSet, destination: Int){
        
        let defaults = UserDefaults.standard
        var Array: [String] = defaults.array(forKey: category) as? [String] ?? []
        
        Array.move(fromOffsets: source, toOffset: destination)
        
        defaults.set(Array, forKey: category)
        
    }
    
    static func deleteBookmark(from: IndexSet.Element){
        
        let defaults = UserDefaults.standard
        var Array: [String] = defaults.array(forKey: "BOOKMARKS_ARRAY") as? [String] ?? []
        var Bookmarks: [String: String] = defaults.dictionary(forKey: "BOOKMARKS") as? [String : String] ?? [:]
        
        
        let stock = Array.remove(at: from)
        Bookmarks.removeValue(forKey: stock)
        
        defaults.set(Array, forKey: "BOOKMARKS_ARRAY")
        defaults.set(Bookmarks, forKey: "BOOKMARKS")
        
    }
    
    //Bookmarks
    static func getBookMarkStateArray()-> [String]{
        
        let defaults = UserDefaults.standard
        let BookmarkArray: [String] = defaults.array(forKey: "BOOKMARKS_ARRAY") as? [String] ?? []
        
        return BookmarkArray
        
    }
    
    static func getBookMarks() -> [String: String]{
        
        let defaults = UserDefaults.standard
        let Bookmarks: [String: String] = defaults.dictionary(forKey: "BOOKMARKS") as? [String : String] ?? [:]
        
        return Bookmarks
    }
    
    static func isBookMarked(ticker: String)-> Bool{
        
        let defaults = UserDefaults.standard
        let Bookmarks: [String] = defaults.array(forKey: "BOOKMARKS_ARRAY") as? [String] ?? []
        
        if Bookmarks.contains(ticker){
            return true
        }else{
            return false
        }
    }
    
    static func toggleBookmark(ticker: String, name: String){
        
        let defaults = UserDefaults.standard
        var Bookmarks: [String: String] = defaults.dictionary(forKey: "BOOKMARKS") as? [String : String] ?? [:]
        var BookmarksArray: [String] = defaults.array(forKey: "BOOKMARKS_ARRAY" ) as? [String] ?? []
        
        if BookmarksArray.contains(ticker){
            Bookmarks.removeValue(forKey: ticker)
            if let index = BookmarksArray.firstIndex(of: ticker) {
                BookmarksArray.remove(at: index)
            }
        }else{
            Bookmarks[ticker]=name
            BookmarksArray.append(ticker)
        }
   
        defaults.set(Bookmarks, forKey: "BOOKMARKS")
        defaults.set(BookmarksArray, forKey: "BOOKMARKS_ARRAY")
    }
    
 
    

    
    
    
    
    static func initBalance(){
        
        let defaults = UserDefaults.standard
        defaults.set(20000, forKey: "BALANCE")
    }
    
    static func getBalance()->Float{
        
        let defaults = UserDefaults.standard
        return defaults.float(forKey: "BALANCE")
        
    }
    
    static func setBalance(value: Float){
        
        let defaults = UserDefaults.standard
        defaults.set(value, forKey: "BALANCE")
        
    }
    
    
    static func getWorth()->Float{
        
        let defaults = UserDefaults.standard
        return defaults.float(forKey: "WORTH") 
        
        
    }
    
    static func setWorth(value: Float){
        
        let defaults = UserDefaults.standard
        defaults.set(value, forKey: "WORTH")
        
    }
    
    
    
    //Portfolio
    static func getPurchases()-> [String: [String: String]]{
        
        let defaults = UserDefaults.standard
        let Portfolio: [String: [String: String]] = defaults.dictionary(forKey: "PURCHASES") as? [String: [String: String]] ?? [:]
        
        return Portfolio
    }
    
    static func getPurchasesStateArray()->[String]{
        
        let defaults = UserDefaults.standard
        let purchasesState: [String] = defaults.array(forKey: "PURCHASES_ARRAY") as? [String] ?? []
        
        return purchasesState
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
