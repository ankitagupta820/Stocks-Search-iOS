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
    @ObservedObject var Portfolio: PortfolioVM
    @ObservedObject var Data: DetailVM
    
    @State var isBookMarked: Bool = false
    @State var lineLimit: Int = 2
    @State var isTruncated: Bool = true
    
   
    var body: some View{
        
        ScrollView{
            
        VStack(alignment: .leading){
            Text(Data.Highlights.name).foregroundColor(.secondary)
            HStack(){
                Text(String(format: "$%.2f", Data.Highlights.last)).font(.title).bold()
                Text(String(format: " ($%.2f)", Data.Highlights.change)).foregroundColor( Data.Highlights.change > 0.00 ? .green : .red)
                Spacer()
            }
        }
        
        //Portfolio Section
        VStack(alignment:.leading){
            Text("Portfolio").font(.title)
            HStack(){
                VStack(alignment:.leading){
                    Text(String(format: "Shares Owned:%.2f", Data.Highlights.last))
                    Text("Market Value: $"+"8276")
                }
                Spacer()
                Button(action: {}){
                        Text("Trade").frame(width: 100)
                            .padding()
                            .foregroundColor(.white)
                            .background(Color.green)
                            .cornerRadius(40)
                    }
            
            }
        }.padding(EdgeInsets(top: 10, leading: 0, bottom: 0 , trailing: 0))
        
        
       //Stats Section
        let rows = [
            GridItem(.fixed(20), spacing:20, alignment: .leading),
            GridItem(.fixed(20), spacing:20, alignment: .leading),
            GridItem(.fixed(20), spacing:20, alignment: .leading)
        ]

        VStack(alignment:.leading){
            Text("Stats").font(.title)
            ScrollView(.horizontal) {
                LazyHGrid(rows: rows,
                          alignment: .top,
                          spacing: 20
                          ) {
                    Text(String(format: "Current Price: %.2f", Data.Stats.last))
                    Text(String(format: "Open Price: %.2f", Data.Stats.open))
                    Text(String(format: "High: %.2f", Data.Stats.high))
                    Text(String(format: "Low: %.2f", Data.Stats.low))
                    Text(String(format: "Mid: %.2f", Data.Stats.mid))
                    Text(String(format: "Volume: %.2f", Data.Stats.volume))
                    Text(String(format: "Bid Price: %.2f", Data.Stats.bidPrice))
                    
                }
            }
        }.padding(EdgeInsets(top: 10, leading: 0, bottom: 0 , trailing: 0))
            
        
        //About Section
            VStack(alignment:.leading){
                Text("About").font(.title)
                Text(Data.Abouts.description)
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
        
        VStack(){
                VStack(alignment: .leading){
                    Text("News").font(.title)
                    PrimaryNews(Data: Data)
                    Divider()
                }
            }
            VStack{
                ForEach(Data.NewsItems){news in
                    HStack(){
                        VStack(alignment: .leading){
                            HStack(){
                                Text(news.publishedAt).foregroundColor(.secondary).font(.system(size: 15))
                                Text(news.source).foregroundColor(.secondary).font(.system(size: 15))
                            }
                            Text(news.title).bold().lineLimit(3).fixedSize(horizontal: false, vertical: true)
                        }
                        Spacer()
                        KFImage(URL(string: news.imgURL)!)
                                    .resizable()
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
    
        
        
        Spacer()
     
                
                

            .onAppear(perform: {
                self.isBookMarked = DefaultsStorage.isBookMarked(ticker: self.ticker)
                self.Data.fetchHighlight()
                self.Data.fetchStats()
                self.Data.fetchNews()
                self.Data.fetchAbout()
                
            })
            .navigationTitle(Data.Highlights.ticker)
            .toolbar{
                ToolbarItem(placement: .navigationBarTrailing){
                    Button(action:{
                        self.onBookmark()
                        //self.isBookMarked.toggle()
                    }){
                        Image(systemName: self.isBookMarked == true ? "plus.circle.fill" : "plus.circle")
                    }
                }
            }
        }.padding(.horizontal)
    }
    
    func onBookmark(){
        
        DefaultsStorage.toggleBookmark(ticker: self.ticker, name: Data.Highlights.name)
        self.isBookMarked = DefaultsStorage.isBookMarked(ticker: self.ticker)
        self.Portfolio.fetchPortfolio()
   
    }
}


struct PrimaryNews: View{
    
    @ObservedObject var Data: DetailVM
    var body: some View{
        VStack{
            KFImage(URL(string: Data.NewsItems[0].imgURL)!)
                .resizable()
                .frame(height: 250)
                .cornerRadius(20)
            HStack(){
                Text(Data.NewsItems[0].publishedAt).foregroundColor(.secondary)
                Text(Data.NewsItems[0].source).foregroundColor(.secondary)
                Spacer()
            }
            Text(Data.NewsItems[0].title)
                .bold()
                .fixedSize(horizontal: false, vertical: true)
        }.background(Color.white)
        .contentShape(RoundedRectangle(cornerRadius: 20))
        .contextMenu(menuItems: {
        
            let source = Data.NewsItems[0].URL
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
        DetailView(ticker: "aapl", Portfolio: PortfolioVM(), Data: DetailVM(ticker: "Aapl"))
    }
}

