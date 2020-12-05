
import SwiftUI

struct PortfolioView: View {


    //Passed from parent View
    @ObservedObject var PortfolioVM: PortfolioVM
    @State var BookMarkArray: [String] = []
    @State var BookMarks: [String: String] = [:]
    @State var PurchasesArray: [String] = []
    @State var Purchases: [String: [String: Any]] = [:]

    @ObservedObject var searchBar: SearchBar = SearchBar()
    @State var searchText: String = ""
    @Environment(\.openURL) var openURL

    
    init(Portfolio: PortfolioVM){
        self.PortfolioVM=Portfolio
    }
    
    var body: some View {
        
        VStack{
            if !self.PortfolioVM.isLoading {
                NavigationView{
                    VStack{
                        if !searchBar.showResults{
                            Content
                        }else{
                            SearchResults
                        }
                    }
                    .navigationTitle(Text("Stocks"))
                    .toolbar{
                    EditButton()
                    }
                    .add(self.searchBar)
                }.listStyle(PlainListStyle())
             
            }else{
                Loading
            }
            
        }
        .onAppear(
            perform: {
                PortfolioVM.fetchPortfolio()
        })
    }
            
    
var Loading: some View {
    ProgressView("Fetching Data...").progressViewStyle(CircularProgressViewStyle())
}
    

var SearchResults: some View {
        List {
            ForEach(searchBar.Results.filter { searchText.isEmpty || (($0["ticker"]?.localizedStandardContains(searchText)) != nil) || (($0["name"]?.localizedStandardContains(searchText)) != nil)}, id: \.self) { stock in
               
                NavigationLink(destination: DetailView(ticker: stock["ticker"] ?? "AAPL" , PortfolioVM: PortfolioVM, DetailVM: DetailVM(ticker: stock["ticker"] ?? "AAPL"))){
                    VStack(alignment: .leading){
                        Text(stock["ticker"] ?? "Default").bold()
                        Text(stock["name"] ?? "No name").foregroundColor(.secondary)
                    }
                }
            }
        }
    }
    
var Content: some View {
    
    VStack{
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
            }
        }
        
        HStack{
            Spacer()
            Button("Powered by Tingoo") {
                openURL(URL(string: "https://api.tiingo.com/")!)
            }.foregroundColor(.secondary)
            Spacer()
        }
        
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
