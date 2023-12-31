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
        @StateObject private var Settings = SettingsViewModel()
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
                        Section(header: Text("Balance Days")) {
                            
                            HStack {
                                Text("Negative Balance Days").font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.red)
                                Spacer()
                                Text(String(History.negativeBalanceDaysLiveData))
                            }
                            HStack {
                                Text("Positive Balance Days").font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.green)
                                Spacer()
                                Text(String(History.positiveBalanceDaysLiveData))
                            }
                            HStack {
                                Text("Even Balance Days").font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.black)
                                Spacer()
                                Text(String(History.evenBalanceDaysLiveData))
                            }
                                
                                            }
                        Section(header: Text("Totals"), footer: Text("")) {
                            ForEach(History.totals, id: \.type) { total in
                                                    TotalRow(total: total)
                                                }
                                            }
                        
                        Section(header: Text("Final Balances for Last 3 Months")) {
                            ForEach(0..<3) { monthIndex in
                                let currentDate = Date()
                                let calendar = Calendar.current
                                let year = calendar.component(.year, from: currentDate)
                                let month = calendar.component(.month, from: currentDate) - monthIndex
                                let monthName = calendar.monthSymbols[(month - 1) % 12]
                                let finalBalance = History.calculateFinalBalanceForMonth(transactions: History.transactions, year: year, month: month)
                                
                                HStack {
                                    Text("\(monthName) \(year)")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                    Spacer()
                                    Text(String(format: "$%.2f", finalBalance))
                                                            }
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
                        Section(header: Text("Predictions")) {
                            HStack {
                                Text("Expenses" )
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.red)
                                Spacer()
                                if let prediction = History.prediction?.predicted_expense {
                                                                Text(String(format: "$%.2f", prediction))
                                                            } else {
                                                                Text("-")
                                                            }
                                
                            }
                                            }
                        Section(header: Text("Suggestions")){
                            HStack {
                                Text("Suggestions Sent" )
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.black)
                                Spacer()
                                Text(String(Settings.numSuggestions))
                            }
                        }
                    }
                }
                
            }
            .onAppear(){
                History.listTransactions()
                Settings.countUserSuggestions()
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

struct PredictionRow: View {
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

    
