//
//  ContentView.swift
//  Prueba de concepto
//
//  Created by Juan Sebastian Sanchez on 7/09/23.
//

import SwiftUI
import WebKit


struct FinanceApp: App {
    var body: some Scene {
        WindowGroup {
            LoginView()
        }
    }
}


struct ContentView: View {
    @State private var balance: Double = 1000.0 // Initial balance
    @State private var isAddingTransaction = false
    
    var body: some View {
        NavigationView {
            ZStack() {
                Color(hex:"12CD8A").edgesIgnoringSafeArea(.all)
                
                VStack() {
                    VStack() {
                        //Color(red: 78, green: 147, blue: 122)
                        Spacer(minLength: 5)
                        Text("Balance")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("$\(String(format: "%.2f", balance))")
                            .font(.largeTitle)
                            .foregroundColor(.white)
                        
                        Button(action: {
                            isAddingTransaction.toggle()
                        }) {
                            Text("Add Transaction")
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.black)
                                .cornerRadius(10)
                        }
                        .sheet(isPresented: $isAddingTransaction) {
                            // Add transaction view goes here
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

struct MenuItem {
    let title: String
    let imageName: String
}

// MENU PRINCIPAL
struct MainMenu: View {
    var menuItems: [MenuItem] = [
        MenuItem(title: "History", imageName: "History"),
        MenuItem(title: "Budgets", imageName: "Budgets"),
        MenuItem(title: "Tags", imageName: "Tags"),
        MenuItem(title: "Summary", imageName: "Summary"),
        MenuItem(title: "Accounts", imageName: "Accounts"),
        MenuItem(title: "Settings", imageName: "Settings")
    ]
    
    var body: some View {
        VStack {
            
            ZStack {
                    Rectangle()
                    .fill(Color.white)
                        .mask(TopRoundedRectangle(radius: 30))
                        .overlay(
                            RoundedRectangle(cornerRadius: 30)
                                .fill(Color.white)
                                .shadow(radius: 3, x: 0, y: -3)
                            
                        )
                        .edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
                
            VStack {
                Spacer(minLength: 50)
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 10),
                    GridItem(.flexible(), spacing: 10)
                ], spacing: 50) {
                    ForEach(menuItems, id: \.title) { menuItem in
                        NavigationLink(destination: destinationView(for: menuItem)) {
                            ZStack {
                                Rectangle()
                                    .fill(Color(red: 242/255, green: 242/255, blue: 242/255))
                                    .frame(width: 120, height: 120)
                                    .cornerRadius(10)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.gray, lineWidth: 0.5)
                                    )
                                    .shadow(color: Color.black.opacity(0.3), radius: 5, x: 0, y: 2)
                                                           
                                VStack {
                                    Image(menuItem.imageName)
                                        .resizable()
                                        .frame(width: 60, height: 60)
                                    Text(menuItem.title)
                                        .foregroundColor(.gray)
                                        .padding(10)
                                }
                            }
                        }
                    }
                    Spacer(minLength: 30)
                        .padding()
                }
            }
            }
            .edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
        }
        .edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
        
        
        

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
    
struct Transaction: Identifiable {
    var id = UUID()
    var name: String
    var amount: Double
    var date: Date
    }
    
// Vista para "History"
    struct HistoryView: View {
        @State private var transactions: [Transaction] = [
            Transaction(name: "Compra de comestibles", amount: -50.0, date: Date()),
            Transaction(name: "Pago de factura del gas", amount: -80.0, date: Date()),
            Transaction(name: "Retiro de cajero", amount: 200.0, date: Date()),
            Transaction(name: "Compra de ropa", amount: -150.0, date: Date()),
            Transaction(name: "Pago de factura del agua", amount: -100.0, date: Date()),
            Transaction(name: "Trabajo ocasional", amount: 250.0, date: Date())
        ]

        var body: some View {
                ZStack() {
                    Color(red: 21/255, green: 191/255, blue: 129/255).edgesIgnoringSafeArea(.all)
                    VStack {
                        Text("History")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                }
                .frame(maxWidth: 400, maxHeight: 60)
                Spacer()
                NavigationView {
                    List {
                        ForEach(transactions) { transaction in
                            VStack(alignment: .leading, spacing: 5) {
                                Text(transaction.name)
                                    .font(.headline)
                                if transaction.amount >= 0 {
                                    Text("$\(String(format: "%.2f", transaction.amount))")
                                        .font(.subheadline)
                                        .foregroundColor(.green)
                                } else {
                                    Text("$\(String(format: "%.2f", transaction.amount))")
                                        .font(.subheadline)
                                        .foregroundColor(.red)
                                }
                                Text(formatDate(transaction.date))
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .onDelete { indexSet in
                            // Opcion para eliminar un elemento de la lista
                            transactions.remove(atOffsets: indexSet)
                        }
                    }
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                        EditButton()
                        }
                    }
                }
            }

        // Función para formatear la fecha y hora
        func formatDate(_ date: Date) -> String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM d, yyyy, hh:mm a"
            return dateFormatter.string(from: date)
        }
    }

    
// Vista para "Budgets"
    struct BudgetsView: View {
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
            VStack() {
                
            }.background(Color.white)
        }
    }


    
// Vista para "Tags"
    struct TagsItem {
           let title: String
           let imageName: String
       }

       struct TagsView: View {
           @State var tagsItems: [TagsItem] = [
               TagsItem(title: "Food", imageName: "Food"),
               TagsItem(title: "Transportation", imageName: "Transportation"),
               TagsItem(title: "Housing", imageName: "Housing"),
               TagsItem(title: "Health", imageName: "Health"),
               TagsItem(title: "Entertainment", imageName: "Entertainment"),
               TagsItem(title: "Add", imageName: "Add")
           ]

           @State var isEditMode = false
           @State var isAddTagDialogPresented = false
           @State var newTagName = ""

           // Función para agregar una nueva etiqueta
           func addNewTag(_ tagName: String) {
               let newTag = TagsItem(title: tagName, imageName: "DefaultImage") // Ajusta la imagen según tus necesidades.
               tagsItems.insert(newTag, at: tagsItems.count - 1)
           }

           var body: some View {
               ZStack() {
                   Color(red: 21/255, green: 191/255, blue: 129/255).edgesIgnoringSafeArea(.all)
                   VStack {
                       Text("Tags")
                           .font(.title)
                           .fontWeight(.bold)
                           .foregroundColor(.white)
                   }
               }
               .frame(maxWidth: 400, maxHeight: 60)
               Spacer()

               VStack() {
                   Spacer(minLength: 40)
                   LazyVGrid(columns: [
                       GridItem(.flexible(), spacing: 10),
                       GridItem(.flexible(), spacing: 10),
                       GridItem(.flexible(), spacing: 10)
                   ], spacing: 50) {
                       ForEach(tagsItems.indices, id: \.self) { index in
                           ZStack {
                               Rectangle()
                                   .fill(Color(red: 242/255, green: 242/255, blue: 242/255))
                                   .frame(width: 90, height: 90)
                                   .cornerRadius(10)
                                   .overlay(
                                       RoundedRectangle(cornerRadius: 10)
                                           .stroke(Color.gray, lineWidth: 0.5)
                                   )
                                   .shadow(color: Color.black.opacity(0.3), radius: 5, x: 0, y: 2)

                               VStack {
                                   Spacer(minLength: 8)
                                   Image(tagsItems[index].imageName)
                                       .resizable()
                                       .frame(width: 45, height: 45)

                                   Text(tagsItems[index].title)
                                       .foregroundColor(.gray)
                                       .padding(10)
                                       .font(.custom("San Francisco", size: 12))
                               }
                               
                               if tagsItems[index].title != "Add" {
                                   if isEditMode {
                                       Button(action: {
                                           tagsItems.remove(at: index)
                                       }) {
                                           Image(systemName: "minus.circle.fill")
                                               .foregroundColor(.red)
                                               .padding(5)
                                               .background(Color.white)
                                               .clipShape(Circle())
                                               .offset(x: 20, y: -20)
                                       }
                                   }
                               } else {
                                   Button(action: {
                                       isAddTagDialogPresented.toggle()
                                   }) {
                                       Image(systemName: "plus.circle.fill")
                                           .foregroundColor(.green)
                                           .padding(5)
                                           .background(Color.white)
                                           .clipShape(Circle())
                                           .offset(x: 20, y: -20)
                                   }
                               }
                           }
                       }
                   }
                   Spacer(minLength: 30)
                   .padding()
               }
               .background(Color.white)
               .toolbar {
                   ToolbarItem(placement: .navigationBarTrailing) {
                       Button(action: {
                           isEditMode.toggle()
                       }) {
                           Text(isEditMode ? "Done" : "Edit")
                       }
                   }
               }
               .sheet(isPresented: $isAddTagDialogPresented) {
                   AddTagDialog(isPresented: $isAddTagDialogPresented, tagName: $newTagName, addTagAction: addNewTag)
               }
           }
       }

       struct AddTagDialog: View {
           @Binding var isPresented: Bool
           @Binding var tagName: String
           var addTagAction: (String) -> Void // Cierre para agregar una nueva etiqueta

           var body: some View {
               VStack {
                   Text("Agregar Nueva Etiqueta")
                       .font(.title)
                       .padding()

                   TextField("Nombre de la etiqueta", text: $tagName)
                       .textFieldStyle(RoundedBorderTextFieldStyle())
                       .padding()

                   HStack {
                       Button("Cancelar") {
                           isPresented = false
                       }
                       Spacer()
                       Button("Guardar") {
                           // Llama a la función para agregar la nueva etiqueta
                           addTagAction(tagName)

                           // Cierra el diálogo
                           isPresented = false
                       }
                   }
                   .padding()
               }
               .padding()
           }
       }
    
    

// Vista para "Summary"
    struct SummaryView: View {
        var body: some View {
            ZStack() {
                Color(red: 21/255, green: 191/255, blue: 129/255).edgesIgnoringSafeArea(.all)
                VStack {
                    Text("Summary")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
            }.frame(maxWidth: 400, maxHeight: 60)
            Spacer()
            VStack() {
                
            }.background(Color.white)
        }
    }
    
    

// Vista para "Accounts"
    struct WebView: UIViewRepresentable {
        let urlString: String

        func makeUIView(context: Context) -> WKWebView {
            let webView = WKWebView()
            return webView
        }

        func updateUIView(_ uiView: WKWebView, context: Context) {
            if let url = URL(string: urlString) {
                let request = URLRequest(url: url)
                uiView.load(request)
            }
        }
    }

    struct WebSheetItem: Identifiable {
        let id = UUID()
        let urlString: String
    }

    struct AccountsView: View {
        let accounts: [Account] = [
            Account(title: "Paypal", imageName: "Paypal", link: "https://www.paypal.com/signin"),
            Account(title: "Nequi", imageName: "Nequi", link: "https://transacciones.nequi.com/bdigital/login.jsp"),
            Account(title: "Daviplata", imageName: "Daviplata", link: "https://conectesunegocio.daviplata.com/es/user/login")
        ]

        @State private var selectedAccountURL: WebSheetItem? = nil

        var body: some View {
            ZStack() {
                Color(red: 21/255, green: 191/255, blue: 129/255).edgesIgnoringSafeArea(.all)
                VStack {
                    Text("Accounts")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
            }.frame(maxWidth: 400, maxHeight: 60)
            .background(Color(red: 240/255, green: 240/255, blue: 242/255))
            VStack{
                Text("Connect with")
                    .fontWeight(.light)
                List(accounts, id: \.title) { account in
                    Button(action: {
                        selectedAccountURL = WebSheetItem(urlString: account.link)
                    }) {
                        AccountRow(account: account)
                    }
                }
            }.background(Color(red: 240/255, green: 240/255, blue: 242/255))
            .sheet(item: $selectedAccountURL) { webSheetItem in
                NavigationView {
                    WebView(urlString: webSheetItem.urlString)
                        .navigationBarTitle("Account Login", displayMode: .inline)
                        .navigationBarItems(leading: Button(action: {
                            selectedAccountURL = nil
                        }) {
                            Image(systemName: "arrow.left")
                                .foregroundColor(.blue)
                        })
                }
            }
        }
    }

    struct Account {
        let title: String
        let imageName: String
        let link: String
    }

    struct AccountRow: View {
        let account: Account
        
        var body: some View {
            HStack {
                Image(account.imageName)
                    .resizable()
                    .frame(width: 40, height: 40)
                    .cornerRadius(20)
                Text(account.title)
                    .font(.headline)
            }
        }
    }
    

// Vista para "Settings"
    struct SettingsView: View {
        var body: some View {
            ZStack() {
                Color(red: 21/255, green: 191/255, blue: 129/255).edgesIgnoringSafeArea(.all)
                VStack {
                    Text("Settings")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
            }.frame(maxWidth: 400, maxHeight: 60)
            Spacer()
            VStack() {
                
            }.background(Color.white).cornerRadius(20)
        }
    }



}

struct TopRoundedRectangle: Shape {
    var radius: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: rect.maxY)) // start from bottom left
        path.addLine(to: CGPoint(x: 0, y: radius)) // line to top left
        path.addArc(center: CGPoint(x: radius, y: radius), radius: radius, startAngle: Angle(degrees: 180), endAngle: Angle(degrees: 90), clockwise: false) // top left corner
        path.addLine(to: CGPoint(x: rect.maxX - radius, y: 0)) // line to top right
        path.addArc(center: CGPoint(x: rect.maxX - radius, y: radius), radius: radius, startAngle: Angle(degrees: 90), endAngle: Angle(degrees: 0), clockwise: false) // top right corner
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY)) // line to bottom right
        path.closeSubpath()
        return path
    }
}
