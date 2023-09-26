//
//  ContentView.swift
//  Prueba de concepto
//
//  Created by Juan Sebastian Sanchez on 7/09/23.
//

import SwiftUI


struct FinanceApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    @StateObject private var viewModel = ContentViewModel()
    
    var body: some View {
        NavigationView {
            ZStack() {
                Color(red: 21/255, green: 191/255, blue: 129/255).edgesIgnoringSafeArea(.all)
                
                VStack() {
                    VStack() {
                        //Color(red: 78, green: 147, blue: 122)
                        Spacer(minLength: 5)
                        Text("Balance")
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
                            // Add transaction view goes here
                        }
                    }
                    Spacer(minLength: 10)
                        MainMenu()
                    
                }
            }
        }
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
    


    




