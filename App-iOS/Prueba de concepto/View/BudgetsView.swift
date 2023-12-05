//
//  BudgetsView.swift
//  Prueba de concepto
//
//  Created by Juan Sebastian Sanchez on 25/09/23.
//

import SwiftUI
import FirebaseFirestore



// Vista para "Budgets"
struct BudgetsView: View {
    @State private var dataArray: [Budget] = []
    @State private var invitations: [Budget] = []
    //@State private var dataArray: [BudgetsViewModel.Budget] = []
    @State private var isAddBudgetViewPresented = false
    @State private var  isNotificationViewPresented=false
    @StateObject private var functions = GlobalFunctions()
    @StateObject private var viewModel = BudgetsViewModel()
    
    

    func convertViewModelBudgets(_ viewModelBudgets: [BudgetsViewModel.Budget]) -> [Budget] {
        return viewModelBudgets.map { viewModelBudget in
            return Budget(documentID: viewModelBudget.documentID, name: viewModelBudget.name, date: viewModelBudget.date, total: viewModelBudget.total, contributions: viewModelBudget.contributions, type: Float(Int(viewModelBudget.type)))
        }
    }
    
    func fetchBudgetData() {
        
        viewModel.fetchBudgets { regularBudgets in
            if let regularBudgets = regularBudgets {
                dataArray += convertViewModelBudgets(regularBudgets)
            }
        }
        viewModel.fetchSharedBudgets { viewModelBudgets in
            if let viewModelBudgets = viewModelBudgets {
                dataArray = convertViewModelBudgets(viewModelBudgets)
                //dataArray = viewModelBudgets
                //print("Dataview:\(dataArray)")
            }
        }
    }
    
    func fetchInvitationsSharedBudgets() {

        viewModel.fetchInvitationsSharedBudgets { viewModelBudgets in
            if let viewModelBudgets = viewModelBudgets {
                invitations = convertViewModelBudgets(viewModelBudgets)

            }
        }
    }
    
    

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
        //
        VStack(){
            Spacer()
            VStack {
                HStack(spacing: 30) {
                    
                    NavigationLink(destination: AddBudgetView(), isActive: $isAddBudgetViewPresented) {
                        EmptyView()
                    }
                    NavigationLink(destination: NotificationView(invitations:$invitations), isActive: $isNotificationViewPresented) {
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
                                .foregroundColor(functions.isDaytime ? Color.blue : Color.white)
                        }}
                    
                    
                    VStack {
                        Image(systemName: "minus.rectangle.fill")
                            .resizable()
                            .frame(width: 40, height: 40) // Increase size
                            .foregroundColor(.red) // Set color to red
                            .background(Color.white.opacity(0.2)) // Background color
                            .cornerRadius(5)
                        Text("Remove")
                            .foregroundColor(functions.isDaytime ? Color.blue : Color.white)
                    }
                    .onTapGesture {
                        // Remove action logic here
                    }
                    Button(action: {
                        // Invitation button action logic here
                        isNotificationViewPresented.toggle()
                        fetchInvitationsSharedBudgets()
                    }) {
                        VStack {
                            Image(systemName: "person.badge.plus")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .foregroundColor(.orange)
                                .background(Color.white.opacity(0.2))
                                .cornerRadius(5)
                            Text("Invitations")
                                .foregroundColor(functions.isDaytime ? Color.blue : Color.white)
                        }
                    }
      
                }
                .padding(.horizontal)
                
                // Section: Individual
                Text("Individual")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top, 20)
                    .foregroundColor(functions.isDaytime ? Color.black : Color.white)
                List {
                    ForEach(dataArray.filter { $0.type == 0 }, id: \.self) { item in
                        NavigationLink(destination: BudgetItemDetailView(budget: item)) {
                            ItemRow(name: item.name, date: item.date, total: item.total,contributions: item.contributions)}
                    
                        }.onDelete(perform: delete)
                        
                        
                }

            
            // Section: Group
            Text("Group")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top, 20)
                .foregroundColor(functions.isDaytime ? Color.black : Color.white)
            
            List {
                ForEach(dataArray.filter { $0.type == 1 }, id: \.self) { item in
                    NavigationLink(destination: BudgetItemDetailView(budget: item)) {
                        ItemRow(name: item.name, date: item.date, total: item.total, contributions: item.contributions)}
                    }.onDelete(perform: delete)
                
            }.foregroundColor(functions.isDaytime ? Color.black : Color.white)
        }.foregroundColor(functions.isDaytime ? Color.black : Color.white)
        .onAppear {
                    fetchBudgetData()
                }
        Spacer()
    }
        .background(functions.isDaytime ? Color.white : Color(red: 23/255, green: 24/255, blue: 25/255))
    }
    func delete(at offsets: IndexSet) {
        dataArray.remove(atOffsets: offsets)
    }
}



