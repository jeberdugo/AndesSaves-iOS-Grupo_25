//
//  FinaceModelView.swift
//  Prueba de concepto
//
//  Created by Juan Sebastian Sanchez on 25/09/23.
//

import Foundation
import Combine
import SwiftUI
import Firebase

final class ContentViewModel: ObservableObject {
    @Published public var isAddingTransaction = false
    @Published public var transactionName = ""
    @Published public var transactionAmount  = ""
    @Published public var transactionSource = ""
    @Published public var selectedType: Int = 0 // 0 for Income, 1 for Expense
    @Published public var selectedExpenseCategory: Int = 0
    @Published public var balance: Double = 60.0
        
    
    func getBalance() {
            
        }

    func addIncome(source: String,  amount: Int) {
        
        }
    

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
    @Published public var transactions: [Transaction] = [ ]
    let currentDateTime = Date()
    
    // Función para formatear la fecha y hora
    func formatDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy, hh:mm a"
        return dateFormatter.string(from: date)
    }
    
    
    @Published var incomes = [Income]()
    
    func listIncomes() {
        
    }
}


final class BudgetsViewModel: ObservableObject {

    
    
    struct Budget: Codable {
        let name: String
        let total: Int
        let user: String
        let date: Date
        let type: Int
    }

    func createBudget(name: String, total: Int, date: Date, type: Int) {
        
    }
    
    func fetchBudgets(completion: @escaping ([Budget]?) -> Void) {
        
    }
    

}


final class TagsViewModel: ObservableObject {
        @Published var tagsItems: [TagsItem] = [
            TagsItem(title: "Add", imageName: "Add")
        ]
    
        @Published var count = 0

        @Published var isEditMode = false
        @Published var isAddTagDialogPresented = false
        @Published var newTagName = ""
        let loginViewModel: LoginViewModel = LoginViewModel()

        // Función para agregar una nueva etiqueta
        func addNewTag(_ tagName: String) {
            let newTag = TagsItem(title: tagName, imageName: "DefaultImage") // Ajusta la imagen según tus necesidades.
            tagsItems.insert(newTag, at: tagsItems.count - 1)
        }
        
        @Published var categories = [Category]()
        @Published var categoriesWithId = [CategoryWithId]()
        @Published var selectedCategoryId: String?
    
    func createCategory(name: String) {
               }
    
    
    func listCategories() {
                       }
    
    
    func deleteCategory(categoryId: String) {
                  
            }
    }


final class SummaryViewModel: ObservableObject {
    
}

final class RegisterViewModel: ObservableObject {
    @Published var isRegistered = false
    @Published var message = ""
    
    func register(name: String, phoneNumber: String, password: String, passwordConfirmation: String, email: String) {
        self.isRegistered = false
        
        if password != passwordConfirmation {
            // Manejo de errores si las contraseñas no coinciden
            // Puedes mostrar una alerta al usuario
            self.message = "Passwords do not match"
        }

        else{
            Auth.auth().createUser(withEmail: email, password: password) { (Result, error) in
                if error != nil {
                    self.message = error!.localizedDescription
                } else {
                    // Registro exitoso
                    self.isRegistered = true
                    self.message = "Registration completed successfully"
                    let user = Auth.auth().currentUser
                    if let user = user {
                        let db = Firestore.firestore()
                        let ref = db.collection("users").document(user.uid)
                        ref.setData(["balance": 0, "email": email, "name": name, "phone": phoneNumber, "userId": user.uid]){error in
                            if let error = error{
                                
                            }
                            
                        }
                        
                        let changeRequest = user.createProfileChangeRequest()
                        changeRequest.displayName = name
                        changeRequest.commitChanges { (error) in
                        }
                    }
                }
            }
            
        }
        
    }

}



final class LoginViewModel: ObservableObject {

    @Published var isLoggedIn = false
    @Published var alertItem: AlertItem?
    @Published var token = ""
    @Published var user = ""
    
    func login(email: String, password: String ) {
        Auth.auth().signIn(withEmail: email, password: password){ result, error in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                self.isLoggedIn = true
            }
        }
    }
    
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

