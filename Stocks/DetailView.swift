//
//  Details.swift
//  Stocks
//
//  Created by Ankita Gupta on 26/11/20.
//

import Foundation
import KingfisherSwiftUI
import SwiftUI

struct DetailView: View {
    
    let ticker: String
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
                Text(String(format: " ($%.2f)", Data.Highlights.change.magnitude)).foregroundColor( Data.Highlights.change > 0.00 ? .green : .red)
                Spacer()
            }
        }
        
        //Portfolio Section
        VStack(alignment:.leading){
            Text("Portfolio").font(.title)
            HStack(){
                VStack(alignment:.leading){
                    Text(String(format: "Shares Owned:%.2f", Data.Highlights.last)).padding(.vertical)
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
            GridItem(.fixed(20), spacing:20),
            GridItem(.fixed(20), spacing:20),
            GridItem(.fixed(20), spacing:20)
        ]

        VStack(alignment:.leading){
            Text("Stats").font(.title)
            ScrollView(.horizontal) {
                LazyHGrid(rows: rows,
                          spacing: 20) {

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
            VStack{
                VStack(alignment:.leading){
                    Text("About").font(.title)
                    Text(Data.Abouts.description)
                        .lineLimit(lineLimit)
                }
                HStack(){
                    Spacer()
                    Button(action:{
                        self.isTruncated.toggle()
                        self.lineLimit =  self.isTruncated == true ? 2 : 50
                    }){
                        Text(self.isTruncated == true ? "Show more..." : "Show less").foregroundColor(.secondary)
                    }
                }.padding(EdgeInsets(top: 0, leading: 0, bottom: 10 , trailing: 0))
            }
        
        
        
        //News Section
        
        VStack(alignment: .leading){
            Text("News").font(.title)
            KFImage(URL(string: Data.NewsItems[0].imgURL)!)
                .resizable()
                .frame(height: 250)
                .cornerRadius(20)
            HStack(){
                Text("Some time ago").foregroundColor(.secondary)
                Text(Data.NewsItems[0].source).foregroundColor(.secondary)
                Spacer()
            }
            Text(Data.NewsItems[0].title).bold()
                
            Divider()
                
            ForEach(Data.NewsItems, id:\.self){news in
                HStack(){
                    VStack(alignment: .leading){
                        HStack(){
                            Text("Some time ago").foregroundColor(.secondary).font(.system(size: 15))
                            Text(news.source).foregroundColor(.secondary).font(.system(size: 15))
                        }
                            Text(news.title).bold().lineLimit(2)
                    }
                    Spacer()
                    KFImage(URL(string: news.imgURL)!)
                                .resizable()
                                .frame(width: 100, height: 100)
                                .cornerRadius(20)
                }
            }
        }
              
     
                
                
                
        
            
        
      

            .onAppear(perform: {
                self.Data.fetchHighlight()
                self.Data.fetchStats()
                self.Data.fetchNews()
                self.Data.fetchAbout()
            })
            .navigationTitle(Data.Highlights.ticker)
            .toolbar{
                ToolbarItem(placement: .navigationBarTrailing){
                    Button(action:{
                        self.isBookMarked.toggle()
                    }){
                        Image(systemName: self.isBookMarked == true ? "plus.circle.fill" : "plus.circle")
                    }
                }
            }
        }.padding(EdgeInsets(top: 0, leading: 20, bottom: 0 , trailing: 20))
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView(ticker: "aapl", Data: DetailVM(ticker: "Aapl"))
    }
}

