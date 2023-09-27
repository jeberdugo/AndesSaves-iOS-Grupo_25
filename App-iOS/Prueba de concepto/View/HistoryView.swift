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
            Color(hex:"12CD8A").edgesIgnoringSafeArea(.all)
            VStack() {
                VStack() {Text("History")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                Spacer(minLength: 30)
                VStack{
                    ZStack{
                        Rectangle()
                        .fill(functions.isDaytime ? Color.white : Color(red: 23/255, green: 24/255, blue: 25/255))
                            .mask(TopRoundedRectangle(radius: 30))
                            .overlay(
                                RoundedRectangle(cornerRadius: 30)
                                    .fill(functions.isDaytime ? Color.white : Color(red: 23/255, green: 24/255, blue: 25/255))
                                    .shadow(radius: 3, x: 0, y: -3)

                            )
                            .edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
                        
                        VStack{
                            Spacer(minLength: 40)
                            List {
                                                    ForEach(viewModel.transactions) { transaction in
                                                            Text(transaction.name)
                                                                .font(.headline)
                                                                .foregroundColor(functions.isDaytime ? Color(red: 23/255, green: 24/255, blue: 25/255):  Color.white) 
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
                                                                .foregroundColor(.secondary)                                                    }
                                                    .onDelete { indexSet in
                                                        // Opcion para eliminar un elemento de la lista
                                                        viewModel.removeTransaction(indexSet)
                                                    }.listRowBackground(functions.isDaytime ? Color.white : Color(red: 23/255, green: 24/255, blue: 25/255)   )                                             }.scrollContentBackground(.hidden)    .listStyle(PlainListStyle())
                                                    .toolbar {
                                                        ToolbarItem(placement: .navigationBarTrailing) {
                                                            EditButton()
                                                        }
                                                    }
                        }
                    }
                }
            }
        }
        
        
        
    }
}

