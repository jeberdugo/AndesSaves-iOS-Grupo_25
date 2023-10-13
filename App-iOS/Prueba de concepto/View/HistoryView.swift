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
                                    ForEach(viewModel.transactions) { transaction in
                                        NavigationLink(
                                            destination: TransactionDetailView(transaction: transaction)
                                        ) {
                                            VStack(alignment: .leading) {
                                                if let income = transaction.income{
                                                    Text(income.source)
                                                        .font(.headline)
                                                        .foregroundColor(Color.black)
                                                    
                                                    Text("$\(String(format: "%.2f", income.amount))")
                                                        .font(.subheadline)
                                                        .foregroundColor(income.amount >= 0 ? .green : .red)
                                                    
                                                    Text(viewModel.formatDate(income.date))
                                                        .font(.subheadline)
                                                        .foregroundColor(Color.gray)
                                                }
                                                if let expense = transaction.expense {
                                                    Text(expense.description)
                                                        .font(.headline)
                                                        .foregroundColor(Color.black)
                                                    
                                                    Text("$\(String(format: "%.2f", expense.amount))")
                                                        .font(.subheadline)
                                                        .foregroundColor(expense.amount >= 0 ? .green : .red)
                                                    
                                                    Text(viewModel.formatDate(expense.date))
                                                        .font(.subheadline)
                                                        .foregroundColor(Color.gray)
                                                }
                                            }
                                        }
                                        .listRowBackground(functions.isDaytime ? Color.white : Color(red: 242/255, green: 242/255, blue: 242/255))
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
            Task {
                await viewModel.getData()
            }
        }
    }
    
    
    struct TransactionDetailView: View {
        let transaction: Transaction
        @StateObject private var functions = GlobalFunctions()
        
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
                    Text("")
                        .padding()
                        .foregroundColor(functions.isDaytime ? Color.black : Color.white)
                        .fontWeight(.bold)
                        .font(.title2)
                    Text("$\(String(format: "%.2f", "das"))")
                        .font(.subheadline)
                    Text("")
                        .padding()
                        .foregroundColor(Color.gray)
                    // agragar foto de la transaccion
                }
                Spacer()
            }
            .background(functions.isDaytime ? Color.white : Color(red: 23/255, green: 24/255, blue: 25/255))
        }
    }
    
    
    
}
