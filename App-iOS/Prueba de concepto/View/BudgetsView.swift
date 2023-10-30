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
    //@State private var dataArray: [BudgetsViewModel.Budget] = []
    @State private var isAddBudgetViewPresented = false
    @StateObject private var functions = GlobalFunctions()
    @StateObject private var viewModel = BudgetsViewModel()
    
    

    func convertViewModelBudgets(_ viewModelBudgets: [BudgetsViewModel.Budget]) -> [Budget] {
        return viewModelBudgets.map { viewModelBudget in
            return Budget(documentID: viewModelBudget.documentID, name: viewModelBudget.name, date: viewModelBudget.date, total: viewModelBudget.total, contributions: viewModelBudget.contributions, type: Float(Int(viewModelBudget.type)))
        }
    }
    
    func fetchBudgetData() {
        viewModel.fetchBudgets { viewModelBudgets in
            if let viewModelBudgets = viewModelBudgets {
                dataArray = convertViewModelBudgets(viewModelBudgets)
                //dataArray = viewModelBudgets
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
      
      private static let formatter: NumberFormatter = {
              let formatter = NumberFormatter()
              formatter.numberStyle = .decimal
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
                  Text("Members")
                      .font(.headline)
                      .frame(maxWidth: .infinity, alignment: .leading)
                      .offset(x: 20)
                      .foregroundColor(functions.isDaytime ? Color.black : Color.white)
                  
                  TextField("Enter member name", text: $memberName)
                      .textFieldStyle(RoundedBorderTextFieldStyle())
                      .padding(.horizontal)
                  
                  Button(action: {
                      groupMembers.append(memberName)
                      memberName = ""
                  }) {
                      Text("Add Member")
                          .foregroundColor(.green)
                  }
              }
              
              Button(action: {
                  viewModel.createBudget(name: budgetName, total: Float(budgetAmount), date: budgetDate, type: selectedType)
                  budgetName=""
                  budgetAmount=0
                  
                  
              }) {
                  Text("Add")
                      .foregroundColor(.white)
                      .padding()
                      .background(Color.green)
                      .cornerRadius(10)
              }.padding()
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
                    viewModel.updateContributions(newContributions: Float(newContribution), documentID: budget.documentID ?? "", currentContributions: budget.contributions ) { success in
                        if success {
                            // Handle success
                            newContribution=0
                            presentationMode.wrappedValue.dismiss()
                            
                        } else {
                            // Handle failure
                        }
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


