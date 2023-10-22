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
    @Published public var balance: Float = 0
    @Published public var storedImage: UIImage?
    
        
    
    func getBalance(transactions: [Transaction]) {
        self.balance = transactions.reduce(0) { $0 + $1.amount }
        print(self.balance)
        }

    
    func addTransaction(amount: Int, category: String, date: Date, imageUri: String, name: String, source: String, type: String){
        let user = Auth.auth().currentUser
        if let user = user{
            let db = Firestore.firestore()
            let transactionsCollection = db.collection("users").document(user.uid).collection("transactions")
            // Create a new transaction document with a unique identifier
                    var ref: DocumentReference? = nil
                    ref = transactionsCollection.addDocument(data: [
                        "amount": amount,
                        "category": category,
                        "date": date,
                        "imageUri": imageUri,
                        "name": name,
                        "source": source,
                        "type": type
                    ]) { error in
                        if let error = error {
                            print("Error adding transaction: \(error.localizedDescription)")
                        } else {
                            print("Transaction added with ID: \(ref!.documentID)")
                            self.isAddingTransaction = true
                        }
                    }
                }
            }
    
    
    func saveImageFromDirectory(fileName: String){
        
        let dir_path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("transactions", isDirectory: true)
        
        if !FileManager.default.fileExists(atPath: dir_path.path){
            do{
                try FileManager.default.createDirectory(atPath: dir_path.path, withIntermediateDirectories: true, attributes: nil)
                print("Succesfully created")
            }
            catch{
                print("Error creating user directory: " + error.localizedDescription)
            }
        }
        
        let img_dir = dir_path.appendingPathComponent(fileName)
        
        do{
            try storedImage?.pngData()?.write(to: img_dir)
            print("Image saved")
        }
        catch{
            print("Some error: " + error.localizedDescription)
        }
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
    @Published public var transactions: [Transaction] = []
    let currentDateTime = Date()
    
    // Función para formatear la fecha y hora
    func formatDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy, hh:mm a"
        return dateFormatter.string(from: date)
    }
    
    
    func listTransactions() {
        transactions.removeAll()
        if let user = Auth.auth().currentUser {
            let db = Firestore.firestore()
            let transactionsCollection = db.collection("users").document(user.uid).collection("transactions")
            

            transactionsCollection.getDocuments { (snapshot, error) in
                guard error == nil else {
                    print(error!.localizedDescription)
                    return
                }
                
                if let snapshot = snapshot {
                    for document in snapshot.documents{
                            let data = document.data()
            
                            let amount = data["amount"] as? Float ?? 0
                            let category = data["category"] as? String ?? ""
                        let date = data["date"] as? Timestamp ?? Timestamp()
                            let imageUri = data["imageUri"] as? String ?? ""
                            let name = data["name"] as? String ?? ""
                            let source = data["source"] as? String ?? ""
                            let transactionId = document.documentID
                            let type = data["type"] as? String ?? ""
                            
                            let transaction = Transaction(amount: amount, category: category, date: date, imageUri: imageUri, name: name, source: source, transactionId: transactionId, type: type)
                            self.transactions.append(transaction)
                }
            }
            }
        }
    }
    
    
    func deleteTransaction(transactionId: String) {
        if let user = Auth.auth().currentUser {
            let db = Firestore.firestore()
            let transactionsCollection = db.collection("users").document(user.uid).collection("transactions")

            // Get a reference to the category document you want to delete
            let transactionDocument = transactionsCollection.document(transactionId)

            // Delete the category document
            transactionDocument.delete { error in
                if let error = error {
                    print("Error deleting category: \(error.localizedDescription)")
                } else {
                    print("Category deleted successfully")
                    
                    // Optionally, remove the deleted category from your local array
                    if let index = self.transactions.firstIndex(where: { $0.transactionId == transactionId }) {
                        self.transactions.remove(at: index)
                    }
                }
            }
        }
    }
    
    func loadImageFromDirectory(){
        
    }
    
    func deleteImageFromDirectory(){
        
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
    
    @Published var expenseCategories:  [String] = []
    
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
    
    
    func createCategory(name: String){
        let user = Auth.auth().currentUser
        if let user = user{
            let db = Firestore.firestore()
            let categoriesCollection = db.collection("users").document(user.uid).collection("tags")
            // Create a new transaction document with a unique identifier
                    var ref: DocumentReference? = nil
                    ref = categoriesCollection.addDocument(data: [
                        "name": name
                    ]) { error in
                        if let error = error {
                            print("Error adding transaction: \(error.localizedDescription)")
                        } else {
                            print("Transaction added with ID: \(ref!.documentID)")
                            
                        }
                    }
                }
            }
    
    
    func listCategories() {
        categoriesWithId.removeAll()
        self.expenseCategories.removeAll()
        if let user = Auth.auth().currentUser {
            let db = Firestore.firestore()
            let categoriesCollection = db.collection("users").document(user.uid).collection("tags")
            

            categoriesCollection.getDocuments { (snapshot, error) in
                guard error == nil else {
                    print(error!.localizedDescription)
                    return
                }
                
                if let snapshot = snapshot {
                    for document in snapshot.documents{
                            let data = document.data()
            
                            let name = data["name"] as? String ?? ""
                            let categoryId = document.documentID
                            
                            let category = CategoryWithId(name: name, categoryId: categoryId )
                            self.categoriesWithId.append(category)
                            self.expenseCategories.append(name)
                }
            }
            }
        }
    }
    
    
    func deleteCategory(categoryId: String) {
        if let user = Auth.auth().currentUser {
            let db = Firestore.firestore()
            let categoriesCollection = db.collection("users").document(user.uid).collection("tags")

            // Get a reference to the category document you want to delete
            let categoryDocument = categoriesCollection.document(categoryId)

            // Delete the category document
            categoryDocument.delete { error in
                if let error = error {
                    print("Error deleting category: \(error.localizedDescription)")
                } else {
                    print("Category deleted successfully")
                    
                    // Optionally, remove the deleted category from your local array
                    if let index = self.categoriesWithId.firstIndex(where: { $0.categoryId == categoryId }) {
                        self.categoriesWithId.remove(at: index)
                    }
                }
            }
        }
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
    @Published public var isLoggingOut = false
    @Published public var isDeletingAccount = false
    @Published public var isShowAlarm = false
    @AppStorage("notificationsEnabled") var notificationsEnabled = false
    
    @Published public var balance: Float = 0
    @Published public var email = ""
    @Published public var name  = ""
    @Published public var phone = ""
    @Published public var userId = ""
    
    func signOut(){
        do{
            try Auth.auth().signOut()
        } catch{
            print("DEBUG: Failed to sign out with error \(error.localizedDescription)")
        }
    }
    
    func deleteAccount(){
        
    }
    
    func fetchUser(){
        if let user = Auth.auth().currentUser {
            let db = Firestore.firestore()
            let usersCollection = db.collection("users")
            

            usersCollection.getDocuments { (snapshot, error) in
                guard error == nil else {
                    print(error!.localizedDescription)
                    return
                }
                
                if let snapshot = snapshot {
                    for document in snapshot.documents{
                            let data = document.data()
                            let id = data["userId"] as? String ?? ""
                        if  id == user.uid{
                            self.balance = data["balance"] as? Float ?? 0
                            self.email = data["email"] as? String ?? ""
                            self.name = data["name"] as? String ?? ""
                            self.phone = data["phone"] as? String ?? ""
                            self.userId = data["userId"] as? String ?? ""
                        }
                    }
                }
            }
        }
    }
}


final class GlobalFunctions: ObservableObject {
// Contex aware feature: Cambia los colores de la vista dependiendo de la hora
 
        var isDaytime: Bool {
            let hour = Calendar.current.component(.hour, from: Date())
            return hour >= 6 && hour < 18
    }
}

