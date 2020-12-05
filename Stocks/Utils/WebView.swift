//
//  WebView.swift
//  Stocks
//
//  Created by Ankita Gupta on 02/12/20.
//

import Foundation

import SwiftUI
import WebKit


struct WebView: UIViewRepresentable {
    

    var ticker: String
    var loadStatusChanged: ((Bool, Error?) -> Void)? = nil

    func makeCoordinator() -> WebView.Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> WKWebView {
        let view = WKWebView()
        view.navigationDelegate = context.coordinator
        view.scrollView.bounces = false
        view.scrollView.isScrollEnabled=false
        if let url = Bundle.main.url(forResource: "LocalWebsite", withExtension: "html", subdirectory: "www") {
                        view.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
        }
        return view
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
    }

    func onLoadStatusChanged(perform: ((Bool, Error?) -> Void)?) -> some View {
        var copy = self
        copy.loadStatusChanged = perform
        return copy
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebView

        init(_ parent: WebView) {
            self.parent = parent
        }

        func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
            parent.loadStatusChanged?(true, nil)
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            
            let javascriptFunction = "fetchChart('\(parent.ticker)');"
                          webView.evaluateJavaScript(javascriptFunction) { (response, error) in
                              if let error = error {
                                  print("Error calling javascript:valueGotFromIOS()")
                                  print(error.localizedDescription)
                              }
                          }
            parent.loadStatusChanged?(false, nil)
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            parent.loadStatusChanged?(false, error)
        }
    }
}

