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
import FirebaseFirestore
import CoreMotion
import Network

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
        var documentID: String?
        let name: String
        let total: Float
        var contributions: Float
        let user: String
        let date: Date
        let type: Int
    }

    func createBudget(name: String, total: Float, date: Date, type: Int) {
        let user = Auth.auth().currentUser
        let contributions = 0
        if let user = user {
            let db = Firestore.firestore()
            let budgetsCollection = db.collection("users").document(user.uid).collection("budgets")
            
            // Create a new budget document with a unique identifier
            var ref: DocumentReference? = nil
            ref = budgetsCollection.addDocument(data: [
                "name": name,
                "total": total,
                "contributions": contributions,
                "date": date,
                "type": type,
                "user": user.uid
            ]) { error in
                if let error = error {
                    print("Error creating budget: \(error.localizedDescription)")
                } else {
                    print("Budget created with ID: \(ref!.documentID)")
                    // You may perform additional actions here upon successful budget creation.
                }
            }
        }
    }
    
    func fetchBudgets(completion: @escaping ([Budget]?) -> Void) {
        let user = Auth.auth().currentUser
        if let user = user {
            let db = Firestore.firestore()
            let budgetsCollection = db.collection("users").document(user.uid).collection("budgets")
            
            // Fetch all budget documents from Firestore
            budgetsCollection.getDocuments { (snapshot, error) in
                if let error = error {
                    print("Error fetching budgets: \(error.localizedDescription)")
                    completion(nil)
                    return
                }
                
                var budgets: [Budget] = []
                
                if let snapshot = snapshot {
                    for document in snapshot.documents {
                    
                        let data = document.data()
                        
                        // Access the document ID for each document
                        let documentID = document.documentID
                        print("Document ID: \(documentID)")
                        
                        if let name = data["name"] as? String,
                           let total = data["total"] as? Float,
                           let dateTimestamp = data["date"] as? Timestamp,
                           let type = data["type"] as? Int {
                            
                            // Convert the Timestamp to a Date
                            let date = dateTimestamp.dateValue()
                            
                            // Calculate the amount (assuming you have the amount stored as a separate field in Firestore)
                            let contributions = data["contributions"] as? Float
                            
                            // Create a Budget instance
                            let budget = Budget(documentID: document.documentID, name: name, total: total, contributions: contributions ?? 0, user: user.uid, date: date, type: type)
                            budgets.append(budget)
                            
                            // Print the data for debugging
                            print("Fetched Budget: \(budget)")
                        }
                    }
                }
                
                completion(budgets)
            }
        }
    }
    
  
    func updateContributions(newContributions: Float, documentID: String, currentContributions: Float, completion: @escaping (Bool) -> Void) {
        let user = Auth.auth().currentUser
        if let user = user {
            let db = Firestore.firestore()
            let budgetsCollection = db.collection("users").document(user.uid).collection("budgets")
            
            // Get the document reference for the specific budget using its document ID
            let documentRef = budgetsCollection.document(documentID)
            
            // Update the contributions field
            documentRef.updateData([
                "contributions": newContributions + currentContributions
            ]) { error in
                if let error = error {
                    print("Error updating contributions for budget: \(error.localizedDescription)")
                    completion(false)
                } else {
                    print("Contributions updated for budget: \(documentID)")
                    
                    // Calculate the updated contributions value
                    let updatedContributions = newContributions + currentContributions
                    
                    // Pass the updated contributions value to the completion handler
                    completion(true)
                }
            }
        }
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
    
        private let categoriesCacheKey = "categoriesCache"
        private var isFetchingCategories = false
    
        private var pendingActions: [TagAction] = []
    
   
       init() {
           if let cachedCategoriesData = UserDefaults.standard.data(forKey: "cachedCategories") {
               if let cachedCategories = try? JSONDecoder().decode([String].self, from: cachedCategoriesData) {
                   self.expenseCategories = cachedCategories
               }
           }

           if let cachedCategoriesWithIdData = UserDefaults.standard.data(forKey: "cachedCategoriesWithId") {
               if let cachedCategoriesWithId = try? JSONDecoder().decode([CategoryWithId].self, from: cachedCategoriesWithIdData) {
                   self.categoriesWithId = cachedCategoriesWithId
               }
           }
       }
    
       private func saveCategoriesToCache() {
           if let categoriesData = try? JSONEncoder().encode(self.expenseCategories) {
               UserDefaults.standard.set(categoriesData, forKey: "cachedCategories")
           }

           if let categoriesWithIdData = try? JSONEncoder().encode(self.categoriesWithId) {
               UserDefaults.standard.set(categoriesWithIdData, forKey: "cachedCategoriesWithId")
           }
       }
    
    private let pendingActionsCacheKey = "pendingActionsCache"

    private func savePendingActionsToCache() {
        if let data = try? JSONEncoder().encode(pendingActions) {
            UserDefaults.standard.set(data, forKey: pendingActionsCacheKey)
        }
    }

    private func loadPendingActionsFromCache() {
        if let data = UserDefaults.standard.data(forKey: pendingActionsCacheKey),
           let actions = try? JSONDecoder().decode([TagAction].self, from: data) {
            pendingActions = actions
        }
    }
    
    func createCategory(name: String){
        let user = Auth.auth().currentUser
        if let user = user{
            let db = Firestore.firestore()
            let categoriesCollection = db.collection("users").document(user.uid).collection("tags")
            
                    var ref: DocumentReference? = nil
                    let group = DispatchGroup()
                    let timerDuration: TimeInterval = 1.5
                    let dispatchTime = DispatchTime.now() + timerDuration
                    var receivedResponse = false

                    group.enter()
                    ref = categoriesCollection.addDocument(data: [
                        "name": name
                    ]) { error in
                        if let error = error {
                            DispatchQueue.global().asyncAfter(deadline: dispatchTime) {
                                print("Error adding transaction: \(error.localizedDescription)")
                                let category = CategoryWithId(name: name, categoryId: "" )
                                let action = TagAction(type: .add, name: name, categoryId: "")
                                self.pendingActions.append(action)
                                self.categoriesWithId.append(category)
                                self.expenseCategories.append(name)
                                self.saveCategoriesToCache()
                                self.savePendingActionsToCache()
                                self.tagCount += 1
                            }
                        } else {
                            receivedResponse = true
                            group.leave()
                            print("Transaction added with ID: \(ref!.documentID)")
                            self.tagCount += 1
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
            
            let group = DispatchGroup()
            let timerDuration: TimeInterval = 1
            let dispatchTime = DispatchTime.now() + timerDuration
            var receivedResponse = false

            group.enter()
            categoriesCollection.getDocuments { (snapshot, error) in
                
                if let error = error {
                    DispatchQueue.global().asyncAfter(deadline: dispatchTime) {
                        print(error.localizedDescription)
                        self.saveCategoriesToCache()
                    }
                    return
                }
                
                if let snapshot = snapshot {
                    receivedResponse = true
                    for document in snapshot.documents {
                        let data = document.data()
                        let name = data["name"] as? String ?? ""
                        let categoryId = document.documentID
                        let category = CategoryWithId(name: name, categoryId: categoryId)
                        self.categoriesWithId.append(category)
                        self.expenseCategories.append(name)
                        self.tagCount += 1
                    }
                }
            }
        
        }
    }

    
    func deleteCategory(categoryId: String, name: String) {
        let user = Auth.auth().currentUser
        if let user = user {
            let db = Firestore.firestore()
            let categoriesCollection = db.collection("users").document(user.uid).collection("tags")

            let categoryDocument = categoriesCollection.document(categoryId)

            // Set up a timer to trigger after approximately 3 seconds
            let timerDuration: TimeInterval = 1.5
            let dispatchTime = DispatchTime.now() + timerDuration
            var receivedResponse = false

            // Make the Firestore request
            var deletionError: Error?
            categoryDocument.delete { error in
                receivedResponse = true
                deletionError = error
            }

            // Introduce a delay before handling the response or using cached data
            DispatchQueue.global().asyncAfter(deadline: dispatchTime) {
                // This block will be executed after the specified delay (3 seconds)

                if let error = deletionError {
                    // Handle the case where an error occurred during deletion
                    print("Error deleting category: \(error.localizedDescription)")
                    
                    let category = CategoryWithId(name: name, categoryId: categoryId)
                    let action = TagAction(type: .delete, name: name, categoryId: categoryId)
                    self.pendingActions.append(action)
                    
                    if let index = self.categoriesWithId.firstIndex(where: { $0.name == name }) {
                        self.categoriesWithId.remove(at: index)
                    }
                    if let index = self.expenseCategories.firstIndex(where: { $0 == name }) {
                        self.expenseCategories.remove(at: index)
                    }
                    
                    self.saveCategoriesToCache()
                    self.savePendingActionsToCache()
                    self.tagCount -= 1
                } else {
                    // The deletion was successful
                    print("Category deleted successfully")

                    // Optionally, remove the deleted category from your local array
                    if let index = self.categoriesWithId.firstIndex(where: { $0.categoryId == categoryId }) {
                        self.categoriesWithId.remove(at: index)
                    self.tagCount -= 1
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
    @Published public var isAlertShowing = false
}



class NetworkMonitor: ObservableObject {
    @Published var isConnected = true
    private let monitor = NWPathMonitor()
    
    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
            }
        }
        let queue = DispatchQueue(label: "NetworkMonitor")
        monitor.start(queue: queue)
    }
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

