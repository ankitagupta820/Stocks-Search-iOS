//
//  Details.swift
//  Stocks
//
//  Created by Ankita Gupta on 26/11/20.
//

import Foundation
import KingfisherSwiftUI
import SwiftUI
import Toast

struct DetailView: View {
    
    let ticker: String
    @ObservedObject var PortfolioVM: PortfolioVM
    @ObservedObject var DetailVM: DetailVM
    
    @State var isBookMarked: Bool = false
    @State var lineLimit: Int = 2
    @State var isTruncated: Bool = true
    
    @State var showToast:Bool = false
    @State var ToastMessage:String = ""
    
    @State var showTradeSheet = false
    
    var body: some View{
        
        if self.DetailVM.isLoading {
            Loading
            .onAppear(
                perform: {
                    self.isBookMarked = DefaultsStorage.isBookMarked(ticker: self.ticker)
                    self.DetailVM.fetchHighlight()
                    self.DetailVM.fetchStats()
                    self.DetailVM.fetchNews()
                    self.DetailVM.fetchAbout()
                    self.DetailVM.getOwnedStocks()
                    
                    debugPrint("|-----Fetching Data for \(self.ticker)----------------")
            })
        }else{
            Content.padding(.horizontal)
            .onDisappear(
                    perform:{
                        self.DetailVM.isLoading=true
                })
        }
    }
    
    var Loading: some View {
        ProgressView("Fetching Data...").progressViewStyle(CircularProgressViewStyle())
    }
    
    var Content: some View {
        
        
        ScrollView{
                
            VStack(alignment: .leading){
                Text(DetailVM.Highlights.name).foregroundColor(.secondary)
                HStack(){
                    Text(String(format: "$%.2f", DetailVM.Highlights.last)).font(.title).bold()
                    Text(String(format: " ($%.2f)", DetailVM.Highlights.change)).foregroundColor( DetailVM.Highlights.change > 0.00 ? .green : .red)
                    Spacer()
                }
            }
            
            //Chart
            VStack(){
                WebView(ticker: ticker)
                               .onLoadStatusChanged { loading, error in
                                   if loading {
                                   }
                                   else {
                                       print("Rendered Chart!")
                                   }
                               }.frame(height: 400)
            }
            
            //Portfolio Section
            VStack(alignment:.leading){
                Text("Portfolio").font(.title)
                HStack(){
                    if !self.DetailVM.isOwned {
                        VStack(alignment:.leading){
                            Text("You have 0 shares of \(self.ticker)").font(.system(size: 15))
                            Text("Start Trading!").font(.system(size: 15))
                        }
                    }else{
                        VStack(alignment:.leading){
                            Text(String(format: "Shares Owned:%.4f", self.DetailVM.Owned))
                            Text(String(format: "Market Value: $%.4f", self.DetailVM.Highlights.last*self.DetailVM.Owned))
                        }
                    }
                    
                    Spacer()
                    Button(action: {
                        self.showTradeSheet.toggle()
                    }){
                            Text("Trade").frame(width: 100)
                                .padding()
                                .foregroundColor(.white)
                                .background(Color.green)
                                .cornerRadius(40)
                    }.sheet(isPresented: $showTradeSheet){
                        TradeSheet(showTradeSheet: self.$showTradeSheet, PortfolioVM : self.PortfolioVM, DetailVM: self.DetailVM)
                    }
                
                }
            }.padding(EdgeInsets(top: 10, leading: 0, bottom: 0 , trailing: 0))
            
            
           //Stats Section
            let rows = [
                GridItem(.fixed(20), spacing:15, alignment: .leading), //spacing; between rows
                GridItem(.fixed(20), spacing:15, alignment: .leading),
                GridItem(.fixed(20), spacing:15, alignment: .leading)
            ]

            VStack(alignment:.leading){
                Text("Stats").font(.title)
                ScrollView(.horizontal) {
                    LazyHGrid(rows: rows,
                              alignment: .center,
                              spacing: 20  //between columns
                              ) {
                        Text(String(format: "Current Price: %.2f", DetailVM.Stats.last))
                        Text(String(format: "Open Price: %.2f", DetailVM.Stats.open))
                        Text(String(format: "High: %.2f", DetailVM.Stats.high))
                        Text(String(format: "Low: %.2f", DetailVM.Stats.low))
                        Text(String(format: "Mid: %.2f", DetailVM.Stats.mid))
                        Text(String(format: "Volume: %.2f", DetailVM.Stats.volume))
                        Text(String(format: "Bid Price: %.2f", DetailVM.Stats.bidPrice))
                        
                    }.frame(height: 100)
                }
            }.padding(EdgeInsets(top: 10, leading: 0, bottom: 10 , trailing: 0))
                
            
            //About Section
                VStack(alignment:.leading){
                    Text("About").font(.title)
                    Text(DetailVM.Abouts.description)
                        .lineLimit(lineLimit)
                        .fixedSize(horizontal: false, vertical: true)
                    HStack(){
                        Spacer()
                        Button(action:{
                            self.isTruncated.toggle()
                            self.lineLimit =  self.isTruncated == true ? 2 : 50
                        }){
                            Text(self.isTruncated == true ? "Show more..." : "Show less").foregroundColor(.secondary)
                        }
                    }
                }.padding(EdgeInsets(top: 0, leading: 0, bottom: 10 , trailing: 0))
            
            
            
            //News Section
            
            let NewsList: [News] = DetailVM.NewsItems
            let firstNews = NewsList[0]
            let remainingNews = NewsList.dropFirst(1)
            
            VStack(){
                    VStack(alignment: .leading){
                        Text("News").font(.title)
                        PrimaryNews(news: firstNews)
                        Divider()
                    }
                }
           
            VStack{
                   ForEach(remainingNews){news in
                            HStack(){
                                VStack(alignment: .leading){
                                    HStack(){
                                        Text(news.source).foregroundColor(.secondary).font(.system(size: 15))
                                        Text(Constants.getNewsTime(timestamp: news.publishedAt)).foregroundColor(.secondary).font(.system(size: 15))
                                    }
                                    Text(news.title).bold().lineLimit(3).fixedSize(horizontal: false, vertical: true)
                                }
                                Spacer()
                                KFImage(URL(string: news.imgURL)!)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .clipped()
                                    .frame(width: 100, height: 100)
                                    .cornerRadius(20)
                            }.background(Color.white)
                            .contentShape(RoundedRectangle(cornerRadius: 20))
                            .contextMenu(menuItems: {
                                let source = news.URL
                                let shareString = String("https://twitter.com/intent/tweet?text=Check out this link: &url=\(source)&hashtags=CSCI571StockApp")
                                
                                let shareUrl: URL = URL(string: source)!
                            
                                let escapedShareString = shareString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
                                let twitterUrl: URL = URL(string: escapedShareString)!
                                
                                Link(destination: shareUrl, label: {Label("Open in Safari", systemImage: "safari")})
                                Link(destination: twitterUrl, label: {Label("Share on Twitter", systemImage: "square.and.arrow.up")})
                            })
                        }
                }

                .navigationTitle(DetailVM.Highlights.ticker)
                .toolbar{
                    ToolbarItem(placement: .navigationBarTrailing){
                        Button(action:{
                            self.onBookmark()
                        }){
                            Image(systemName: self.isBookMarked == true ? "plus.circle.fill" : "plus.circle")
                        }
                    }
                }
            }
        
        .toast(isPresented: self.$showToast) {
        HStack {
            Text(self.ToastMessage)
        }
    }
}

