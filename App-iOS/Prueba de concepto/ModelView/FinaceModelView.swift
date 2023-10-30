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
import FirebaseStorage
import CoreMotion

final class ContentViewModel: ObservableObject {
    @Published public var isAddingTransaction = false
    @Published public var fieldsAreEmpty = false
    @Published public var transactionName = ""
    @Published public var transactionAmount  = ""
    @Published public var transactionSource = ""
    @Published public var errorText = ""
    @Published public var selectedType: Int = 0 // 0 for Income, 1 for Expense
    @Published public var selectedExpenseCategory: Int = 0
    @Published public var balance: Float = 0
    @Published public var storedImage: UIImage?
    
    #if os(iOS)
    let motionManager = CMMotionManager()
    #endif
    
    func clearTextFields() {
        transactionName = ""
        transactionAmount = ""
        transactionSource = ""
    }

    
    func addTransaction(amount: Int, category: String, date: Date, imageUri: String, name: String, source: String, type: String, image: UIImage?){
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
                            self.balance = self.balance + Float(amount)
                            self.updateBalance(newBalance: self.balance)
                            print("Transaction added with ID: \(ref!.documentID)")
                            if image != nil{
                                //self.saveImageFromDirectory(fileName: ref!.documentID, image: image)
                                self.uploadImage(fileName: ref!.documentID, image: image)
                            }
                            self.isAddingTransaction = false
                        }
                    }
                }
            }
    
    func updateBalance(newBalance: Float) {
        if let user = Auth.auth().currentUser {
            let db = Firestore.firestore()
            let userDocument = db.collection("users").document(user.uid)

            userDocument.updateData([
                "balance": newBalance
            ]) { error in
                if let error = error {
                    // Handle the error here
                    print("Error updating balance: \(error.localizedDescription)")
                } else {
                    // Update successful
                    print("Balance updated successfully")
                }
            }
        }
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
                            print(self.balance)
                            let email = data["email"] as? String ?? ""
                            let name = data["name"] as? String ?? ""
                            let phone = data["phone"] as? String ?? ""
                            let userId = data["userId"] as? String ?? ""
                        }
                    }
                }
            }
        }
    }
    
    
    func saveImageFromDirectory(fileName: String, image: UIImage?){
        
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
        
        let img_dir = dir_path.appendingPathComponent(fileName + ".png")
        
        do{
            print("Image will be saved at: " + img_dir.path)
            try image?.pngData()?.write(to: img_dir)
            print("Image saved")
        }
        catch{
            print("Some error: " + error.localizedDescription)
        }
    }
    
    func uploadImage(fileName: String, image: UIImage?){
        
        if image != nil{
            
            let storageRef = Storage.storage().reference()
            
            let imageData = image!.jpegData(compressionQuality: 0.8)
            
            guard imageData != nil else{
            return
        }
        
        let fileRef = storageRef.child("Transactions/\(fileName).jpg")
        
        let uploadTask = fileRef.putData(imageData!, metadata: nil){ metadata, error in
            
            
            if error == nil && metadata != nil{
                
            }
            
        }
        }else{
            print("La imagen es nil")
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
    @Published public var storedImage: UIImage?
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
                    self.expensesByMonth()
                    self.calculateTotals()
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
                    self.deleteImage(fileName: transactionDocument.documentID)
                    
                    // Optionally, remove the deleted category from your local array
                    if let index = self.transactions.firstIndex(where: { $0.transactionId == transactionId }) {
                        self.transactions.remove(at: index)
                    }
                }
            }
        }
    }
    
    func loadImageFromDirectory(fileName: String){
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let documentsPath = documentsURL.appendingPathComponent("transactions")
        let imagePath = documentsPath.appendingPathComponent(fileName + ".png")

        print("Image will be loaded from: " + imagePath.path)
        self.storedImage = UIImage(contentsOfFile: imagePath.path)
        print("Image Loaded")
    }

    func deleteImageFromDirectory(fileName: String){
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let documentsPath = documentsURL.appendingPathComponent("transactions")
        let imagePath = documentsPath.appendingPathComponent(fileName + ".png")

        do {
            try FileManager.default.removeItem(at: imagePath)
            print("Image Deleted from directory")
        } catch {
            print("Failed to delete: " + error.localizedDescription)
        }
    }
    
    func retrieveImage(fileName: String){
        let storageRef = Storage.storage().reference()
        
        let fileRef = storageRef.child("Transactions/\(fileName).jpg")
        
        fileRef.getData(maxSize: 5 * 1024 * 1024){
            data, error in
            
            if error == nil && data != nil{
                
                self.storedImage = UIImage(data: data!)
            }
            
        }
    }
    
    func deleteImage(fileName: String){
        let storageRef = Storage.storage().reference()
        
        let fileRef = storageRef.child("Transactions/\(fileName).jpg")

        // Delete the file
        fileRef.delete { error in
          if let error = error {
            print("an error occur")
          } else {
            print("Image deleted")
          }
        }
    }
   
    @Published var expensesByCategories: [ExpenseByCategory] = []
   
    func expensesByMonth() {
        // Create an empty dictionary to store expenses by category
        var expensesByCategoryDict: [String: Float] = [:]

        // Iterate through the transactions
        for transaction in self.transactions {
            if transaction.type == "Expense" {
                let category = transaction.category
                let amount = transaction.amount
                print(category)

                // Check if the category is already in the dictionary
                if let existingAmount = expensesByCategoryDict[category] {
                    // If it exists, add the amount to the existing value
                    expensesByCategoryDict[category] = existingAmount + amount
                } else {
                    // If it doesn't exist, initialize it with the amount
                    expensesByCategoryDict[category] = amount
                }
            }
        }

        // Convert the dictionary to an array of ExpenseByCategory
        let expensesByCategoryArray = expensesByCategoryDict.map { (category, amount) in
            return ExpenseByCategory(category: category, amount: abs(amount))
        }

        // Update the expensesByCategories property with the calculated values
        self.expensesByCategories = expensesByCategoryArray
    }
    
    @Published var totals: [Total] = [
        Total(type: "Expenses", amount: 0),
        Total(type: "Incomes", amount: 0)]
    
    
    
    func calculateTotals(){

        var expenseTotal: Float = 0
           var incomeTotal: Float = 0

           for transaction in self.transactions {
               if transaction.type == "Expense" {
                   expenseTotal += transaction.amount
               } else if transaction.type == "Income" {
                   incomeTotal += transaction.amount
               }
           }

           // Update the totals array
           if let expenseIndex = self.totals.firstIndex(where: { $0.type == "Expenses" }) {
               self.totals[expenseIndex].amount = expenseTotal
           }
           if let incomeIndex = self.totals.firstIndex(where: { $0.type == "Incomes" }) {
               self.totals[incomeIndex].amount = incomeTotal
           }
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
    
        @Published var tagCount: Int = UserDefaults.standard.integer(forKey: "tagCount") {
            didSet {
                UserDefaults.standard.set(tagCount, forKey: "tagCount")
            }
        }

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
            listCategories()
            //objectWillChange.send()
            }
    
    
    func listCategories() {
        categoriesWithId.removeAll()
        self.expenseCategories.removeAll()
        self.tagCount = 0
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
                            self.tagCount += 1
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
    @Published var email = ""
    @Published var name = ""
    @Published var phone = ""
    @Published var password = ""
    @Published var passwordConfirmation = ""
    @Published var showNextView = false
    @Published var phoneRegex = #"^\d{10}$"#
    @Published var isPhoneNumberValid = true
    
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
    @Published var isShowAlarm = false
    @Published var alertItem: AlertItem?
    @Published var token = ""
    @Published var user = ""
    @Published var message = ""
    
    func login(email: String, password: String ) {
        self.isShowAlarm = false
        Auth.auth().signIn(withEmail: email, password: password){ result, error in
            if error != nil {
                print(error!.localizedDescription)
                if error!.localizedDescription != "An internal error has occurred, print and inspect the error details for more information."{
                    self.message = error!.localizedDescription
                }else{
                    self.message = "The password or email is incorrect"
                }
                self.isShowAlarm = true
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