struct ItemRow: View {
    @StateObject private var functions = GlobalFunctions()
    var name: String
    var date: Date
    var total: Float
    var contributions: Float

    var body: some View {
        HStack {
            VStack {
                Text(name)
                    .font(.headline)
                    .frame(width: 100)

                Text(formatDate(date)) // Display the formatted date
                    .font(.subheadline)
                
            }

            Spacer()
            
            

            if total != 0 {
                let percentage = (contributions * 100) / total
                // Now, use `percentage` to create the text
                Text(String(format: "%.1f%%", percentage)).font(.subheadline)
            } else {
                // Handle the case when total is zero (division by zero)
                Text("0%").font(.subheadline)
            }
                
        }
        .padding(.horizontal)
        .padding(.vertical, 5)
        .background(functions.isDaytime ? Color.white : Color(red: 23/255, green: 24/255, blue: 25/255))
    }
    
    // Function to format Date to String
    func formatDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        return dateFormatter.string(from: date)

    }
}
  struct BudgetsView_Previews: PreviewProvider {
      static var previews: some View {
          BudgetsView()
      }
  }

  struct AddBudgetView: View {
      @State private var budgetName = ""
      @State private var budgetAmount = 0
      @ObservedObject var viewModel = BudgetsViewModel()
      @State private var budgetDate = Date()
      @State private var selectedType = 0 // 0 for Individual, 1 for Group

      @State private var memberName = ""
      @State private var groupMembers: [String] = []
      @State private var contributions: [Double] = []
      @StateObject private var functions = GlobalFunctions()
      
      
      @State private var showNameList = false
      @State private var userIDsAndEmails: [String: String] = [:]
      
      @Environment(\.presentationMode) var presentationMode

      private func fetchUserEmailsAndIDs() {
          viewModel.fetchUserEmailsAndIDs { emailsAndIDs in
              if let emailsAndIDs = emailsAndIDs {
                  // Store the fetched emails and IDs in a dictionary
                  userIDsAndEmails = emailsAndIDs
              } else {
                  // Handle error fetching emails and IDs from Firestore
              }
          }
      }

      
      private static let formatter: NumberFormatter = {
              let formatter = NumberFormatter()
              formatter.numberStyle = .decimal
          formatter.maximumFractionDigits = 0
          formatter.maximumIntegerDigits = 20
              return formatter
          }()
      
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
          VStack{
          VStack {
              Text("Name")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .offset(x: 20)
                    .foregroundColor(functions.isDaytime ? Color.black : Color.white)
                  
              
              TextField("Enter name", text: $budgetName)
                  .textFieldStyle(RoundedBorderTextFieldStyle())
                  .padding(.horizontal)
                  .onChange(of: budgetName) { newValue in
                                              if newValue.count > 30 {
                                                  budgetName = String(newValue.prefix(30))
                                              }
                      if newValue.trimmingCharacters(in: .whitespaces).isEmpty {
                                                      budgetName = ""
                                                                 }
                                          }
              Text("Amount")
                  .font(.headline)
                  .frame(maxWidth: .infinity, alignment: .leading)
                  .offset(x: 20)
                  .foregroundColor(functions.isDaytime ? Color.black : Color.white)
              
              TextField("Enter amount", value: $budgetAmount, formatter: Self.formatter).keyboardType(.numberPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding(.horizontal)
              
              
              Text("Date")
                  .font(.headline)
                  .frame(maxWidth: .infinity, alignment: .leading)
                  .offset(x: 20)
                  .foregroundColor(functions.isDaytime ? Color.black : Color.white)
              
              DatePicker("", selection: $budgetDate, displayedComponents: .date)
                  .datePickerStyle(DefaultDatePickerStyle())
                  .padding(.horizontal)
                  .foregroundColor(functions.isDaytime ? Color.black : Color.white)
              
              
              Text("Type")
                  .font(.headline)
                  .frame(maxWidth: .infinity, alignment: .leading)
                  .offset(x: 20)
                  .foregroundColor(functions.isDaytime ? Color.black : Color.white)
              
              Picker(selection: $selectedType, label: Text("Type")) {
                  Text("Individual").tag(0)
                  Text("Group").tag(1)
              }
              .pickerStyle(SegmentedPickerStyle())
              .padding(.horizontal)
              
              if selectedType == 1 {
                  NavigationLink(destination: NameListView(userIDsAndEmails: $userIDsAndEmails,
                                                           budgetName: $budgetName,
                                                           budgetAmount: $budgetAmount,
                                                           budgetDate: $budgetDate)
                                 , isActive: $showNameList) {
                                  Text("Add Group Members")
                              }
                  .onAppear {
                      fetchUserEmailsAndIDs()
                          }
              }
              
              Button(action: {
                  viewModel.createBudget(name: budgetName, total: Float(budgetAmount), date: budgetDate, type: selectedType)
                  budgetName=""
                  budgetAmount=0
                  presentationMode.wrappedValue.dismiss()
                  
                  
              }) {
                  Text("Add")
                      .foregroundColor(.white)
                      .padding()
                      .background(Color.green)
                      .cornerRadius(10)
              }
              .padding()
              .opacity(selectedType == 0 ? 1.0 : 0.0)
              .disabled(selectedType != 0)
          }
              Spacer()
          }
          .background(functions.isDaytime ? Color.white : Color(red: 23/255, green: 24/255, blue: 25/255))
      }
  }

  struct AddBudgetView_Previews: PreviewProvider {
      static var previews: some View {
          AddBudgetView()
  }
  }


