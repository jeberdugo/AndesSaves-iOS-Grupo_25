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

        var body: some View {
                ZStack() {
                    Color(red: 21/255, green: 191/255, blue: 129/255).edgesIgnoringSafeArea(.all)
                    VStack {
                        Text("History")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                }
                .frame(maxWidth: 400, maxHeight: 60)
            ZStack{
                NavigationView {
                    List {
                        ForEach(viewModel.transactions) { transaction in
                            VStack(alignment: .leading, spacing: 5) {
                                Text(transaction.name)
                                    .font(.headline)
                                if transaction.amount >= 0 {
                                    Text("$\(String(format: "%.2f", transaction.amount))")
                                        .font(.subheadline)
                                        .foregroundColor(.green)
                                } else {
                                    Text("$\(String(format: "%.2f", transaction.amount))")
                                        .font(.subheadline)
                                        .foregroundColor(.red)
                                }
                                Text(viewModel.formatDate(transaction.date))
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .onDelete { indexSet in
                            // Opcion para eliminar un elemento de la lista
                            viewModel.removeTransaction(indexSet)
                        }
                    }
                    .listStyle(PlainListStyle())
                    .background(functions.isDaytime ? Color.white : Color(red: 23/255, green: 24/255, blue: 25/255))
                        .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                EditButton()
                            }
                        }
                }
            }
        }
    }

