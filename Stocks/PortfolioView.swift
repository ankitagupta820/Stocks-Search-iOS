
import SwiftUI

struct PortfolioView: View {

   
    @State var isLoading: Bool = true
    @State var showSearchResults:Bool = false
    //Passed from parent View
    @ObservedObject var PortfolioVM: PortfolioVM
    @State var BookMarkArray: [String] = []
    @State var BookMarks: [String: String] = [:]
    @State var PurchasesArray: [String] = []
    @State var Purchases: [String: [String: Any]] = [:]

    @ObservedObject var searchBar: SearchBar = SearchBar()
    @Environment(\.openURL) var openURL
    
  //  var tickers=["AAPL": "Apple Inc.", "IBM": "International Business", "AMZN": "Amazon"]
    
    init(Portfolio: PortfolioVM){
        
        self.PortfolioVM=Portfolio
        
    }
    
    var body: some View {
        
        if self.PortfolioVM.isLoading {
            
            Loading
            .onAppear(
                perform: {
                    //DefaultsStorage.addDummy()
                    debugPrint("|------Fetching Portfolio data-----|")
                    PortfolioVM.fetchPortfolio()
            })
        }else{
            
//            if !Portfolio.autoComplete.isEmpty{
//                List {
//                    ForEach(
//                        tickers.keys.filter {searchBar.text.isEmpty || $0.localizedStandardContains(searchBar.text)},id: \.self) { stock in
//                        NavigationLink(destination: DetailView(ticker: stock , Portfolio: Portfolio, Data: DetailVM(ticker: stock))){
//                            VStack(alignment: .leading){
//                                Text(stock).bold()
//                                Text(tickers[stock]!).foregroundColor(.secondary)
//                            }
//                        }
//                    }
//                }
//            }
            
            Content
                .onDisappear(perform: {
                    
                })
        }
    }
            
    
var Loading: some View {
    ProgressView("Fetching Data...").progressViewStyle(CircularProgressViewStyle())
}
    
var Content: some View {
    NavigationView{
            List{
                let date: String = getDate()
                Text(date).font(.title).foregroundColor(.secondary).bold()
                
                Section(header: Text("Portfolio")){
                                VStack(alignment: .leading){
                                    Text("Net Worth").font(.title)
                                    Text("\(PortfolioVM.NetWorth, specifier:"%.2f")").font(.title).foregroundColor(.primary).bold()
                                }
                                ForEach(self.PortfolioVM.PurchasesState, id: \.self){ purchase in
                                    let stockDict: [String: Any] = self.PortfolioVM.Purchases[purchase]!
                                    let portfolioDict: portfolio = self.PortfolioVM.PortfolioData[purchase]!
                                    NavigationLink(destination: DetailView(ticker: purchase , PortfolioVM: PortfolioVM, DetailVM: DetailVM(ticker: purchase))){
                                        HStack{
                                            VStack(alignment: .leading){
                                                Text(purchase).font(.title2).bold()
                                                Text(String(format: "%.2f shares", stockDict["qty"] as! Float)).foregroundColor(.secondary)
                                            }
                                            Spacer()
                                            VStack(alignment: .trailing){
                                                Text(String(format: "%.2f", portfolioDict.last)).font(.title2).bold()
                                                HStack{
                                                    Image(systemName: portfolioDict.change < 0 ? "arrow.down.right" : "line.diagonal.arrow" )
                                                    Text(String(format: "%.2f", portfolioDict.change))
                                                }.foregroundColor(portfolioDict.change < 0 ? .red : .green)
                                            }
                                        }
                                    }
                                }.onMove(perform: movePurchase)
                            }

                Section(header: Text("Favorites")){
                    ForEach(self.PortfolioVM.BookMarkState, id: \.self){favourite in
                        
                        let bookmark: String = self.PortfolioVM.BookMarks[favourite]!
                        let portfolioDict: portfolio = self.PortfolioVM.PortfolioData[favourite] ?? portfolio(ticker: "nil", last: 0.00, change: 1.0)
                        let isPurchased:Bool = self.PortfolioVM.PurchasesState.contains(favourite)
                     
                        NavigationLink(destination: DetailView(ticker: favourite, PortfolioVM: PortfolioVM, DetailVM: DetailVM(ticker: favourite))){
                            HStack{
                                VStack(alignment: .leading){
                                    Text(favourite).font(.title2).bold()
                                    if isPurchased{
                                        let purchaseDict: [String: Any] = self.PortfolioVM.Purchases[favourite]!
                                        Text(String(format: "%.2f shares", purchaseDict["qty"] as! Float)).foregroundColor(.secondary)
                                    }else{
                                        Text(bookmark).foregroundColor(.secondary)
                                    }
                                }
                                Spacer()
                                VStack(alignment: .trailing){
                                    Text(String(format: "%.2f", portfolioDict.last)).font(.title2).bold()
                                    HStack{
                                            Image(systemName: portfolioDict.change < 0 ? "arrow.down.right" : "line.diagonal.arrow" )
                                            Text(String(format: "%.2f", portfolioDict.change))
                                        }.foregroundColor(portfolioDict.change < 0 ? .red : .green)
                                    }
                                }
                    }
                    }
                    
                    .onMove(perform:movefavourite)
                    .onDelete(perform: deletefavourite)
                    Spacer()
                }
                HStack{
                    Spacer()
                    Button("Powered by Tingoo") {
                        openURL(URL(string: "https://api.tiingo.com/")!)
                    }.foregroundColor(.secondary)
                    Spacer()
                }
            }
            .navigationTitle(Text("Stocks"))
            .toolbar{
            EditButton()
            }
            .add(self.searchBar)
    }
    
}


func movefavourite(from: IndexSet, to: Int){
    PortfolioVM.reorder(type: "BOOKMARKS_ARRAY", source: from, destination: to )
}
    
func movePurchase(from: IndexSet, to: Int){
    PortfolioVM.reorder(type: "PURCHASES_ARRAY", source: from, destination: to )
}
    
func deletefavourite(offsets: IndexSet){
    self.PortfolioVM.deleteBookMark(offset: offsets)
}

    
func getDate()->String{
    let formatter = DateFormatter()
    formatter.dateStyle = .long
    let datetime = formatter.string(from: Date())
    return datetime
}
    

}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        PortfolioView(Portfolio: PortfolioVM())
    }
}
