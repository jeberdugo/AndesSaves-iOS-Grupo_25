//
//  BudgetsView.swift
//  Prueba de concepto
//
//  Created by Juan Sebastian Sanchez on 25/09/23.
//

import SwiftUI

// Vista para "Budgets"
struct BudgetsView: View {

    @State private var dataArray: [Budget] = [
        Budget(name: "House", date: "2023-09-25", percentage: "60%"),
        Budget(name: "Car", date: "2023-10-01", percentage: "80%"),
        Budget(name: "Bike", date: "2023-10-02", percentage: "40%"),
        Budget(name: "Boat", date: "2023-10-03", percentage: "70%")
    ]
    @State private var isAddBudgetViewPresented = false
      @StateObject private var functions = GlobalFunctions()

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
        Spacer()
        VStack(){
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
                ForEach(self.dataArray, id: \.self) { item in
                    ItemRow(name: item.name, date: item.date, percentage: item.percentage)
                        
                }.onDelete(perform: delete)
                .foregroundColor(functions.isDaytime ? Color.black : Color.white)            }
            
            
            
            // Section: Group
            Text("Group")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top, 20)
                .foregroundColor(functions.isDaytime ? Color.black : Color.white)
            
            ItemRow(name: "Europe", date: "2023-09-27", percentage: "75%")
                .foregroundColor(functions.isDaytime ? Color.black : Color.white)
            
            Divider()
                .foregroundColor(functions.isDaytime ? Color.black : Color.white)
            
            ItemRow(name: "Car", date: "2023-09-28", percentage: "90%")
                .foregroundColor(functions.isDaytime ? Color.black : Color.white)
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
      var name: String
      var date: String
      var percentage: String

      var body: some View {
          HStack {
              VStack{
                  Text(name)
                      .font(.headline)
                      .frame(width: 100)

                  Text(date)
                      .font(.subheadline)
              }


              Spacer()

              Text(percentage)
                  .font(.subheadline)
          }
          .padding(.horizontal)
          .padding(.vertical, 5)
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
                  viewModel.createBudget(name: budgetName, total: budgetAmount, date: budgetDate, type: selectedType)
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
    var name: String
    var date: String
    var totalContributions: Double // Total contributions
    var budgetAmount: Double // Budget amount
    var contributions: [Double] // All contributions
    @Binding var newContribution: String// Input for new contribution
    
    // Create a local non-optional variable
    @State private var contributionInput: String = ""
    
    
            

    var body: some View {
        ZStack() {
            Color(red: 21/255, green: 191/255, blue: 129/255).edgesIgnoringSafeArea(.all)
            VStack {
                Text(name)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
        }.frame(maxWidth: 400, maxHeight: 60)
        Spacer()
        
        VStack {
            // Percentage Chart
            ZStack {
                Circle()
                    .stroke(lineWidth: 15.0)
                    .opacity(0.3)
                    .foregroundColor(Color.gray)

                Circle()
                    .trim(from: 0.0, to: CGFloat(min(totalContributions / budgetAmount, 1.0)))
                    .stroke(style: StrokeStyle(lineWidth: 15.0, lineCap: .round, lineJoin: .round))
                    .foregroundColor(Color.green)
                    .rotationEffect(Angle(degrees: -90))

                Text("\(Int((totalContributions / budgetAmount) * 100))%")
                    .font(.title)
                    .fontWeight(.bold)
            }
            .padding()
            

            Text("\(date)")
                .font(.subheadline)
                .padding()
            

            Text("0/$\(totalContributions)")
                .font(.subheadline)
                .padding()

            
           

            

            // Input for New Contribution
            TextField("Enter Contribution", text: $newContribution)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.decimalPad)
                .padding()

            Button(action: {
                //if let amount = Double(newContribution) {
                  //      contributions.append(amount)
                    //    newContribution = ""
                    //}
            }) {
                Text("Add Contribution")
                    .foregroundColor(.green)
            }
            .padding()

            // History of Contributions
            Text("Contributions History:")
                .font(.headline)
                .padding(.top)

            List(contributions.map { String(format: "$%.2f", $0) }, id: \.self) { contribution in
                Text(contribution)
            }
        }
        //.navigationBarTitle(Text("Item Details"), displayMode: .inline)
    }
}

