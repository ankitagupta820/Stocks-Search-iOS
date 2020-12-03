import Foundation
import SwiftyJSON
import Alamofire

class DetailVM: ObservableObject {
    
    let ticker: String
    @Published var Highlights: Highlight
    @Published var NewsItems: [News]
    @Published var Stats: Stat
    @Published var Abouts: About
    @Published var Owned: Float
    @Published var isOwned: Bool
    
    @Published var isLoading: Bool = true

    
    init(ticker: String){
        self.ticker = ticker
        self.Highlights = Highlight(ticker : "Ticker",name: "Company Name",last: 0.00,change: 0.00)
        self.Abouts = About(description: "Description")
        self.Stats = Stat(last: 0.0, open: 0.0, high: 0.0, low: 0.0, mid: 0.0, volume: 0, bidPrice: 0.0)
        self.NewsItems = [News(title: "Title", imgURL: "url", source: "source", URL: "url", content: "Content", publishedAt: "December 3, 2020")]
        self.Owned = 0.0
        self.isOwned = false
    
    }
    
    func getOwnedStocks(){
        
        let Purchases:[String: [String: Any]] = DefaultsStorage.getPurchases()
        
        if let stock: [String: Any] = Purchases[self.ticker]{
            self.Owned = stock["qty"] as! Float
            self.isOwned = true
            
        }else{
            self.Owned = 0.0
            self.isOwned = false
        }
    }
    
    func fetchHighlight(){
        
        let url: String = Constants.Host+"highlights/"+self.ticker
        AF.request(url, encoding:JSONEncoding.default).responseJSON { response in
            switch response.result{
            case .success(let value):
                let json = JSON(value)

                    self.Highlights = Highlight(
                    ticker : json["ticker"].stringValue,
                    name: json["name"].stringValue,
                    last: json["last"].floatValue,
                    change: json["change"].floatValue
                    )
                
                debugPrint("Highlights fetched!")
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func fetchStats(){
        
        let url: String = Constants.Host+"summary/"+self.ticker
        AF.request(url, encoding:JSONEncoding.default).responseJSON { response in
            switch response.result{
            case .success(let value):
                let json = JSON(value)

                    self.Stats = Stat(
                        last: json["last"].floatValue,
                        open: json["open"].floatValue,
                        high: json["high"].floatValue,
                        low: json["low"].floatValue,
                        mid: json["mid"].floatValue,
                        volume: json["volume"].intValue,
                        bidPrice: json["bidPrice"].floatValue
                    )
                
                debugPrint("Stats fetched!")
                
            case .failure(let error):
                print(error)
            }
        }
    }

    func fetchAbout(){
        
        let url: String = Constants.Host+"summary/company/"+self.ticker
        AF.request(url, encoding:JSONEncoding.default).responseJSON { response in
            switch response.result{
            case .success(let value):
                let json = JSON(value)
                self.Abouts = About(
                    description: json["description"].stringValue
                )
                debugPrint("About fetched!")
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func fetchNews(){
        
        let url: String = Constants.Host+"news/"+self.ticker
        AF.request(url, encoding:JSONEncoding.default).responseJSON { response in
            switch response.result{
            case .success(let value):
                let json = JSON(value)

                var NewsPieces: [News] = []
                for item in json.arrayValue {
                    let newsObj = News(
                        title: item["title"].stringValue,
                        imgURL: item["urlToImage"].stringValue,
                        source: item["source"]["name"].stringValue,
                        URL: item["url"].stringValue,
                        content: item["content"].stringValue,
                        publishedAt: item["publishedAt"].stringValue
                    )
                    NewsPieces.append(newsObj)
                }
                self.NewsItems=NewsPieces
                self.isLoading = false
                debugPrint("News fetched!")
                
            case .failure(let error):
                print(error)
            }
        }
    }

}


struct Highlight{
    
    var ticker: String
    var name: String
    var last: Float
    var change: Float
}

struct Stat{
    
    var last: Float
    var open: Float
    var high: Float
    var low: Float
    var mid: Float
    var volume: Int
    var bidPrice: Float
    
}

struct About{
    
    var description: String
}

struct News: Identifiable{
    
    var id = UUID()
    var title: String
    var imgURL: String
    var source: String
    var URL: String
    var content: String
    var publishedAt: String
    
}





