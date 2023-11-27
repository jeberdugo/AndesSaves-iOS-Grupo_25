//
//  SettingsView.swift
//  Prueba de concepto
//
//  Created by Juan Sebastian Sanchez on 25/09/23.
//

import SwiftUI
import UserNotifications
import WebKit

// Vista para "Settings"
struct SettingsView: View {
    @StateObject private var functions = GlobalFunctions()
    @StateObject private var viewModel = SettingsViewModel()
    @StateObject private var networkManager = NetworkMonitor()
    @State private var isInternetConnected = true
    @State private var isShowingSuggestionView = false
    @State private var isShowingUsefulLinksView = false

    var body: some View {
        ZStack {
            Color(red: 21/255, green: 191/255, blue: 129/255).edgesIgnoringSafeArea(.all)
            VStack {
                Text("Settings")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
        }
        .frame(maxWidth: 400, maxHeight: 60)

        Spacer()

        List {
            Section {
                HStack {
                    Image(systemName: "person.circle.fill")
                        .imageScale(.large)
                        .foregroundColor(.gray)
                        .font(.title)
                        .frame(width: 72, height: 72)

                    VStack(alignment: .leading, spacing: 7) {
                        Text(viewModel.name)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .padding(.top, 4)

                        Text(viewModel.email)
                            .font(.footnote)
                            .accentColor(.gray)
                    }
                }
            }

            Section("General") {
                HStack(spacing: 12) {
                    Image(systemName: "gear.circle.fill")
                        .imageScale(.small)
                        .foregroundColor(.gray)
                        .font(.title)
                        .frame(width: 20, height: 20)

                    SectionView(title: "Version")
                        .font(.subheadline)
                        .foregroundColor(.black)

                    Spacer()

                    Text("2.0.0")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(5)
                }

                HStack(spacing: 12) {
                    Image(systemName: "bell.circle.fill")
                        .imageScale(.small)
                        .foregroundColor(.gray)
                        .font(.title)
                        .frame(width: 20, height: 20)

                    SectionView(title: "Notifications")
                        .font(.subheadline)
                        .foregroundColor(.black)

                    Spacer()

                    Toggle("", isOn: $viewModel.notificationsEnabled)
                        .padding(.trailing, 16)
                        .foregroundColor(.blue)
                        .onChange(of: viewModel.notificationsEnabled) { newValue in
                            if newValue {
                                requestNotificationAuthorization()
                            } else {
                                disableNotifications()
                            }
                        }
                }

                HStack(spacing: 12) {
                    Image(systemName: "square.and.pencil")
                        .imageScale(.small)
                        .foregroundColor(.gray)
                        .font(.title)
                        .frame(width: 20, height: 20)

                    SectionView(title: "Send Suggestion")
                        .font(.subheadline)
                        .foregroundColor(.black)

                    Spacer()

                    Button(action: {
                        if networkManager.isConnected {
                            print("Sign Out..")
                            isShowingSuggestionView.toggle()
                        } else {
                            viewModel.isAlertShowing = true
                        }
                    }) {
                        Image(systemName: "arrow.right.circle.fill")
                            .foregroundColor(.green)
                            .imageScale(.small)
                            .font(.title)
                            .frame(width: 20, height: 20)
                    }
                    .sheet(isPresented: $isShowingSuggestionView) {
                        SuggestionFeedbackView(isPresented: $isShowingSuggestionView)
                    }
                }
                
                HStack(spacing: 12) {
                    Image(systemName: "link.circle.fill")
                        .imageScale(.small)
                        .foregroundColor(.gray)
                        .font(.title)
                        .frame(width: 20, height: 20)
                    
                    SectionView(title: "Useful Links")
                        .font(.subheadline)
                        .foregroundColor(.black)
                    
                    Spacer()

                    Button(action: {
                        if networkManager.isConnected {
                            print("Sign Out..")
                            isShowingUsefulLinksView.toggle()
                        } else {
                            viewModel.isAlertShowing = true
                        }
                    }) {
                        Image(systemName: "arrow.right.circle.fill")
                            .foregroundColor(.green)
                            .imageScale(.small)
                            .font(.title)
                            .frame(width: 20, height: 20)
                    }
                    .sheet(isPresented: $isShowingUsefulLinksView, content: {
                            UsefulLinksView(isPresented: $isShowingUsefulLinksView)
                        })
                }
            }

            Section("Accounts") {
                Button {
                    if networkManager.isConnected {
                        print("Sign Out..")
                        viewModel.signOut()
                        viewModel.isLoggingOut.toggle()
                    } else {
                        viewModel.isAlertShowing = true
                    }
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "arrow.left.circle.fill")
                            .foregroundColor(.red)
                            .imageScale(.small)
                            .font(.title)
                            .frame(width: 20, height: 20)

                        SectionView(title: "Sign Out")
                            .font(.subheadline)
                            .foregroundColor(.black)
                    }
                }
                .fullScreenCover(isPresented: $viewModel.isLoggingOut) {
                    LoginView()
                }
            }
            .alert(isPresented: $viewModel.isAlertShowing) {
                Alert(
                    title: Text("No Internet Connection"),
                    message: Text("Please check your internet connection and try again."),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
        .listStyle(PlainListStyle())
        .onReceive(networkManager.$isConnected) { isConnected in
            isInternetConnected = isConnected
        }
        .onAppear {
            viewModel.fetchUser()
        }
    }
}


struct SectionView: View {
    var title: String

    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
                .padding(.leading, 16)

            Spacer()
        }
        .frame(height: 40)
        
    }
}


// Request user authorization for notifications
func requestNotificationAuthorization() {
    let center = UNUserNotificationCenter.current()
    
    center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
        if granted {
            // User granted permission, you can now schedule notifications
            scheduleNotifications()
        } else {
            // User denied permission or there was an error
            // Handle accordingly, e.g., show an alert or provide guidance to enable notifications in Settings
        }
    }
}

