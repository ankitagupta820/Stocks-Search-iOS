//
//  SearchBar.swift
//  Stocks
//
//  Created by Ankita Gupta on 26/11/20.
//

import Foundation
import SwiftUI
import SwiftyJSON
import Alamofire


class SearchBar: NSObject, ObservableObject {
    
    @Published var text: String = ""
    let searchController: UISearchController = UISearchController(searchResultsController: nil)
    
    //Boolean flag to display results and array of results
    @Published var showResults:Bool = false
    @Published var Results:[[String:String]] = []
    let debouncer = Debouncer(delay: 0.5)
    
    override init() {
        super.init()
        self.searchController.obscuresBackgroundDuringPresentation = false
        self.searchController.searchResultsUpdater = self
    }
}

extension SearchBar: UISearchResultsUpdating {
   
    func updateSearchResults(for searchController: UISearchController) {
        
        if let searchBarText = searchController.searchBar.text {
                self.text = searchBarText
        }
        
        if(self.text.count >= 3){
            self.Results=[]
            fetchAutoComplete(keyword: self.text)
        }else{
            self.showResults=false
            self.Results=[]
        }
    }
    
    func fetchAutoComplete(keyword: String){
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2, execute:{
            self.debouncer.run(action:{
                
                let url: String = Constants.Host+"autocomplete?ticker="+keyword
                AF.request(url, encoding:JSONEncoding.default).validate().responseJSON { response in
                    switch response.result{
                    case .success(let value):
                        let json = JSON(value)

                        var autocompleteArray: [[String: String]] = []
                        for item in json.arrayValue {
                            var tickerDict:[String:String] = [:]
                            tickerDict["ticker"] = item["ticker"].stringValue
                            tickerDict["name"]=item["name"].stringValue
                            autocompleteArray.append(tickerDict)
                        }
                        self.Results = autocompleteArray
                        self.showResults = false
                        self.showResults = true
                        debugPrint("Autocomplete data fetched!")
                        
                    case .failure(let error):
                        print(error)
                    }
                }
            })
        })
    }
}

struct SearchBarModifier: ViewModifier {
    
    let searchBar: SearchBar
    
    func body(content: Content) -> some View {
        content
            .overlay(
                ViewControllerResolver { viewController in
                    viewController.navigationItem.searchController = self.searchBar.searchController
                }
                    .frame(width: 0, height: 0)
            )
    }
}

extension View {
    
    func add(_ searchBar: SearchBar) -> some View {
        return self.modifier(SearchBarModifier(searchBar: searchBar))
    }
}
