//
//  ContentView.swift
//  Prueba de concepto
//
//  Created by Juan Sebastian Sanchez on 7/09/23.
//

import SwiftUI
import WebKit



struct FinanceApp: App {
    var body: some Scene {
        WindowGroup {
            LoginView()
        }
    }
}
struct ContentView: View {
    @StateObject private var viewModel = ContentViewModel()
    @StateObject private var functions = GlobalFunctions()
    var expenseCategories = ["Food", "Transport", "House", "Others"]
    var body: some View {
        NavigationView {
            ZStack() {
                Color(hex:"12CD8A").edgesIgnoringSafeArea(.all)
                
                VStack() {
                    VStack() {
                        //Color(red: 78, green: 147, blue: 122)
                        Spacer(minLength: 5)
                        Text("BALANCE")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("$\(String(format: "%.2f", viewModel.balance))")
                            .font(.largeTitle)
                            .foregroundColor(.white)
                        
                        Button(action: {
                            viewModel.isAddingTransaction.toggle()
                        }) {
                            Text("Add Transaction")
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.black)
                                .cornerRadius(10)
                        }
                        .sheet(isPresented: $viewModel.isAddingTransaction) {
                            ZStack() {
                                //Color(red: 21/255, green: 191/255, blue: 129/255).edgesIgnoringSafeArea(.all)
                                if(viewModel.selectedType == 1){
                                    Color(hex:"EE446D ").edgesIgnoringSafeArea(.all)                                                                    }
                                else{
                                    Color(hex:"12CD8A").edgesIgnoringSafeArea(.all)                                  }
                                VStack {
                                    Text("History")
                                        .font(.title)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                }
                            }
                            .frame(maxWidth: 400, maxHeight: 60)
                            Spacer()
                            // Add transaction view goes here
                            VStack{
                            Form {
                                Section(header: Text("Transaction Details")) {
                                    TextField("Name", text: $viewModel.transactionName)
                                    TextField("Amount", text: $viewModel.transactionAmount)
                                    TextField("Source", text: $viewModel.transactionSource)
                                }
                                
                                Section(header: Text("Type")) {
                                    Picker(selection: $viewModel.selectedType, label: Text("Type")) {
                                        Text("Income").tag(0)
                                        Text("Expense").tag(1)
                                    }
                                    .pickerStyle(SegmentedPickerStyle())
                                    .padding(.horizontal)                                    }
                                if viewModel.selectedType == 1 {
                                    Section(header: Text("Expense Category")) {
                                        Picker("Select Category", selection: $viewModel.selectedExpenseCategory) {
                                            ForEach(0..<expenseCategories.count) { index in
                                                Text(expenseCategories[index])
                                            }
                                        }
                                        .pickerStyle(SegmentedPickerStyle())
                                    }
                                }
                            }
                            Button(action: {
                                // Add action logic here to save the transaction
                            }) {
                                Text("Add")
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(viewModel.selectedType == 1 ? Color(hex:"EE446D") : Color(hex:"12CD8A"))
                                    .cornerRadius(10)
                            }
                            .padding()
                          }
                            .background(functions.isDaytime ? Color.white : Color(red: 23/255, green: 24/255, blue: 25/255))
                        }
                    }
                    Spacer(minLength: 10)
                    MainMenu()
                    
                }
            }
        }
        .navigationBarBackButtonHidden(/*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
    }
}


// SELECTOR DE VISTAS SECUNDARIAS
func destinationView(for menuItem: MenuItem) -> some View {
    switch menuItem.title {
    case "History":
        return AnyView(HistoryView())
    case "Budgets":
        return AnyView(BudgetsView())
    case "Tags":
        return AnyView(TagsView())
    case "Summary":
        return AnyView(SummaryView())
    case "Accounts":
        return AnyView(AccountsView())
    case "Settings":
        return AnyView(SettingsView())
        
    default:
        return AnyView(Text("Ha ocurrido un error, vuelva al menu principal"))
    }
}
