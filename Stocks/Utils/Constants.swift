//
//  Constants.swift
//  Stocks
//
//  Created by Ankita Gupta on 26/11/20.
//

import Foundation

class Constants{
   static let Host: String = "http://stocks.us-east-1.elasticbeanstalk.com/"
    
    static func getNewsTime(timestamp: String)->String{
        
        let isoDate = timestamp
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM dd, yyyy"
        let date = dateFormatter.date(from:isoDate)!
        return date.timeAgoSinceDate()
        
    }
}
