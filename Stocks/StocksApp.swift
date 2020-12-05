//
//  StocksApp.swift
//  Stocks
//
//  Created by Ankita Gupta on 25/11/20.
//

import SwiftUI

@main
struct StocksApp: App {
  
    @ObservedObject var Portfolio: PortfolioVM = PortfolioVM()
   
    var body: some Scene{
       
            WindowGroup {
                PortfolioView(Portfolio: Portfolio).onAppear(perform: { DefaultsStorage.initBalance()})
            }
    }
}

extension View {
    func toast<Content>(isPresented: Binding<Bool>, content: @escaping () -> Content) -> some View where Content: View {
        Toast(
            isPresented: isPresented,
            presenter: { self },
            content: content
        )
    }
}

extension Date {


    func timeAgoSinceDate() -> String {

        // From Time
        let fromDate = self

        // To Time
        let toDate = Date()

        // Estimation
        // Year
        if let interval = Calendar.current.dateComponents([.year], from: fromDate, to: toDate).year, interval > 0  {

            return interval == 1 ? "\(interval)" + " " + "year ago" : "\(interval)" + " " + "years ago"
        }

        // Month
        if let interval = Calendar.current.dateComponents([.month], from: fromDate, to: toDate).month, interval > 0  {

            return interval == 1 ? "\(interval)" + " " + "month ago" : "\(interval)" + " " + "months ago"
        }

        // Day
        if let interval = Calendar.current.dateComponents([.day], from: fromDate, to: toDate).day, interval > 0  {

            return interval == 1 ? "\(interval)" + " " + "day ago" : "\(interval)" + " " + "days ago"
        }

        // Hours
        if let interval = Calendar.current.dateComponents([.hour], from: fromDate, to: toDate).hour, interval > 0 {

            return interval == 1 ? "\(interval)" + " " + "hour ago" : "\(interval)" + " " + "hours ago"
        }
        
        //Minutes
        if let interval = Calendar.current.dateComponents([.minute], from: fromDate, to: toDate).minute, interval > 0 {

                    return interval == 1 ? "\(interval)" + " " + "minute ago" : "\(interval)" + " " + "minutes ago"
                }

                return "a moment ago"
            }
        }