// Schedule a sample notification
func scheduleNotifications() {
    let content = UNMutableNotificationContent()
    content.title = "Sample Notification"
    content.body = "This is a sample notification message."
    content.sound = UNNotificationSound.default

    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
    let request = UNNotificationRequest(identifier: "sampleNotification", content: content, trigger: trigger)
    
    let center = UNUserNotificationCenter.current()
    center.add(request) { error in
        if let error = error {
            // Handle the error
            print("Error scheduling notification: \(error.localizedDescription)")
        } else {
            // Notification scheduled successfully
        }
    }
}

// Disable notifications
func disableNotifications() {
    let center = UNUserNotificationCenter.current()
    center.removeAllPendingNotificationRequests()
    center.removeAllDeliveredNotifications()
    
    // Optionally, you can also revoke notification authorization
    center.getNotificationSettings { settings in
        if settings.authorizationStatus == .authorized {
            center.setNotificationCategories([])
            center.removeDeliveredNotifications(withIdentifiers: ["" /* Add notification identifiers here if needed */])
            center.removePendingNotificationRequests(withIdentifiers: ["" /* Add notification request identifiers here if needed */])
        }
    }
}


struct SuggestionFeedbackView: View {
    @Binding var isPresented: Bool
    @StateObject private var viewModel = SettingsViewModel()
    @State private var suggestionText = "Type your suggestion or claim here..."
    private let maxCharacterCount = 150
    @State private var showAlert = false
    @State private var isSuccess: Bool?
    @State private var title = ""
    @State private var message = ""
    
    var body: some View {
        ZStack {
            Color(red: 21/255, green: 191/255, blue: 129/255).edgesIgnoringSafeArea(.all)
            VStack {
                Text("Settings")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
        }
        .frame(maxWidth: 400, maxHeight: 60)

        Spacer()
        
        VStack {
            TextEditor(text: $suggestionText)
                .frame(minHeight: 150)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
                .padding()
                .onTapGesture {
                    if suggestionText == "Type your suggestion or claim here..." {
                    suggestionText = ""
                        }
                    }
            
            Text("\(suggestionText.count)/\(maxCharacterCount) characters")
                .foregroundColor(suggestionText.count > maxCharacterCount ? .red : .gray)
                .padding(.bottom)
            
            Button(action: {
                if suggestionText.count <= maxCharacterCount {
                    print("Submitted suggestion: \(suggestionText)")

                    viewModel.addSuggestion(text: suggestionText) { isSuccess in
                        if isSuccess {
                            // Suggestion added successfully
                            print("Suggestion added successfully!")
                            isPresented.toggle()
                        } else {
                            // Failed to add suggestion
                            title = "Internet Connection Problem"
                            message = "Check your internet connection and try again"
                            showAlert = true
                            print("Failed to add suggestion.")
                        }
                    }
                } else {
                    title = "Exceeded Character Limit"
                    message = "Your suggestion exceeds the maximum limit of \(maxCharacterCount) characters."
                    showAlert = true
                    print("Suggestion exceeds the character limit.")
                           }
            }) {
                Text("Submit")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(hex:"12CD8A"))
                    .cornerRadius(10)
            }
            .alert(isPresented: $showAlert) {
                            Alert(
                                title: Text(title),
                                message: Text(message),
                                dismissButton: .default(Text("OK"))
                            )
                        }
            
            Spacer()
        }
        .padding()
    }
}


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

    struct UsefulLinksView: View {
        @Binding var isPresented: Bool
        @StateObject private var viewModel = AccountsViewModel()
        @StateObject private var functions = GlobalFunctions()
        @StateObject private var networkManager = NetworkMonitor()
        @State private var isInternetConnected = true
        
        var body: some View {
            ZStack() {
                Color(red: 21/255, green: 191/255, blue: 129/255).edgesIgnoringSafeArea(.all)
                VStack {
                    Text("Useful links")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(Color.white)
                }
            }.frame(maxWidth: 400, maxHeight: 60)
            .background(Color(red: 240/255, green: 240/255, blue: 242/255))
            VStack{
                Text("Connect with")
                    .fontWeight(.light)
                    .foregroundColor(functions.isDaytime ? Color.black : Color.white)
                List(viewModel.accounts, id: \.title) { account in
                    Button(action: {
                        if networkManager.isConnected {
                            viewModel.selectedAccountURL = WebSheetItem(urlString: account.link)
                        } else{
                            viewModel.isAlertShowing = true
                        }
                    }) {
                        AccountRow(account: account)
                    }
                }
                .alert(isPresented: $viewModel.isAlertShowing) {
                           Alert(
                               title: Text("No Internet Connection"),
                               message: Text("Please check your internet connection and try again."),
                               dismissButton: .default(Text("OK"))
                           )
                       }
            }.listStyle(PlainListStyle())
                .background(functions.isDaytime ? Color.white : Color(red: 23/255, green: 24/255, blue: 25/255))
                .sheet(item: $viewModel.selectedAccountURL) { webSheetItem in
                NavigationView {
                    WebView(urlString: webSheetItem.urlString)
                        .navigationBarTitle("Account Login", displayMode: .inline)
                        .navigationBarItems(leading: Button(action: {
                            viewModel.selectedAccountURL = nil
                        }) {
                            Image(systemName: "arrow.left")
                                .foregroundColor(.blue)
                        })
                }
            }.onReceive(networkManager.$isConnected) { isConnected in
                isInternetConnected = isConnected
            }
        }
    }


    struct AccountRow: View {
        let account: Account
        @StateObject private var functions = GlobalFunctions()
        
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
