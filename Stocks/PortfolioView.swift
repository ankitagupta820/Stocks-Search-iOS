
//  ContentView.swift
//  Stocks

import SwiftUI

struct PortfolioView: View {

    @ObservedObject var searchBar: SearchBar = SearchBar()
    @ObservedObject var portfolio = Portfolio()
    var body: some View {
        Group{
        NavigationView{
        
           List{
            Text("November 1, 2020").font(.title).foregroundColor(.secondary).bold()
                Section(header: Text("Portfolio")){
                    VStack(alignment: .leading){
                        Text("Net Worth").font(.title)
                        Text("271.98").font(.title).foregroundColor(.primary).bold()
                    }
                    ForEach(0..<3){_ in
                        NavigationLink(destination: DetailView(ticker: "aapl", Data: DetailVM(ticker: "aapl"))){
                                HStack{
                                    VStack(alignment: .leading)
                                    {
                                        Text("TICKER").font(.title2).bold()
                                        Text("subtitle").foregroundColor(.secondary)
                                    }
                                    Spacer()
                                    VStack(alignment: .trailing){
                                        Text("1762.8").font(.title2).bold()
                                        HStack{
                                            Text("symbol")
                                            Text("subtitle").foregroundColor(.secondary)
                                        }
                                    }
                                }
                            }
                    }.onMove(perform: moveStocks)
                }
            
                Section(header: Text("Favorites")){
                    ForEach(0..<3){_ in
                       NavigationLink(destination: DetailView(ticker: "pbt",  Data: DetailVM(ticker: "pbt"))){
                        HStack{
                            VStack(alignment: .leading){
                                Text("TICKER").font(.title2).bold()
                                Text("subtitle").foregroundColor(.secondary)
                            }
                            Spacer()
                            VStack(alignment: .trailing){
                                Text("1762.8").font(.title2).bold()
                                HStack{
                                    Text("symbol")
                                    Text("subtitle").foregroundColor(.secondary)
                                }
                            }
                        }
                       }
                    }
                    .onMove(perform: moveStocks)
                    .onDelete(perform: deleteStocks)
                }
           }
           .navigationTitle(Text("Stocks"))
           .toolbar{
            EditButton()
           }
           .add(self.searchBar)
        }
        }
        
        Spacer()
        Link("Powered by Tingoo", destination: URL(string: "https://api.tiingo.com/")!)
            .foregroundColor(.secondary)
            .padding()
    }
}



func moveStocks(from: IndexSet, to: Int){
    
}
func deleteStocks(offsets: IndexSet){
    
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        PortfolioView()
    }
}
