//
//  HistoryView.swift
//  Prueba de concepto
//
//  Created by Juan Sebastian Sanchez on 25/09/23.
//

import SwiftUI

// Vista para "History"
struct HistoryView: View {
    @StateObject private var viewModel = HistoryViewModel()
    @StateObject private var functions = GlobalFunctions()
    @State private var selectedTransaction: Transaction?
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "12CD8A").edgesIgnoringSafeArea(.all)
                VStack {
                    VStack {
                        Text("History")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    Spacer(minLength: 30)
                    VStack {
                        ZStack {
                            Rectangle()
                                .fill(functions.isDaytime ? Color.white : Color(red: 23/255, green: 24/255, blue: 25/255))
                                .mask(TopRoundedRectangle(radius: 30))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 30)
                                        .fill(functions.isDaytime ? Color.white : Color(red: 23/255, green: 24/255, blue: 25/255))
                                        .shadow(radius: 3, x: 0, y: -3)
                                )
                                .edgesIgnoringSafeArea(.all)
                            
                            VStack {
                                Spacer(minLength: 40)
                                List {
                                    ForEach(viewModel.transactions, id: \.self) { transaction in
                                        NavigationLink(
                                            destination: TransactionDetailView(transaction: transaction)
                                        ) {
                                            VStack(alignment: .leading) {
                                                
                                                    Text(transaction.name)
                                                        .font(.headline)
                                                        .foregroundColor(Color.black)
                                                
                                                    Text(transaction.source)
                                                        .font(.subheadline)
                                                        .foregroundColor(Color.black)
                                                    
                                                    Text("$\(String(format: "%.2f", transaction.amount))")
                                                        .font(.subheadline)
                                                        .foregroundColor(transaction.amount >= 0 ? .green : .red)
                                                    
                                                    Text(viewModel.formatDate(transaction.date.dateValue()))
                                                        .font(.subheadline)
                                                        .foregroundColor(Color.gray)
                                                
                                                
                                            }
                                        }
                                        .listRowBackground(functions.isDaytime ? Color.white : Color(red: 242/255, green: 242/255, blue: 242/255))
                                    }
                                    .onDelete { indexSet in
                                        for index in indexSet {
                                            let transaction = viewModel.transactions[index]
                                            viewModel.deleteTransaction(transactionId: transaction.transactionId)
                                        }
                                    }
                                    .scrollContentBackground(.hidden)
                                    .background(functions.isDaytime ? Color.white : Color(red: 23/255, green: 24/255, blue: 25/255))
                                }
                            }
                        }
                    }
                }
                .navigationBarTitle("", displayMode: .inline)
                .navigationBarHidden(true)
            }
        }.onAppear {
            
            viewModel.listTransactions()
        }
    }
    
    
    struct TransactionDetailView: View {
        let transaction: Transaction
        @StateObject private var functions = GlobalFunctions()
        @StateObject private var viewModel = HistoryViewModel()
        
        var body: some View {
            VStack(){
                ZStack() {
                    Color(red: 21/255, green: 191/255, blue: 129/255).edgesIgnoringSafeArea(.all)
                    VStack {
                        Text("Transaction Detail")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                }.frame(maxWidth: 400, maxHeight: 60)
                VStack() {
                    VStack() {
                            Text(transaction.name)
                                .padding()
                                .foregroundColor(Color.black)
                                .fontWeight(.bold)
                                .font(.headline)
                            Text(transaction.source)
                                .font(.subheadline)
                                .foregroundColor(Color.black)
                            Text("$\(String(format: "%.2f", transaction.amount))")
                                .font(.subheadline)
                                .foregroundColor(transaction.amount >= 0 ? .green : .red)
                            Text("\(transaction.date.dateValue())")
                                .padding()
                                .foregroundColor(Color.gray)
                          
                        if let image = viewModel.storedImage {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 300, height: 350) // Set the size as per your requirements
                        } else {
                            Text("No Image Available")
                        }
                                
                        }
                }
                Spacer()
            }
            .onAppear {
                
                //viewModel.loadImageFromDirectory(fileName: transaction.name)
                viewModel.retrieveImage(fileName: transaction.transactionId)
            }
            .background(functions.isDaytime ? Color.white : Color(red: 23/255, green: 24/255, blue: 25/255))
        }
    }
    
    
    
}