    func onBookmark(){
        
        DefaultsStorage.toggleBookmark(ticker: self.ticker, name: DetailVM.Highlights.name)
        self.isBookMarked = DefaultsStorage.isBookMarked(ticker: self.ticker)
        self.PortfolioVM.fetchPortfolio()
        
        if self.isBookMarked {
            self.ToastMessage = "Adding \(self.ticker) to Favorites"
        }else{
            self.ToastMessage = "Removing \(self.ticker) from Favorites"
        }
        self.showToast=true
    }
    
}


struct PrimaryNews: View{
    
    var news: News
    var body: some View{
        VStack(alignment: .leading){
            KFImage(URL(string: news.imgURL)!)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(maxWidth: .infinity,maxHeight: 250)
                .clipped()
//                .resizable()
//                .frame(height: 250)
                .cornerRadius(20)
            HStack(){
                Text(news.source).foregroundColor(.secondary)
                Text(Constants.getNewsTime(timestamp: news.publishedAt)).foregroundColor(.secondary)
                Spacer()
            }
            Text(news.title)
                .bold()
                .fixedSize(horizontal: false, vertical: true)
        }.background(Color.white)
        .contentShape(RoundedRectangle(cornerRadius: 20))
        .contextMenu(menuItems: {
        
            let source = news.URL
            let shareString = String("https://twitter.com/intent/tweet?text=Check out this link: &url=\(source)&hashtags=CSCI571StockApp")
            
            let shareUrl: URL = URL(string: source)!
        
            let escapedShareString = shareString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
            let twitterUrl: URL = URL(string: escapedShareString)!
            
            Link(destination: shareUrl, label: {Label("Open in Safari", systemImage: "safari")})
            Link(destination: twitterUrl, label: {Label("Share on Twitter", systemImage: "square.and.arrow.up")})
        })
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView(ticker: "aapl", PortfolioVM: PortfolioVM(), DetailVM: DetailVM(ticker: "Aapl"))
    }
}

