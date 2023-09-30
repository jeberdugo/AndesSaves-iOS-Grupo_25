import SwiftUI

struct RegisterView: View {
    @State private var email = ""
    @State private var name = ""
    @State private var phone = ""
    @State private var password = ""
    @State private var passwordConfirmation = ""
    @StateObject private var functions = GlobalFunctions()

    var body: some View {
        NavigationView {
            VStack{
                VStack {
                    Image("Logo") // Replace "YourLogo" with the name of your logo image asset
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 300, height: 200) // Adjust the size as needed
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(hex: "EEEEEE")) // Set your desired background color here
                            .frame(height: 37) // Adjust the height as needed
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color(hex: "C6C6C6"), lineWidth: 1) // Set your desired border color and width
                            )
                        
                        TextField("Email", text: $email)
                            .textFieldStyle(PlainTextFieldStyle())
                            .padding(.horizontal, 10)
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
                        
                        TextField("Name", text: $name)
                            .textFieldStyle(PlainTextFieldStyle())
                            .padding(.horizontal, 10)
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
                        
                        TextField("Phone", text: $phone)
                            .textFieldStyle(PlainTextFieldStyle())
                            .padding(.horizontal, 10)
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
                            .textFieldStyle(PlainTextFieldStyle())
                            .padding(.horizontal, 10)
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
                        
                        SecureField("Confirm Password", text: $passwordConfirmation)
                            .textFieldStyle(PlainTextFieldStyle())
                            .padding(.horizontal, 10)
                    }
                    .padding()
                    
                    Button(action: {
                        // Implement your registration logic here
                        // Validate the user input and perform registration
                        // If successful, navigate to the main content view
                    }) {
                        Text("Register")
                            .foregroundColor(Color.white)
                            .padding(.horizontal, 35.0)
                            .padding(.vertical, 10.0)
                            .background(Color(red: 21/255, green: 191/255, blue: 129/255))
                            .cornerRadius(10)
                    }
                    .padding()
                    
                }
                .padding()
                Spacer()
            }.background(functions.isDaytime ? Color.white : Color(red: 23/255, green: 24/255, blue: 25/255))
        }
    }
}