struct BudgetItemDetailView: View {
    @StateObject private var functions = GlobalFunctions()
    var budget: Budget // The budget item to display
    @ObservedObject var viewModel = BudgetsViewModel()
    @State private var newContribution = 0
    @Environment(\.presentationMode) var presentationMode
    
    
   
    
    
    var body: some View {
        
            ZStack() {
                Color(red: 21/255, green: 191/255, blue: 129/255).edgesIgnoringSafeArea(.all)
                VStack {
                    Text(budget.name)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
            }.frame(maxWidth: 400, maxHeight: 60)
            //Spacer()
                ZStack {
                    Circle()
                        .stroke(lineWidth: 8.0)  // Decrease the line width to make the circle smaller
                        .opacity(0.3)
                        .foregroundColor(Color.gray)
                        .frame(width: 130, height: 130)  // Adjust the frame size to control the circle's size
                    
                    Circle()
                        .trim(from: 0.0, to: CGFloat(min(budget.contributions / budget.total, 1.0)))
                        .stroke(style: StrokeStyle(lineWidth: 10.0, lineCap: .round, lineJoin: .round))
                        .foregroundColor(Color.green)
                        .rotationEffect(Angle(degrees: -90))
                        .frame(width: 130, height: 130)  // Match the frame size with the outer circle
                    
                    if budget.total != 0 {
                        let percentage = (budget.contributions * 100) / budget.total
                        Text(String(format: "%.1f%%", percentage))
                            .font(.title)
                            .fontWeight(.bold)
                    } else {
                        Text("0%")
                            .font(.title)
                            .fontWeight(.bold)
                    }
                }
                .padding()
                
                
                Text("\(formatDate(budget.date))")
                    .font(.headline)
                    .padding()
                    
        
                
                Text("$ " + String(budget.contributions)+"/ $ " + String(budget.total))
                    .font(.headline)
                    .padding()
                    
                
                
                //Spacer()
                
                HStack {
                    TextField("Enter amount", text: Binding(
                        get: { String(newContribution) },
                        set: {
                            if let value = NumberFormatter().number(from: $0)?.intValue {
                                newContribution = value
                            }
                        }
                    ))
                    .keyboardType(.numberPad)
                    .font(.subheadline)
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 1))


                
                
                Button(action: {
                    if budget.type == 0 {
                        viewModel.updateContributions(newContributions: Float(newContribution), documentID: budget.documentID ?? "", currentContributions: budget.contributions ) { success in
                            if success {
                                // Handle success
                                newContribution = 0
                                presentationMode.wrappedValue.dismiss()
                            }
                        }
                    } else {
                        viewModel.updateContributionsShared(newContributions: Float(newContribution), documentID: budget.documentID ?? "", currentContributions: budget.contributions ){ success in
                            if success {
                                // Handle success
                                newContribution = 0
                                presentationMode.wrappedValue.dismiss()
                            }}
                        
                    }
                    
                }) {
                    Text("Add Contribution")
                        .foregroundColor(.green)
                }.padding()
            
                
            
            
                
            
        Spacer()
        
    }
    
    
    func formatDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        return dateFormatter.string(from: date)
    }
}



