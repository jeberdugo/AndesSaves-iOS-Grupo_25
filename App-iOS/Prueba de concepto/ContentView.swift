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
    @State private var transactionName = ""
    @State private var transactionAmount = ""
    @State private var transactionSource = ""
    @State private var selectedType: Int = 0 // 0 for Income, 1 for Expense
    @State private var selectedExpenseCategory: Int = 0
    
    var expenseCategories = ["Food", "Transport", "House", "Others"]
    
    
    
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
                            ZStack() {
                                //Color(red: 21/255, green: 191/255, blue: 129/255).edgesIgnoringSafeArea(.all)
                                Color(selectedType == 1 ? .red : .green) // Red for Expense, Green for Income
                                                        .edgesIgnoringSafeArea(.all)
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
                            Form {
                                            Section(header: Text("Transaction Details")) {
                                                TextField("Name", text: $transactionName)
                                                TextField("Amount", text: $transactionAmount)
                                                TextField("Source", text: $transactionSource)
                                            }

                                            Section(header: Text("Type")) {
                                                Picker(selection: $selectedType, label: Text("Type")) {
                                                    Text("Income").tag(0)
                                                    Text("Expense").tag(1)
                                                }
                                                .pickerStyle(SegmentedPickerStyle())
                                                .padding(.horizontal)
                                            }

                                            if selectedType == 1 {
                                                Section(header: Text("Expense Category")) {
                                                    Picker("Select Category", selection: $selectedExpenseCategory) {
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
                                                .background(selectedType == 1 ? Color.red : Color.green)
                                                .cornerRadius(10)
                                        }
                                        .padding()
                            
                            
                            
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
        @State private var isAddBudgetViewPresented = false
        
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
                    VStack {
                        HStack(spacing: 30) {
                            
                            NavigationLink(destination: AddBudgetView(), isActive: $isAddBudgetViewPresented) {
                                EmptyView()
                            }
                            
                            Button(action: {
                                isAddBudgetViewPresented.toggle()
                            }) {
                            VStack {
                                
                                    Image(systemName: "plus.rectangle.fill")
                                        .resizable()
                                        .frame(width: 40, height: 40) // Increase size
                                        .foregroundColor(.green) // Set color to green
                                        .background(Color.white.opacity(0.2)) // Background color
                                        .cornerRadius(5)
                                    Text("Add")
                                }}
                            
                            
                            VStack {
                                Image(systemName: "minus.rectangle.fill")
                                    .resizable()
                                    .frame(width: 40, height: 40) // Increase size
                                    .foregroundColor(.red) // Set color to red
                                    .background(Color.white.opacity(0.2)) // Background color
                                    .cornerRadius(5)
                                Text("Remove")
                            }
                            .onTapGesture {
                                // Remove action logic here
                            }
                        }
                        .padding(.horizontal)
                        
                        // Section: Individual
                        Text("Individual")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.top, 20)
                        
                        ItemRow(name: "House", date: "2023-09-25", percentage: "60%")
                        
                        Divider()
                        
                        ItemRow(name: "Car", date: "2023-09-26", percentage: "80%")
                        
                        // Section: Group
                        Text("Group")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.top, 20)
                        
                        ItemRow(name: "Europe", date: "2023-09-27", percentage: "75%")
                        
                        Divider()
                        
                        ItemRow(name: "Car", date: "2023-09-28", percentage: "90%")
                    }
                    .padding(.top, -650)
                    .background(Color.white)
                    
                
            }
        
    }
    
    
    
    struct ItemRow: View {
        var name: String
        var date: String
        var percentage: String
        
        var body: some View {
            HStack {
                VStack{
                    Text(name)
                        .font(.headline)
                        .frame(width: 100)
                    
                    Text(date)
                        .font(.subheadline)
                }
                
                
                Spacer()
                
                Text(percentage)
                    .font(.subheadline)
            }
            .padding(.horizontal)
            .padding(.vertical, 5)
        }
    }

    struct BudgetsView_Previews: PreviewProvider {
        static var previews: some View {
            BudgetsView()
        }
    }
    
    struct AddBudgetView: View {
        @State private var budgetName = ""
        @State private var budgetAmount = ""
        @State private var budgetDate = Date()
        @State private var selectedType = 0 // 0 for Individual, 1 for Group
        @State private var memberName = ""
        @State private var groupMembers: [String] = []
        var body: some View {
            ZStack() {
                Color(red: 21/255, green: 191/255, blue: 129/255).edgesIgnoringSafeArea(.all)
                VStack {
                    Text("Add Budgets")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
            }.frame(maxWidth: 400, maxHeight: 60)
            Spacer()
            VStack {
                // Budget Entry Form
                Text("Name")
                    .font(.headline)
                    .padding(.top, 20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .offset(x: 20)
                
                TextField("Enter name", text: $budgetName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                Text("Amount")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .offset(x: 20)
                
                TextField("Enter amount", text: $budgetAmount)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                Text("Date")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .offset(x: 20)
                
                DatePicker("", selection: $budgetDate, displayedComponents: .date)
                    .datePickerStyle(DefaultDatePickerStyle())
                    .padding(.horizontal)
                    
                    
                
                Text("Type")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .offset(x: 20)
                
                Picker(selection: $selectedType, label: Text("Type")) {
                    Text("Individual").tag(0)
                    Text("Group").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                if selectedType == 1 {
                    Text("Members")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .offset(x: 20)
                    
                    TextField("Enter member name", text: $memberName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                    
                    Button(action: {
                        groupMembers.append(memberName)
                        memberName = ""
                    }) {
                        Text("Add Member")
                            .foregroundColor(.green)
                    }
                }
                
                Button(action: {
                    // Add budget entry logic here
                }) {
                    Text("Add")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(10)
                }.padding()
                
            
                
            }.padding(.top, -650)
    }
    }

    struct AddBudgetView_Previews: PreviewProvider {
        static var previews: some View {
            AddBudgetView()
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
                    HStack() {
                        Image(systemName: "dollarsign.circle")
                            .foregroundColor(.blue)
                            .padding(.leading, 16)
                            .frame(width: 30, height: 30)
                        
                        SectionView(title: "Currency")
                            .font(.headline)
                            .padding(.leading, 16)
                            .foregroundColor(.primary)
                        
                        Spacer()}
                    
                    Divider()
                    
                    HStack(){
                        Image(systemName: "globe")
                            .foregroundColor(.blue)
                            .padding(.leading, 16)
                            .frame(width: 30, height: 30)
                        
                        SectionView(title: "Language")
                            .font(.headline)
                            .padding(.leading, 16)
                            .foregroundColor(.primary)
                        
                        Spacer()}
                    
                    Divider()
                    
                    HStack() {
                        Image(systemName: "bell")
                            .foregroundColor(.blue)
                            .padding(.leading, 16)
                            .frame(width: 30, height: 30)
                        
                        SectionView(title: "Notifications")
                            .font(.headline)
                            .padding(.leading, 16)
                            .foregroundColor(.primary)
                        
                        Spacer()}
                    
                }.background(Color.white)
                .padding(.top, -650)
            
        }
    }
    
    struct SectionView: View {
        var title: String
        
        var body: some View {
            HStack {
                Text(title)
                    .font(.headline)
                    .padding(.leading, 16)
                
                Spacer()
            }
            .frame(height: 40) // Adjust the height as needed
        }
    }



}
