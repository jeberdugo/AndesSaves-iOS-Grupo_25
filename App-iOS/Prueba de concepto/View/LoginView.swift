import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @ObservedObject var viewModel = LoginViewModel()
    @State private var selection: Bool? = false
    @State private var showNextView = false
    @StateObject private var functions = GlobalFunctions()

    var body: some View {
        NavigationView {
            VStack{
            VStack {
                Image("Logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 300, height: 200) // Adjust the size as needed            TextField("Username", text: $username)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(1.0)
                
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(hex: "EEEEEE")) // Set your desired background color here
                        .frame(height: 37) // Adjust the height as needed
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(hex: "C6C6C6"), lineWidth: 1) // Set your desired border color and width
                        )
                    
                    TextField("Email", text: $email)
                        .textFieldStyle(PlainTextFieldStyle()) // Use PlainTextFieldStyle to remove the default border
                        .padding(.horizontal, 10) // Adjust the horizontal padding as needed
                }
                .padding()
                
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(hex: "EEEEEE")) // Set your desired background color here
                        .frame(height: 37) // Adjust the height as needed
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(hex: "C6C6C6"), lineWidth: 1) // Set your desired border color and width
                        )
                    SecureField("Password", text: $password)
                        .textFieldStyle(PlainTextFieldStyle()) // Use PlainTextFieldStyle to remove the default border
                        .padding(.horizontal, 10) // Adjust the horizontal padding as needed
                }
                .padding()
                
                
                NavigationLink(
                    destination: ContentView(),
                    isActive: $showNextView
                ){
                    EmptyView()
                }
                
                Button(action: {
                    viewModel.login(email: self.email, password: self.password)
                    
                    if viewModel.isLoggedIn {
                                            self.showNextView = true
                                        }
                }) {
                    Text("Login")
                        .foregroundColor(Color.white)
                        .padding(.horizontal, 35.0)
                        .padding(.vertical, 10.0)
                        .background(Color(hex:"12CD8A"))
                        .cornerRadius(10)
                }
                .padding()
                
                
                NavigationLink(destination: RegisterView()) {
                    Text("Don't have an account? Click here")
                        .foregroundColor(Color.blue) // Set your desired text color
                        .underline() // Add an underline to the text
                }
            }
            .padding()
            Spacer()
            }.background(functions.isDaytime ? Color.white : Color(red: 23/255, green: 24/255, blue: 25/255))
        }.navigationBarBackButtonHidden(true)
    }
}

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        _ = scanner.scanString("#")
        var rgb: UInt64 = 0

        scanner.scanHexInt64(&rgb)

        let red = Double((rgb & 0xFF0000) >> 16) / 255.0
        let green = Double((rgb & 0x00FF00) >> 8) / 255.0
        let blue = Double(rgb & 0x0000FF) / 255.0

        self.init(red: red, green: green, blue: blue)
    }
}
