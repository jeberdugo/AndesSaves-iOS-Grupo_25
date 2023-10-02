//
//  FinaceModelView.swift
//  Prueba de concepto
//
//  Created by Juan Sebastian Sanchez on 25/09/23.
//

import Foundation

final class ContentViewModel: ObservableObject {
    @Published public var isAddingTransaction = false
    @Published public var transactionName = ""
    @Published public var transactionAmount = ""
    @Published public var transactionSource = ""
    @Published public var selectedType: Int = 0 // 0 for Income, 1 for Expense
    @Published public var selectedExpenseCategory: Int = 0

}


final class MainMenuViewModel: ObservableObject {
    @Published var menuItems: [MenuItem] = [
        MenuItem(title: "History", imageName: "History"),
        MenuItem(title: "Budgets", imageName: "Budgets"),
        MenuItem(title: "Tags", imageName: "Tags"),
        MenuItem(title: "Summary", imageName: "Summary"),
        MenuItem(title: "Accounts", imageName: "Accounts"),
        MenuItem(title: "Settings", imageName: "Settings")
    ]
}


final class HistoryViewModel: ObservableObject {
    @Published public var transactions: [Transaction] = [
        Transaction(name: "Compra de comestibles", amount: -100000, date: Date()),
        Transaction(name: "Pago de factura del gas", amount: 80000, date: Date()),
        Transaction(name: "Retiro de cajero", amount: -200000, date: Date()),
        Transaction(name: "Compra de ropa", amount: -150000, date: Date()),
        Transaction(name: "Pago de factura del agua", amount: -100000, date: Date()),
        Transaction(name: "Trabajo ocasional", amount: 250000, date: Date())
    ]
    
    func calculateBalance() -> Double {
        let totalAmount = transactions.reduce(0) { $0 + $1.amount }
        return totalAmount
    }
    
    // Función para formatear la fecha y hora
    func formatDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy, hh:mm a"
        return dateFormatter.string(from: date)
    }
    
    // Funcion para eliminar un item de History
    func removeTransaction(_ indexSet: IndexSet) {
               transactions.remove(atOffsets: indexSet)
       }
}


final class BudgetsViewModel: ObservableObject {
    
    
    
    // Vista de Add Budgets
    
}


final class TagsViewModel: ObservableObject {
    @Published var tagsItems: [TagsItem] = [
        TagsItem(title: "Food", imageName: "Food"),
        TagsItem(title: "Transportation", imageName: "Transportation"),
        TagsItem(title: "Housing", imageName: "Housing"),
        TagsItem(title: "Health", imageName: "Health"),
        TagsItem(title: "Entertainment", imageName: "Entertainment"),
        TagsItem(title: "Add", imageName: "Add")
    ]

    @Published var isEditMode = false
    @Published var isAddTagDialogPresented = false
    @Published var newTagName = ""

    // Función para agregar una nueva etiqueta
    func addNewTag(_ tagName: String) {
        let newTag = TagsItem(title: tagName, imageName: "DefaultImage") // Ajusta la imagen según tus necesidades.
        tagsItems.insert(newTag, at: tagsItems.count - 1)
    }
}


final class SummaryViewModel: ObservableObject {
    
}


final class AccountsViewModel: ObservableObject {
    
    @Published var accounts: [Account] = [
        Account(title: "Paypal", imageName: "Paypal", link: "https://www.paypal.com/signin"),
        Account(title: "Nequi", imageName: "Nequi", link: "https://transacciones.nequi.com/bdigital/login.jsp"),
        Account(title: "Daviplata", imageName: "Daviplata", link: "https://conectesunegocio.daviplata.com/es/user/login")
    ]

    @Published public var selectedAccountURL: WebSheetItem? = nil
}

final class SettingsViewModel: ObservableObject {
    
}


final class GlobalFunctions: ObservableObject {
// Contex aware feature: Cambia los colores de la vista dependiendo de la hora
 
        var isDaytime: Bool {
            let hour = Calendar.current.component(.hour, from: Date())
            return hour >= 6 && hour < 18
    }
}