struct NameListView: View {
    @Binding var userIDsAndEmails: [String: String] // Dictionary containing user IDs and emails
    @Binding var budgetName: String
    @Binding var budgetAmount: Int
    @Binding var budgetDate: Date
    @State private var selectedType: Int = 1
    @State private var searchText: String = ""
    @State private var isSearching: Bool = false
    @State private var checkedItems: Set<String> = []
    @State private var checkedItemsUserIds: Set<String> = []
    @ObservedObject var viewModel = BudgetsViewModel()
    @Environment(\.presentationMode) var presentationMode
    

    var body: some View {
        NavigationView {

            VStack {
                ZStack() {
                    Color(red: 21/255, green: 191/255, blue: 129/255).edgesIgnoringSafeArea(.all)
                    VStack {
                        Text("Group Members")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                }.frame(maxWidth: 400, maxHeight: 60)
                
                SearchBar(text: $searchText, isSearching: $isSearching)

                List {
                    ForEach(userIDsAndEmails.filter { key, value in
                        searchText.isEmpty ? true : value.localizedCaseInsensitiveContains(searchText)
                    }, id: \.key) { key, value in
                        HStack {
                            Text(value) // Display email
                            Spacer()
                            Image(systemName: checkedItems.contains(value) ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(checkedItems.contains(value) ? .blue : .gray)
                        }
                        .onTapGesture {
                            toggleCheck(for: value)
                        }
                    }
                }
               // .navigationBarTitle("Group Members")
         

                Button(action: {
                    addCheckedNames()
                    viewModel.createSharedBudget(
                        name: budgetName,
                        total: Float(budgetAmount),
                        date: budgetDate,
                        type: selectedType,
                        userIDs: checkedItemsUserIds)
                    dismissToFirstView()
                    
                }) {
                    Text("Add Group Budget")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(10)
                }
                
                .padding()

            }
        }
    }

    func toggleCheck(for email: String) {
        if checkedItems.contains(email) {
            checkedItems.remove(email)
        } else {
            checkedItems.insert(email)
        }
    }

    func addCheckedNames() {
        for email in checkedItems {
            if let userID = userIDsAndEmails.first(where: { $0.value == email })?.key {
                print("Selected: Email: \(email), UserID: \(userID)")
                // Further actions with selected email and userID
                checkedItemsUserIds.insert(userID)
            }
        }
    }
    
    func dismissToFirstView() {
        presentationMode.wrappedValue.dismiss() // Dismiss the third view
        presentationMode.wrappedValue.dismiss() // Dismiss the second view
    }
    
}


struct SearchBar: View {
    @Binding var text: String
    @Binding var isSearching: Bool

    var body: some View {
        HStack {
            TextField("Search", text: $text)
                .padding(.leading, 24)
                .onChange(of: text) { _ in
                    isSearching = !text.isEmpty
                }

            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
                .padding(.horizontal)
                .onTapGesture {
                    isSearching = true
                }

            if isSearching {
                Button(action: {
                    text = ""
                    isSearching = false
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
                .padding(.trailing)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
    }
}



struct NotificationView: View {
    @Binding var invitations: [Budget]
    @ObservedObject var viewModel = BudgetsViewModel()
    @State private var hiddenIndices: Set<Int> = []

    var body: some View {
        VStack {
            
            ZStack() {
                Color(red: 21/255, green: 191/255, blue: 129/255).edgesIgnoringSafeArea(.all)
                VStack {
                    Text("Invitations for Group Budgets")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
            }.frame(maxWidth: 400, maxHeight: 60)

            List {
                ForEach(invitations.indices, id: \.self) { index in
                    if !hiddenIndices.contains(index) {
                        let invitation = invitations[index]
                        HStack {
                            Text(invitation.name)
                            
                            Spacer()
                            
                            HStack(spacing: 20) {
                                Image(systemName: "checkmark.circle")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(.green)
                                    .onTapGesture {
                                        viewModel.updateSharedBudgetUsersPending(documentID: invitation.documentID ?? "")
                                        hideInvitation(at: index)
                                    }
                                
                                Image(systemName: "x.circle")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(.red)
                                    .onTapGesture {
                                        viewModel.deleteInvitation(documentID: invitation.documentID ?? "")
                                        hideInvitation(at: index)
                                    }
                            }
                        }
                        .padding()
                    }
                }
            }
        }
    }

    func hideInvitation(at index: Int) {
        hiddenIndices.insert(index)
    }
}

