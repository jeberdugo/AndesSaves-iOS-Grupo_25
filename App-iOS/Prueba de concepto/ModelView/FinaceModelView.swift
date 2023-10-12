//
//  FinaceModelView.swift
//  Prueba de concepto
//
//  Created by Juan Sebastian Sanchez on 25/09/23.
//

import Foundation
import Combine
import SwiftUI

final class ContentViewModel: ObservableObject {
    @Published public var isAddingTransaction = false
    @Published public var transactionName = ""
    @Published public var transactionAmount  = ""
    @Published public var transactionSource = ""
    @Published public var selectedType: Int = 0 // 0 for Income, 1 for Expense
    @Published public var selectedExpenseCategory: Int = 0
    @Published public var balance: Double = 0

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

    
    
    struct Budget: Codable {
        let name: String
        let total: Int
        let user: String
        let date: Date
        let type: Int
    }

    func createBudget(name: String, total: Int, date: Date, type: Int) {
        let budget = Budget(name: name, total: total, user: Auth.shared.getUser()!, date: date, type: type)
        guard let url = URL(string: "https://andesaves-backend.onrender.com/budgets/new") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        print("token" + Auth.shared.getAccessToken()!)
        let token = Auth.shared.getAccessToken()
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        do {
            let jsonData = try JSONEncoder().encode(budget)
            request.httpBody = jsonData
        } catch {
            print("Error encoding budget data")
            return
        }

        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Error making POST request: \(error)")
                return
            }
            if let response = response as? HTTPURLResponse {
                print("Response status code: \(response.statusCode)")
            }
        }.resume()
    }

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
    @Published var alertItem: AlertItem?
    @Published var token = ""
    @Published var user = ""
    
    func login(email: String, password: String, completion: @escaping (Bool) -> Void) {
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
                        if let auth = json["auth"] as? Int{
                            DispatchQueue.main.async {
                                if auth == 1 {
                                    if let token2 = json["token"] as? String{
                                        self.token = token2
                                        if let user2 = json["user"] as? String{
                                            self.user = user2
                                            print(user2)
                                            Auth.shared.setCredentials(
                                                           accessToken: token2, user: user2
                                                       )
                                            print(Auth.shared.getCredentials())
                                        }
                                    }
                                    self.isLoggedIn = true
                                    completion(true)
                                } else {
                                    if let message = json["message"] as? String{
                                        self.alertItem = AlertItem(message: message)
                                    }
                                    completion(false)
                                }
                            }
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

