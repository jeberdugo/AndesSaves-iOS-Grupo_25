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
    
    init() {
        loadBalanceFromUserDefaults()
    }
    
    
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
    
    
    func loadBalanceFromUserDefaults() {
        if let savedBalance = UserDefaults.standard.value(forKey: "userBalance") as? Float {
            balance = savedBalance
        }
    }
    
    func saveBalanceToUserDefaults(_ balance: Float) {
        UserDefaults.standard.set(balance, forKey: "userBalance")
    }
    
    func removeBalanceFromUserDefaults() {
        UserDefaults.standard.removeObject(forKey: "userBalance")
    }

    func updateBalanceInCache(newBalance: Float) {
        balance = newBalance
        saveBalanceToUserDefaults(newBalance)
        // Resto de tu lógica de actualización
    }

    
    func addTransaction(amount: Int, category: String, date: Date, imageUri: String, name: String, source: String, type: String, image: UIImage?){
        let user = Auth.auth().currentUser
        if let user = user{
            let db = Firestore.firestore()
            let transactionsCollection = db.collection("users").document(user.uid).collection("transactions")
            // Create a new transaction document with a unique identifier
                var ref: DocumentReference? = nil
            
                let group = DispatchGroup()
                let timerDuration: TimeInterval = 0.5
                let dispatchTime = DispatchTime.now() + timerDuration
                var receivedResponse = false
            
                    group.enter()
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
                            DispatchQueue.global().asyncAfter(deadline: dispatchTime) {
                                let timestamp = Timestamp(date: date)
                                let transaction = Transaction(amount: Float(amount),
                                                              category: category,
                                                              date:  timestamp,
                                                              imageUri: imageUri,
                                                              name: name,
                                                              source: source, transactionId: "0", type: type )
                                self.balance = self.balance + Float(amount)
                                self.updateBalance(newBalance: self.balance)
                                self.loadBalanceFromUserDefaults()
                        if image != nil{
                                    self.saveImageFromDirectory(fileName: name, image: image)
                                }
                                self.isAddingTransaction = false
                               // self.historyViewModel.transactions.append(transaction)
                                //self.historyViewModel.saveTransactionsToCache()
                            }
                        } else {
                            receivedResponse = true
                            group.leave()
                            self.balance = self.balance + Float(amount)
                            self.updateBalance(newBalance: self.balance)
                            print("Transaction added with ID: \(ref!.documentID)")
                            if image != nil{
                                //self.saveImageFromDirectory(fileName: ref!.documentID, image: image)
                                self.uploadImage(fileName: ref!.documentID, image: image)
                                self.saveImageFromDirectory(fileName: ref!.documentID, image: image)
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
                    self.saveBalanceToUserDefaults(newBalance)
                } else {
                    // Update successful
                    print("Balance updated successfully")
                    self.removeBalanceFromUserDefaults()
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
        MenuItem(title: "News", imageName: "News"),
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
    
    init() {
        if let transactionsData = UserDefaults.standard.data(forKey: "cachedTransactions") {
            if let transactionDictionaries = try? PropertyListSerialization.propertyList(from: transactionsData, options: [], format: nil) as? [[String: Any]] {
                self.transactions = transactionDictionaries.map { dictionary in
                    return Transaction(
                        amount: dictionary["amount"] as? Float ?? 0,
                        category: dictionary["category"] as? String ?? "",
                        date: dictionary["date"] as? Timestamp ?? Timestamp(),
                        imageUri: dictionary["imageUri"] as? String ?? "",
                        name: dictionary["name"] as? String ?? "",
                        source: dictionary["source"] as? String ?? "",
                        transactionId: dictionary["transactionId"] as? String ?? "",
                        type: dictionary["type"] as? String ?? ""
                    )
                }
            }
        }
    }
 
    func saveTransactionsToCache() {
        // Convert transactions to an array of dictionaries
        let transactionDictionaries: [[String: Any]] = transactions.map { transaction in
            return [
                "amount": transaction.amount,
                "category": transaction.category,
                "date": transaction.date, // You might need to convert this to a compatible format
                "imageUri": transaction.imageUri,
                "name": transaction.name,
                "source": transaction.source,
                "type": transaction.type
            ]
        }

        // Save the array of dictionaries to a Plist
        if let transactionsData = try? PropertyListSerialization.data(fromPropertyList: transactionDictionaries, format: .binary, options: 0) {
            UserDefaults.standard.set(transactionsData, forKey: "cachedTransactions")
        }
    }

    func listTransactions() {
        // Try to load transactions from cache
        if let cachedTransactionsData = UserDefaults.standard.data(forKey: "cachedTransactions"),
           let cachedTransactionDictionaries = try? PropertyListSerialization.propertyList(from: cachedTransactionsData, options: [], format: nil) as? [[String: Any]] {
            
            let cachedTransactions = cachedTransactionDictionaries.compactMap { dictionary in
                Transaction(
                    amount: dictionary["amount"] as? Float ?? 0,
                    category: dictionary["category"] as? String ?? "",
                    date: dictionary["date"] as? Timestamp ?? Timestamp(),
                    imageUri: dictionary["imageUri"] as? String ?? "",
                    name: dictionary["name"] as? String ?? "",
                    source: dictionary["source"] as? String ?? "",
                    transactionId: dictionary["transactionId"] as? String ?? "",
                    type: dictionary["type"] as? String ?? ""
                )
            }
            
            // Use cached transactions while fetching from Firebase
            self.transactions = cachedTransactions
        }

        if let user = Auth.auth().currentUser {
            let db = Firestore.firestore()
            let transactionsCollection = db.collection("users").document(user.uid).collection("transactions")

            transactionsCollection.getDocuments { [weak self] (snapshot, error) in
                guard let self = self else { return }

                if let error = error {
                    print("Firebase Error: \(error.localizedDescription)")
                }

                if let snapshot = snapshot {
                    var fetchedTransactions = [Transaction]()

                    for document in snapshot.documents {
                        let data = document.data()
                        let amount = data["amount"] as? Float ?? 0
                        let category = data["category"] as? String ?? ""
                        let date = data["date"] as? Timestamp ?? Timestamp()
                        let imageUri = data["imageUri"] as? String ?? ""
                        let name = data["name"] as? String ?? ""
                        let source = data["source"] as? String ?? ""
                        let transactionId = document.documentID
                        let type = data["type"] as? String ?? ""

                        let transaction = Transaction(
                            amount: amount,
                            category: category,
                            date: date,
                            imageUri: imageUri,
                            name: name,
                            source: source,
                            transactionId: transactionId,
                            type: type
                        )

                        fetchedTransactions.append(transaction)
                    }

                    // Update the transaction list
                    self.transactions = fetchedTransactions

                    // Save the fetched transactions to the cache
                    self.saveTransactionsToCache()
                    self.expensesByMonth()
                    self.calculateTotals()
                    self.listPredictions()
                    self.updateBalanceDays(transactions: self.transactions)
            }
        }
    }
   }
    
    
    @Published var negativeBalanceDaysLiveData = 0
           @Published var positiveBalanceDaysLiveData = 0
           @Published var evenBalanceDaysLiveData = 0

           func updateBalanceDays(transactions: [Transaction]) {
               var dailyBalances: [Date: Float] = [:]

               for transaction in transactions {
                   let dateWithoutTime = Calendar.current.startOfDay(for: transaction.date.dateValue())
                   let amount = transaction.type == "Income" ? transaction.amount : -transaction.amount

                   if dailyBalances[dateWithoutTime] != nil {
                       dailyBalances[dateWithoutTime]! += amount
                   } else {
                       dailyBalances[dateWithoutTime] = amount
                   }
               }

               for (_, balance) in dailyBalances {
                   if balance > 0 {
                       positiveBalanceDaysLiveData += 1
                   } else if balance < 0 {
                       negativeBalanceDaysLiveData += 1
                   } else {
                       evenBalanceDaysLiveData += 1
                   }
               }
           }
    
    
    func calculateFinalBalanceForMonth(transactions: [Transaction], year: Int, month: Int) -> Float {
        let calendar = Calendar.current

        let firstDayOfMonth = calendar.date(from: DateComponents(year: year, month: month, day: 1))!
        let lastDayOfMonth = calendar.date(from: DateComponents(year: year, month: month + 1, day: 1))!

        var balance: Float = 0

        for transaction in transactions {
            let transactionDate = transaction.date.dateValue()

            if transactionDate >= firstDayOfMonth && transactionDate < lastDayOfMonth {
                let amount = transaction.type == "Income" ? transaction.amount : -transaction.amount
                balance += amount
            }
        }

        return balance
    }
    
    
    @Published public var prediction: Prediction? = nil
        func listPredictions() {
            let date = Date()
                    let calendar = Calendar.current
                    let month = calendar.component(.month, from: date)
                    let year = calendar.component(.year, from: date)

            if let user = Auth.auth().currentUser {
                let db = Firestore.firestore()
                let predictions = db.collection("users").document(user.uid).collection("predictions").whereField("year", isEqualTo: year).whereField("month", isEqualTo:  month)

                predictions.getDocuments { (snapshot, error) in
                    guard error == nil else {
                        print(error!.localizedDescription)
                        return
                    }

                    if let snapshot = snapshot {
                        for document in snapshot.documents{
                                let data = document.data()

                                let amount = data["predicted_expense"] as? Float ?? 0
                                let yearIn = data["year"] as? Int ?? 0
                                let monthIn = data["month"] as? Int ?? 0


                                let predicttionIn = Prediction(predicted_expense: amount, month: monthIn, year: yearIn )
                                self.prediction = predicttionIn
                    }

                }
                }
            }
        }
    
    
    func deleteTransaction(transactionId: String, name: String) {
        if let user = Auth.auth().currentUser {
            let db = Firestore.firestore()
            let transactionsCollection = db.collection("users").document(user.uid).collection("transactions")

            let transactionDocument = transactionsCollection.document(transactionId)

            let timerDuration: TimeInterval = 0.5
            let dispatchTime = DispatchTime.now() + timerDuration
            var receivedResponse = false

            var deletionError: Error?
            transactionDocument.delete { error in
                receivedResponse = true
                deletionError = error
            }

            DispatchQueue.global().asyncAfter(deadline: dispatchTime) {

                if let error = deletionError {
                    print("Error deleting transaction: \(error.localizedDescription)")
                    
    
                    if let index = self.transactions.firstIndex(where: { $0.name == name }) {
                        self.transactions.remove(at: index)
                    }
                    self.saveTransactionsToCache()
                    self.deleteImageFromDirectory(fileName: transactionId)
                    self.deleteImageFromDirectory(fileName: name)
                } else {
                    
                    print("Transaction deleted successfully")
                    if let index = self.transactions.firstIndex(where: { $0.transactionId == transactionId }) {
                        self.transactions.remove(at: index)
                        self.deleteImageFromDirectory(fileName: transactionId)
                        self.deleteImageFromDirectory(fileName: name)
                        self.deleteImage(fileName: transactionId)
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
    
    // Key for caching budgets in UserDefaults
       private let budgetsCacheKey = "BudgetsCache"

       @Published var budgets: [Budget] = []

       init() {
           loadCachedBudgets()
       }
    
    // Update cached budgets
    private func updateCachedBudgets() {
        do {
            let budgetData = try JSONEncoder().encode(budgets)
            UserDefaults.standard.set(budgetData, forKey: budgetsCacheKey)
        } catch {
            print("Error encoding budgets for caching: \(error.localizedDescription)")
        }
    }

    // Load cached budgets from UserDefaults
    private func loadCachedBudgets() {
        if let cachedBudgetData = UserDefaults.standard.data(forKey: budgetsCacheKey),
           let cachedBudgets = try? JSONDecoder().decode([Budget].self, from: cachedBudgetData) {
            budgets = cachedBudgets
        }
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
                
                // Update the cached budget data
                let newBudget = Budget(documentID: ref!.documentID, name: name, total: total, contributions: Float(contributions), user: user.uid, date: date, type: type)
                self.budgets.append(newBudget)
                self.updateCachedBudgets()
                
            }
        }
    }
    
   
    
    func fetchBudgets(completion: @escaping ([Budget]?) -> Void) {        // Check if cached budgets are available
        if !budgets.isEmpty {
            completion(self.budgets)
        }
        
    
        
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
                
                self.budgets = budgets
                self.updateCachedBudgets()

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
                    
                    // Update the cached budget data
                    if let index = self.budgets.firstIndex(where: { $0.documentID == documentID }) {
                        self.budgets[index].contributions = updatedContributions
                        self.updateCachedBudgets()
                    }
                    
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
            let timerDuration: TimeInterval = 0.5
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
                            }
                        } else {
                            receivedResponse = true
                            group.leave()
                            print("Transaction added with ID: \(ref!.documentID)")
                        }
                    }
                }
            listCategories()
            //objectWillChange.send()
        }
    
    
    func listCategories() {
        // Load tags from cache (if available)
        if let cachedCategories = UserDefaults.standard.data(forKey: "cachedCategories"),
           let cachedCategoriesWithId = UserDefaults.standard.data(forKey: "cachedCategoriesWithId") {
            if let decodedCategories = try? JSONDecoder().decode([String].self, from: cachedCategories),
               let decodedCategoriesWithId = try? JSONDecoder().decode([CategoryWithId].self, from: cachedCategoriesWithId) {
                DispatchQueue.main.async {
                    self.expenseCategories = decodedCategories
                    self.categoriesWithId = decodedCategoriesWithId
                }
            }
        }
        
        // Fetch data from Firebase
        if let user = Auth.auth().currentUser {
            let db = Firestore.firestore()
            let categoriesCollection = db.collection("users").document(user.uid).collection("tags")

            self.expenseCategories.removeAll { $0 == "Add" }
            self.categoriesWithId.removeAll { $0.name == "Add" }
            
            categoriesCollection.getDocuments { (snapshot, error) in
                // Handle the data from Firebase
                if let snapshot = snapshot {
                    var categories = [String]()
                    var categoriesWithId = [CategoryWithId]()

                    for document in snapshot.documents {
                        let data = document.data()
                        let name = data["name"] as? String ?? ""
                        let categoryId = document.documentID

                        let category = CategoryWithId(name: name, categoryId: categoryId)
                        categoriesWithId.append(category)
                        categories.append(name)
                    }
                    
                    let category = CategoryWithId(name: "Add", categoryId: "0")
                                        categoriesWithId.append(category)

                    DispatchQueue.main.async {
                        self.expenseCategories = categories
                        self.categoriesWithId = categoriesWithId
                        self.tagCount = self.expenseCategories.count

                        if let categoriesData = try? JSONEncoder().encode(categories) {
                            UserDefaults.standard.set(categoriesData, forKey: "cachedCategories")
                        }

                        if let categoriesWithIdData = try? JSONEncoder().encode(categoriesWithId) {
                            UserDefaults.standard.set(categoriesWithIdData, forKey: "cachedCategoriesWithId")
                        }
                    }
                } else {
                    // Handle errors here
                    print(error?.localizedDescription ?? "Unknown error")
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
            let timerDuration: TimeInterval = 0.5
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
                } else {
                    // The deletion was successful
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
                UserDefaults.standard.set(true, forKey: "isLoggedIn")
                UserDefaults.standard.set(email, forKey: "userEmail")
                UserDefaults.standard.set(password, forKey: "userPass")

            }
        }
    }
    
    func autologin() {
        print("de")
        if UserDefaults.standard.bool(forKey: "isLoggedIn") == true {
            self.isLoggedIn = true
            let emailIn = UserDefaults.standard.string(forKey: "userEmail")
            let passIn = UserDefaults.standard.string(forKey: "userPass")
            self.login(email: emailIn!, password: passIn!)
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
    @Published public var isAlertShowing = false
    
    @AppStorage("notificationsEnabled") var notificationsEnabled = false
    
    @Published public var balance: Float = 0
    @Published public var email = ""
    @Published public var name  = ""
    @Published public var phone = ""
    @Published public var userId = ""
    
    func signOut(){
        do{
            try Auth.auth().signOut()
            UserDefaults.standard.set(false, forKey: "isLoggedIn")
            UserDefaults.standard.removeObject(forKey: "userEmail")
            UserDefaults.standard.removeObject(forKey: "userPass")
        } catch{
            print("DEBUG: Failed to sign out with error \(error.localizedDescription)")

            }
        }
    
    
    func fetchUser() {
        // Load user data from cache (if available)
        if let cachedUserData = UserDefaults.standard.data(forKey: "cachedUserData") {
            if let decodedUserData = try? JSONDecoder().decode(UserData.self, from: cachedUserData) {
                self.balance = decodedUserData.balance
                self.email = decodedUserData.email
                self.name = decodedUserData.name
                self.phone = decodedUserData.phone
                self.userId = decodedUserData.userId
            }
        }

        // Fetch user data from Firebase
        if let user = Auth.auth().currentUser {
            let db = Firestore.firestore()
            let usersCollection = db.collection("users")

            let group = DispatchGroup()
            var receivedResponse = false

            group.enter()

            usersCollection.getDocuments { (snapshot, error) in
                guard error == nil else {
                    // Handle errors here
                    DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
                        self.useCachedUserData()
                    }
                    group.leave()
                    return
                }

                if let snapshot = snapshot {
                    var userData: UserData?

                    for document in snapshot.documents {
                        let data = document.data()
                        let id = data["userId"] as? String ?? ""
                        if id == user.uid {
                            userData = UserData(
                                balance: data["balance"] as? Float ?? 0,
                                email: data["email"] as? String ?? "",
                                name: data["name"] as? String ?? "",
                                phone: data["phone"] as? String ?? "",
                                userId: id
                            )
                            break
                        }
                    }

                    if let userData = userData {
                        self.updateUserData(userData)
                    } else {
                        self.useCachedUserData()
                    }

                    receivedResponse = true
                    group.leave()
                }
            }

            // Use cached user data if no response within 0.5 seconds
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
                if !receivedResponse {
                    self.useCachedUserData()
                }
            }
        }
    }

    func updateUserData(_ userData: UserData) {
        self.balance = userData.balance
        self.email = userData.email
        self.name = userData.name
        self.phone = userData.phone
        self.userId = userData.userId

        // Save to cache
        if let userData = try? JSONEncoder().encode(userData) {
            UserDefaults.standard.set(userData, forKey: "cachedUserData")
        }
    }

    func useCachedUserData() {
        if let cachedUserData = UserDefaults.standard.data(forKey: "cachedUserData") {
            if let decodedUserData = try? JSONDecoder().decode(UserData.self, from: cachedUserData) {
                self.updateUserData(decodedUserData)
            }
        }
    }
    
    
    func addSuggestion(text: String, completion: @escaping (Bool) -> Void) {
        let user = Auth.auth().currentUser

        if let user = user {
            let db = Firestore.firestore()
            let suggestionsCollection = db.collection("users").document(user.uid).collection("suggestions")

            var ref: DocumentReference? = nil
            let group = DispatchGroup()

            group.enter()

            ref = suggestionsCollection.addDocument(data: ["text": text]) { error in
                DispatchQueue.main.async {
                    if let error = error {
                        // Handle error on the main thread
                        completion(false)
                        print("An error has occurred: \(error)")

                        // Show an alert here if needed
                    } else {
                        // Operation successful
                        group.leave()
                        print("Transaction added with ID: \(ref!.documentID)")
                        completion(true)
                    }
                }
            }

            // Optionally, add a timeout for the operation
            let timerDuration: TimeInterval = 0.5
            let dispatchTime = DispatchTime.now() + timerDuration

            // Wait for the operation to finish or timeout
            if group.wait(timeout: dispatchTime) == .timedOut {
                // Handle timeout if needed
                DispatchQueue.main.async {
                    completion(false)
                    print("Operation timed out.")
                }
            }
        }
    }


}

final class NewsViewModel: ObservableObject {
    @Published var news: [News] = [
        News(headline: "Breaking News 1", author: "John Doe", date: "Nov 1, 2023", content: "Lorem ipsum dolor sit amet, consectetur adipiscing elit.", image: "news1"),
        News(headline: "Important Update", author: "Jane Smith", date: "Nov 2, 2023", content: "Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.", image: "news2"),
        // Add more news items as needed
    ]
    
    @Published var newsWithId = [NewWithId]()
    
    func fetchNews() {
            // Load news data from cache (if available)
            if let cachedNewsData = UserDefaults.standard.data(forKey: "cachedNewsData") {
                if let decodedNewsData = try? JSONDecoder().decode([NewWithId].self, from: cachedNewsData) {
                    self.newsWithId = decodedNewsData
                }
            }

            // Fetch news data from Firebase
            if let user = Auth.auth().currentUser {
                let db = Firestore.firestore()
                let newsCollection = db.collection("News")

                let group = DispatchGroup()
                var receivedResponse = false

                group.enter()

                newsCollection.getDocuments { (snapshot, error) in
                    guard error == nil else {
                        // Handle errors here
                        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
                            self.useCachedNewsData()
                        }
                        group.leave()
                        return
                    }

                    if let snapshot = snapshot {
                        var newsData = [NewWithId]()

                        for document in snapshot.documents {
                            let data = document.data()
                            let id = document.documentID
                            let headline = data["headline"] as? String ?? ""
                            let author = data["author"] as? String ?? ""
                            let date = data["date"] as? String ?? ""
                            let content = data["content"] as? String ?? ""
                            let image = data["image"] as? String ?? ""

                            let news = NewWithId(newId: id, headline: headline, author: author, date: date, content: content, image: image)
                            newsData.append(news)
                        }

                        self.newsWithId = newsData

                        // Save to cache
                        if let newsData = try? JSONEncoder().encode(newsData) {
                            UserDefaults.standard.set(newsData, forKey: "cachedNewsData")
                        }

                        receivedResponse = true
                        group.leave()
                    }
                }

                // Use cached news data if no response within 0.5 seconds
                DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
                    if !receivedResponse {
                        self.useCachedNewsData()
                    }
                }
            }
        }

        // Function to use cached news data
        func useCachedNewsData() {
            if let cachedNewsData = UserDefaults.standard.data(forKey: "cachedNewsData") {
                if let decodedNewsData = try? JSONDecoder().decode([NewWithId].self, from: cachedNewsData) {
                    self.newsWithId = decodedNewsData
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

