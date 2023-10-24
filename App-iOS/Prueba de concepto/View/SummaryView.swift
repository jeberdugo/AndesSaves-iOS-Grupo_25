//
//  SummaryView.swift
//  Prueba de concepto
//
//  Created by Juan Sebastian Sanchez on 25/09/23.
//

import SwiftUI
import Charts

// Vista para "Summary"
    struct SummaryView: View {
        @StateObject private var History = HistoryViewModel()
        @StateObject private var functions = GlobalFunctions()
        
        var body: some View {
            VStack(){
                ZStack() {
                    Color(red: 21/255, green: 191/255, blue: 129/255).edgesIgnoringSafeArea(.all)
                    VStack {
                        Text("Summary")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                }.frame(maxWidth: 400, maxHeight: 60)
                Spacer()
                VStack() {
                    List {
                        Section(header: Text("Totals")) {
                            ForEach(History.totals, id: \.type) { total in
                                                    TotalRow(total: total)
                                                }
                                            }

                        
                        Text("Total expenses by category")
                            .font(.headline)
                            .fontWeight(.bold)
                        
                        if !History.expensesByCategories.isEmpty{
                            Chart(History.expensesByCategories) {
                            BarMark(
                                x: .value("Category", $0.category),
                                y: .value("Amount", $0.amount)
                            )
                        }
                            .frame(height: 250)
                        }
                        else{
                            Text("There are no expenses to show yet")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        // Here
                    }
                }
            }
            .onAppear(){
                History.listTransactions()
            }
            .background(functions.isDaytime ? Color.white : Color(red: 23/255, green: 24/255, blue: 25/255))
        }
    }

struct TotalRow: View {
    var total: Total

    var body: some View {
        HStack {
            Text(total.type)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(total.type == "Expenses" ? .red : .green)
            Spacer()
            Text(String(format: "$%.2f", total.amount))
        }
    }
}
    
