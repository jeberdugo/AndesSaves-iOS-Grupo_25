//
//  AccountsView.swift
//  Prueba de concepto
//
//  Created by Juan Sebastian Sanchez on 25/09/23.
//

import SwiftUI
import WebKit

// Vista para "Accounts"
    struct WebView: UIViewRepresentable {
        let urlString: String

        func makeUIView(context: Context) -> WKWebView {
            let webView = WKWebView()
            return webView
        }

        func updateUIView(_ uiView: WKWebView, context: Context) {
            if let url = URL(string: urlString) {
                let request = URLRequest(url: url)
                uiView.load(request)
            }
        }
    }

    struct AccountsView: View {
        @StateObject private var viewModel = AccountsViewModel()
        @StateObject private var functions = GlobalFunctions()
        
        var body: some View {
            ZStack() {
                Color(red: 21/255, green: 191/255, blue: 129/255).edgesIgnoringSafeArea(.all)
                VStack {
                    Text("Accounts")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(Color.white)
                }
            }.frame(maxWidth: 400, maxHeight: 60)
            .background(Color(red: 240/255, green: 240/255, blue: 242/255))
            VStack{
                Text("Connect with")
                    .fontWeight(.light)
                    .foregroundColor(functions.isDaytime ? Color.black : Color.white)
                List(viewModel.accounts, id: \.title) { account in
                    Button(action: {
                        viewModel.selectedAccountURL = WebSheetItem(urlString: account.link)
                    }) {
                        AccountRow(account: account)
                    }
                }
            }.listStyle(PlainListStyle())
                .background(functions.isDaytime ? Color.white : Color(red: 23/255, green: 24/255, blue: 25/255))
                .sheet(item: $viewModel.selectedAccountURL) { webSheetItem in
                NavigationView {
                    WebView(urlString: webSheetItem.urlString)
                        .navigationBarTitle("Account Login", displayMode: .inline)
                        .navigationBarItems(leading: Button(action: {
                            viewModel.selectedAccountURL = nil
                        }) {
                            Image(systemName: "arrow.left")
                                .foregroundColor(.blue)
                        })
                }
            }
        }
    }


    struct AccountRow: View {
        let account: Account
        
        var body: some View {
            HStack {
                Image(account.imageName)
                    .resizable()
                    .frame(width: 40, height: 40)
                    .cornerRadius(20)
                Text(account.title)
                    .font(.headline)

            }
        }
    }
