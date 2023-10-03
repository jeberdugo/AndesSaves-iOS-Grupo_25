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
    
    @Published var categories = [Category]()

        func createCategory(name: String, user: String) {
            let url = URL(string: "https://andesaves-backend.onrender.com/categories/new")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")

            let parameters: [String: Any] = [
                "name": name,
                "user": user
            ]

            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
            } catch let error {
                print(error.localizedDescription)
            }

            URLSession.shared.dataTask(with: request) { data, response, error in
                if let data = data {
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                            // Handle the JSON response as needed
                            print(json)
                        }
                    } catch let error {
                        print(error.localizedDescription)
                    }
                }
            }.resume()
        }

        @Published var selectedCategoryId: String? // Add a property to store the selected category ID

        func listCategories(userId: String) {
            let url = URL(string: "https://andesaves-backend.onrender.com/categories/list/\(userId)")!
            var request = URLRequest(url: url)
            request.httpMethod = "GET"

            URLSession.shared.dataTask(with: request) { data, response, error in
                if let data = data {
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
                            // Parse and handle the JSON response as needed
                            let categories = json.map { dict in
                                Category(
                                    id: dict["_id"] as? String ?? "", // Assuming the category ID is named "_id"
                                    name: dict["name"] as? String ?? "",
                                    user: dict["user"] as? String ?? ""
                                )
                            }
                            DispatchQueue.main.async {
                                self.categories = categories
                            }
                            
                            // Save the category ID of the first category (if available)
                            if let firstCategoryId = categories.first?.id {
                                UserDefaults.standard.set(firstCategoryId, forKey: "SelectedCategoryIdKey")
                                self.selectedCategoryId = firstCategoryId // Update the selectedCategoryId property
                            }
                        }
                    } catch let error {
                        print(error.localizedDescription)
                    }
                }
            }.resume()
        }
    
    
    func deleteCategory(categoryId: String) {
           guard let userId = UserDefaults.standard.string(forKey: "UserIdKey") else {
               print("User ID not found. Please ensure the user is logged in.")
               return
           }

           let url = URL(string: "https://andesaves-backend.onrender.com/category/delete/\(categoryId)")!
           var request = URLRequest(url: url)
           request.httpMethod = "DELETE"

           URLSession.shared.dataTask(with: request) { data, response, error in
               if let data = data {
                   do {
                       if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                           if let success = json["success"] as? Bool, success {
                               print("Category deleted successfully")
                               
                               if self.selectedCategoryId == categoryId {
                                   self.selectedCategoryId = nil
                               }
                           } else {
                               print("Category deletion failed.")
                           }
                       }
                   } catch let error {
                       print(error.localizedDescription)
                   }
               }
           }.resume()
       }
    }


final class SummaryViewModel: ObservableObject {
    
}

final class RegisterViewModel: ObservableObject {

        
    func register(name: String, phoneNumber : String, password : String, email: String)
    {
        let url = URL(string: "https://andesaves-backend.onrender.com/auth/register")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let parameters: [String: Any] = [
            "name": name,
            "email": email,
            "phoneNumber": phoneNumber,
            "password": password
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch let error {
            print(error.localizedDescription)
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                do {
                    print(data)
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        print(json)
                    }
                } catch let error {
                    print(error.localizedDescription)
                }
            }
        }.resume()
    }
}

final class LoginViewModel: ObservableObject {

    @Published var isLoggedIn = false
    @Published var userId: String?

       func login(email: String, password: String) {
           let url = URL(string: "https://andesaves-backend.onrender.com/auth/login")!
           var request = URLRequest(url: url)
           request.httpMethod = "POST"
           request.addValue("application/json", forHTTPHeaderField: "Content-Type")

           let parameters: [String: Any] = [
               "email": email,
               "password": password
           ]

           do {
               request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
           } catch let error {
               print(error.localizedDescription)
           }

           URLSession.shared.dataTask(with: request) { data, response, error in
               if let data = data {
                   do {
                       if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                           print(json)
                           if let auth = json["auth"] as? Int, auth == 1 {
                               // Login was successful
                               self.isLoggedIn = true
                               
                               // Save the user ID in UserDefaults
                               if let userId = json["userId"] as? String {
                                   UserDefaults.standard.set(userId, forKey: "UserIdKey")
                                   self.userId = userId // Update the userId property
                               }
                           } else {
                               print("El registro del usuario no fue exitoso.")
                               // Handle login failure
                           }
                       }
                   } catch let error {
                       print(error.localizedDescription)
                   }
               }
           }.resume()
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

