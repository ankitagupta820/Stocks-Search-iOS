
import SwiftUI

struct PortfolioView: View {

    @State var isLoading: Bool = true
    //Passed from parent View
    @ObservedObject var Portfolio: PortfolioVM
    @State var BookMarkArray: [String] = []
    @State var BookMarks: [String: String] = [:]
    @State var PurchasesArray: [String] = []
    @State var Purchases: [String: [String: Any]] = [:]

    @ObservedObject var searchBar: SearchBar = SearchBar()
    @State private var isEditable = false
    
    init(Portfolio: PortfolioVM){
        
        self.Portfolio=Portfolio
        debugPrint("Portfolio View init()")
        
    }
    var body: some View {
        
        if self.Portfolio.isLoading {
            Loading
            .onAppear(
                perform: {
                    //DefaultsStorage.addDummy()
                    Portfolio.fetchPortfolio()
                    debugPrint("Portfolio on appear")
            })
        }else{
            Content
            Link("Powered by Tingoo", destination: URL(string: "https://api.tiingo.com/")!)
                .foregroundColor(.secondary)
                .padding()
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
                                Text("271.98").font(.title).foregroundColor(.primary).bold()
                            }
                            ForEach(self.Portfolio.PurchasesState, id: \.self){ purchase in
                                let stockDict: [String: Any] = self.Portfolio.Purchases[purchase]!
                                let portfolioDict: portfolio = self.Portfolio.PortfolioData[purchase]!
                                NavigationLink(destination: DetailView(ticker: purchase , Portfolio: Portfolio, Data: DetailVM(ticker: purchase))){
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
//                            .onLongPressGesture {
//                                            withAnimation {
//                                                self.isEditable = true
//                                            }
//                                        }
                        }

            Section(header: Text("Favorites")){
                ForEach(self.Portfolio.BookMarkState, id: \.self){stock in
                    
                    let bookmark: String = self.Portfolio.BookMarks[stock]!
                    let pDict: portfolio = self.Portfolio.PortfolioData[stock] ?? portfolio(ticker: "nil", last: 0.00, change: 1.0)
                    NavigationLink(destination: DetailView(ticker: stock, Portfolio: Portfolio, Data: DetailVM(ticker: stock))){
                        HStack{
                            VStack(alignment: .leading){
                                Text(stock).font(.title2).bold()
                                Text(bookmark).foregroundColor(.secondary)
                            }
                            Spacer()
                            VStack(alignment: .trailing){
                                Text(String(format: "%.2f", pDict.last)).font(.title2).bold()
                                HStack{
                                        Image(systemName: pDict.change < 0 ? "arrow.down.right" : "line.diagonal.arrow" )
                                        Text(String(format: "%.2f", pDict.change))
                                    }.foregroundColor(pDict.change < 0 ? .red : .green)
                                }
                            }
                                            
                }
                }
                .onMove(perform:movefavourite)
                .onDelete(perform: deletefavourite)
//                .onLongPressGesture {
//                                withAnimation {
//                                    self.isEditable = true
//                                }
//                            }
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
    Portfolio.reorder(type: "BOOKMARKS_ARRAY", source: from, destination: to )
}
    
func movePurchase(from: IndexSet, to: Int){
    Portfolio.reorder(type: "PURCHASES_ARRAY", source: from, destination: to )
}
    
func deletefavourite(offsets: IndexSet){
    self.Portfolio.deleteBookMark(offset: offsets)
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
