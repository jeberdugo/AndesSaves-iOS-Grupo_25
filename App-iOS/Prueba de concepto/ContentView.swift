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
    @State private var balance: Double = 1000.0 // Initial balance
    @State private var isAddingTransaction = false
    
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
                        
                        Text("$\(String(format: "%.2f", balance))")
                            .font(.largeTitle)
                            .foregroundColor(.white)
                        
                        Button(action: {
                            isAddingTransaction.toggle()
                        }) {
                            Text("Add Transaction")
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.black)
                                .cornerRadius(10)
                        }
                        .sheet(isPresented: $isAddingTransaction) {
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

struct MenuItem {
    let title: String
    let imageName: String
}

// MENU PRINCIPAL
struct MainMenu: View {
    var menuItems: [MenuItem] = [
        MenuItem(title: "History", imageName: "History"),
        MenuItem(title: "Budgets", imageName: "Budgets"),
        MenuItem(title: "Tags", imageName: "Tags"),
        MenuItem(title: "Summary", imageName: "Summary"),
        MenuItem(title: "Accounts", imageName: "Accounts"),
        MenuItem(title: "Settings", imageName: "Settings")
    ]
    
    var body: some View {
        VStack {
            Spacer(minLength: 50)
            VStack {
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 10),
                    GridItem(.flexible(), spacing: 10)
                ], spacing: 50) {
                    ForEach(menuItems, id: \.title) { menuItem in
                        NavigationLink(destination: destinationView(for: menuItem)) {
                            ZStack {
                                Rectangle()
                                    .fill(Color(red: 242/255, green: 242/255, blue: 242/255))
                                    .frame(width: 120, height: 120)
                                    .cornerRadius(10)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.gray, lineWidth: 0.5)
                                    )
                                    .shadow(color: Color.black.opacity(0.3), radius: 5, x: 0, y: 2)
                                                           
                                VStack {
                                    Image(menuItem.imageName)
                                        .resizable()
                                        .frame(width: 60, height: 60)
                                    Text(menuItem.title)
                                        .foregroundColor(.gray)
                                        .padding(10)
                                }
                            }
                        }
                    }
                    Spacer(minLength: 30)
                        .padding()
                }
            }
        }
        
        .background(Color.white)
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
    
struct Transaction: Identifiable {
    var id = UUID()
    var name: String
    var amount: Double
    var date: Date
    }
    
// Vista para "History"
    struct HistoryView: View {
        @State private var transactions: [Transaction] = [
            Transaction(name: "Compra de comestibles", amount: -50.0, date: Date()),
            Transaction(name: "Pago de factura del gas", amount: -80.0, date: Date()),
            Transaction(name: "Retiro de cajero", amount: 200.0, date: Date()),
            Transaction(name: "Compra de ropa", amount: -150.0, date: Date()),
            Transaction(name: "Pago de factura del agua", amount: -100.0, date: Date()),
            Transaction(name: "Trabajo ocasional", amount: 250.0, date: Date())
        ]

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
                Spacer()
                NavigationView {
                    List {
                        ForEach(transactions) { transaction in
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
                                Text(formatDate(transaction.date))
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .onDelete { indexSet in
                            // Opcion para eliminar un elemento de la lista
                            transactions.remove(atOffsets: indexSet)
                        }
                    }
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                        EditButton()
                        }
                    }
                }
            }

        // Función para formatear la fecha y hora
        func formatDate(_ date: Date) -> String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM d, yyyy, hh:mm a"
            return dateFormatter.string(from: date)
        }
    }

    
// Vista para "Budgets"
    struct BudgetsView: View {
        var body: some View {
            ZStack() {
                Color(red: 21/255, green: 191/255, blue: 129/255).edgesIgnoringSafeArea(.all)
                VStack {
                    Text("Budgets")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
            }.frame(maxWidth: 400, maxHeight: 60)
            Spacer()
            VStack() {
                
            }.background(Color.white)
        }
    }


    
// Vista para "Tags"
    struct TagsView: View {
        var body: some View {
            ZStack() {
                Color(red: 21/255, green: 191/255, blue: 129/255).edgesIgnoringSafeArea(.all)
                VStack {
                    Text("Tags")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
            }.frame(maxWidth: 400, maxHeight: 60)
            Spacer()
            VStack() {
                
            }.background(Color.white)
        }
    }
    
    

// Vista para "Summary"
    struct SummaryView: View {
        var body: some View {
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
                
            }.background(Color.white)
        }
    }
    
    

// Vista para "Accounts"
    struct AccountsView: View {
        var body: some View {
            ZStack() {
                Color(red: 21/255, green: 191/255, blue: 129/255).edgesIgnoringSafeArea(.all)
                VStack {
                    Text("Accounts")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
            }.frame(maxWidth: 400, maxHeight: 60)
            Spacer()
            VStack() {
                
            }.background(Color.white)
        }
    }
    

// Vista para "Settings"
    struct SettingsView: View {
        var body: some View {
            ZStack() {
                Color(red: 21/255, green: 191/255, blue: 129/255).edgesIgnoringSafeArea(.all)
                VStack {
                    Text("Settings")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
            }.frame(maxWidth: 400, maxHeight: 60)
            Spacer()
            VStack() {
                
            }.background(Color.white)
        }
    }



}
