import SwiftUI

struct RegisterView: View {
    @StateObject private var viewModel = RegisterViewModel()
    @StateObject private var functions = GlobalFunctions()
    
    var isAnyFieldEmpty: Bool {
        return viewModel.email.isEmpty || viewModel.name.isEmpty || viewModel.phone.isEmpty || viewModel.password.isEmpty || viewModel.passwordConfirmation.isEmpty
    }
    
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
                        
                          
                        
                        TextField("Email", text: $viewModel.email)
                            .textFieldStyle(PlainTextFieldStyle())
                            .padding(.horizontal, 10)
                            .autocapitalization(.none)
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
                        
                        TextField("Name", text: $viewModel.name)
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
                        
                        TextField("Phone", text: $viewModel.phone)
                            .textFieldStyle(PlainTextFieldStyle())
                            .padding(.horizontal, 10)
                            .onChange(of: viewModel.phone) { newValue in
                                viewModel.isPhoneNumberValid = NSPredicate(format: "SELF MATCHES %@", viewModel.phoneRegex).evaluate(with: newValue)
                            }
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
                        
                        SecureField("Password", text: $viewModel.password)
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
                        
                        
                        SecureField("Confirm Password", text: $viewModel.passwordConfirmation)
                            .textFieldStyle(PlainTextFieldStyle())
                            .padding(.horizontal, 10)
                    }
                    .padding()
                    
                    Button(action: {
                        if isAnyFieldEmpty {
                                // Show an alert indicating that a field is empty
                                viewModel.message = "Please fill in all fields."
                                viewModel.isRegistered = true
                        } else if !viewModel.isPhoneNumberValid {
                                viewModel.message = "Please enter a valid phone number."
                                viewModel.isRegistered = true
                            }else {
                                // All fields are filled, proceed with registration
                                viewModel.register(name: viewModel.name, phoneNumber: viewModel.phone, password: viewModel.password, passwordConfirmation: viewModel.passwordConfirmation, email: viewModel.email)
                            }
                        
                    }) {
                        Text("Register")
                            .foregroundColor(Color.white)
                            .padding(.horizontal, 35.0)
                            .padding(.vertical, 10.0)
                            .background(Color(red: 21/255, green: 191/255, blue: 129/255))
                            .cornerRadius(10)
                        
                    }
                    .padding()
                    
                    Spacer()
                }.background(functions.isDaytime ? Color.white : Color(red: 23/255, green: 24/255, blue: 25/255))
            }
            .alert(isPresented: $viewModel.isRegistered) {
                      Alert(title: Text("Registration"), message: Text(viewModel.message), dismissButton: .default(Text("OK")))
            }
            .onReceive(viewModel.$message) { newMessage in
                        // Show the alert when the message is updated
                        if !newMessage.isEmpty {
                            viewModel.isRegistered = true
                            print(viewModel.message)
                        }
                    }
                }
            }
        }

