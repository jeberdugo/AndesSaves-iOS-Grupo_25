//
//  ContentView.swift
//  Prueba de concepto
//
//  Created by Juan Sebastian Sanchez on 7/09/23.
//

import SwiftUI
import WebKit
import UserNotifications



struct FinanceApp: App {
    var body: some Scene {
        WindowGroup {
            LoginView()
        }
    }
}

struct ContentView: View {
    @State private var showAlert = false
    @StateObject private var viewModel = ContentViewModel()
    @StateObject private var functions = GlobalFunctions()
    @StateObject private var History = HistoryViewModel()
    let expenseCategories = ["Food", "Transport", "House", "Others"]
    
    var body: some View {
        NavigationView {
            ZStack() {
                Color(hex:"12CD8A").edgesIgnoringSafeArea(.all)
                
                VStack() {
                    Spacer(minLength: 20)
                    VStack() {
                        //Color(red: 78, green: 147, blue: 122)
                        Spacer(minLength: 5)
                        Text("BALANCE")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                       
                        Text("$\(String(format: "%.2f", 100))")
                            .font(.largeTitle)
                            .foregroundColor(.white)
                        
                        Button(action: {
                            viewModel.isAddingTransaction.toggle()
                        }) {
                            Text("Add Transaction")
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.black)
                                .cornerRadius(10)
                        }
                        .sheet(isPresented: $viewModel.isAddingTransaction) {

                            ZStack() {
                                //Color(red: 21/255, green: 191/255, blue: 129/255).edgesIgnoringSafeArea(.all)
                                if(viewModel.selectedType == 1){
                                    Color(hex:"EE446D ").edgesIgnoringSafeArea(.all)                                                                    }
                                else{
                                    Color(hex:"12CD8A").edgesIgnoringSafeArea(.all)                                  }
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
                                    TextField("Name", text: $viewModel.transactionName)
                                    TextField("Amount", text: $viewModel.transactionAmount)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .keyboardType(.decimalPad)
                                    TextField("Source", text: $viewModel.transactionSource)
                                }
                                
                                Section(header: Text("Type")) {
                                    Picker(selection: $viewModel.selectedType, label: Text("Type")) {
                                        Text("Income").tag(0)
                                        Text("Expense").tag(1)
                                    }
                                    .pickerStyle(SegmentedPickerStyle())
                                    .padding(.horizontal)                                    }
                                if viewModel.selectedType == 1 {
                                    Section(header: Text("Expense Category")) {
                                        Picker("Select Category", selection: $viewModel.selectedExpenseCategory) {
                                            ForEach(0..<expenseCategories.count) { index in
                                                Text(expenseCategories[index])
                                            }
                                        }
                                        .pickerStyle(SegmentedPickerStyle())
                                    }
                                }
                            }
                            Button(action: {
                                
                                if viewModel.selectedType == 1 && viewModel.balance-(Double(viewModel.transactionAmount) ?? 0.0) < 0 {
                                    showAlert = true
                                } else {
                                                // Add your action logic here to save the transaction
                                        }
                            }) {
                                Text("Add")
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(viewModel.selectedType == 1 ? Color(hex:"EE446D") : Color(hex:"12CD8A"))
                                    .cornerRadius(10)
                            }
                            .padding()
                            .alert(isPresented: $showAlert) {
                                Alert(
                                    title: Text("Warning: Negative Balance"),
                                    message: Text("Your expense transaction will result in a negative balance. Are you sure you want to proceed?"),
                                    primaryButton: .destructive(
                                        Text("Confirm"),
                                        action: {
                                            // Add your action logic here to handle the user's confirmation
                                        }
                                    ),
                                    secondaryButton: .cancel())
                            }

                            AddTransactionView()
                                .environmentObject(viewModel)
                                .environmentObject(functions)
                                .environmentObject(History)

                        }
                    }
                    Spacer(minLength: 10)
                    MainMenu()
                    
                }
            }
        }
        .navigationBarBackButtonHidden(/*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
        }
    }


struct AddTransactionView: View {
    @EnvironmentObject var viewModel: ContentViewModel
    @EnvironmentObject var functions: GlobalFunctions
    @EnvironmentObject var historyViewModel: HistoryViewModel
    @State private var showImagePicker = false
    @State private var image: Image? 
    @State private var isShowingImage = false
    let expenseCategories = ["Food", "Transport", "House", "Others"]
    
    var body: some View {
        ZStack() {
            if viewModel.selectedType == 1 {
                Color(hex: "EE446D").edgesIgnoringSafeArea(.all)
            } else {
                Color(hex: "12CD8A").edgesIgnoringSafeArea(.all)
            }
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
        VStack {
            Form {
                Section(header: Text("Transaction Details")) {
                    TextField("Name", text: $viewModel.transactionName)
                    TextField("Amount", text: $viewModel.transactionAmount)
                    TextField("Source", text: $viewModel.transactionSource)
                }
                
                Section(header: Text("Type")) {
                    Picker(selection: $viewModel.selectedType, label: Text("Type")) {
                        Text("Income").tag(0)
                        Text("Expense").tag(1)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                }
                
                if viewModel.selectedType == 1 {
                    Section(header: Text("Expense Category")) {
                        Picker("Select Category", selection: $viewModel.selectedExpenseCategory) {
                            ForEach(0..<expenseCategories.count) { index in
                                Text(expenseCategories[index])
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                }
            }
            
            if isShowingImage {
                ZStack {
                    image?
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200) // Specify the desired image size
                    
                    Button(action: {
                        // Add action logic to delete the image here
                        image = nil
                        isShowingImage = false
                    }) {
                        Image(systemName: "minus.circle")
                            .foregroundColor(.red) // Customize the color of the delete button
                    }
                    .padding(8) // Adjust the padding as needed
                }
                .onTapGesture {
                    isShowingImage.toggle()
                }
                .contextMenu {
                    Button("Delete") {
                        image = nil
                        isShowingImage = false
                    }
                }
            } else {
                Button(action: {
                    // Toggle the camera sheet
                    showImagePicker.toggle()
                }) {
                    Text("Take Photo")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(viewModel.selectedType == 1 ? Color(hex: "EE446D") : Color(hex: "12CD8A"))
                        .cornerRadius(10)
                }
                .padding()
            }
            
            Button(action: {
                // Add action logic here to save the transaction
                checkAndSendNotificationIfNeeded()
            }) {
                Text("Add")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(viewModel.selectedType == 1 ? Color(hex: "EE446D") : Color(hex: "12CD8A"))
                    .cornerRadius(10)
            }
            .padding()
        }
        .background(functions.isDaytime ? Color.white : Color(red: 23/255, green: 24/255, blue: 25/255))
        
        // Camera sheet
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $image, isShowingImage: $isShowingImage)
        }
    }
}


    
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: Image?
    @Binding var isShowingImage: Bool
    @Environment(\.presentationMode) var presentationMode
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = Image(uiImage: uiImage)
                parent.isShowingImage = true
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera // Set the source type to the camera
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {
    }
}


func checkAndSendNotificationIfNeeded() {
    print("Checking balance and sending notification")
    let History = HistoryViewModel()
    @State var showNegativeBalanceAlert = false
    if 5 < 0 {
        // Create a notification content
        
        let content = UNMutableNotificationContent()
        content.title = "Negative Balance Alert"
        content.body = "Your balance is negative. Please review your transactions."
        
        // Create a trigger for the notification (e.g., deliver immediately)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        
        // Create a notification request
        let request = UNNotificationRequest(identifier: "NegativeBalance", content: content, trigger: trigger)
        
        // Schedule the notification
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }
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
