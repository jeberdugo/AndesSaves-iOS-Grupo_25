//
//  SettingsView.swift
//  Prueba de concepto
//
//  Created by Juan Sebastian Sanchez on 25/09/23.
//

import SwiftUI
import UserNotifications

// Vista para "Settings"
struct SettingsView: View {
    @StateObject private var functions = GlobalFunctions()
    @StateObject private var viewModel = SettingsViewModel()
    
    var body: some View {
        ZStack() {
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
        
        List{
            Section{
                HStack{
                    
                    Image(systemName: "person.circle.fill")
                        .imageScale(.large)
                        .foregroundColor(.gray)
                        .font(.title)
                        .frame(width: 72, height: 72)
                    
                    VStack(alignment: .leading, spacing: 7){
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
            
            Section("General"){
                HStack(spacing: 12){
                    Image(systemName: "gear.circle.fill")
                        .imageScale(.small)
                        .foregroundColor(.gray)
                        .font(.title)
                        .frame(width: 20, height: 20)
                    
                    SectionView(title: "Currency")
                        .font(.subheadline)
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    Text("2.0.0")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(5)
                }
                
                HStack(spacing: 12){
                    Image(systemName: "bell.circle.fill")
                        .imageScale(.small)
                        .foregroundColor(.gray)
                        .font(.title)
                        .frame(width: 20, height: 20)
                    
                    SectionView(title: "Notifications")
                        .font(.subheadline)
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    Toggle("", isOn: $viewModel.notificationsEnabled) // Add a Toggle switch
                        .padding(.trailing, 16)
                        .foregroundColor(.blue)
                        .onChange(of: viewModel.notificationsEnabled) { newValue in
                            // Handle the toggle state change here
                            if newValue {
                                requestNotificationAuthorization()
                            } else {
                                disableNotifications()
                            }
                        }
                }
            }
            
            Section("Accounts"){
                
                        Button{
                            print("Sign Out..")
                            viewModel.signOut()
                            viewModel.isLoggingOut.toggle()
                        }label: {
                            HStack(spacing: 12){
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

                    
                /*
                        Button{
                            viewModel.isShowAlarm = true
                            
                        }label: {
                            HStack(spacing: 12){
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.red)
                                    .imageScale(.small)
                                    .font(.title)
                                    .frame(width: 20, height: 20)
                                
                                SectionView(title: "Delete Account")
                                    .font(.subheadline)
                                    .foregroundColor(.red)
                            }
                        }
                        .fullScreenCover(isPresented: $viewModel.isDeletingAccount) {
                                    LoginView()
                                }
                    .alert(isPresented: $viewModel.isShowAlarm) {
                        Alert(
                            title: Text("Warning: Delete Account"),
                            message: Text("are you sure you want to delete your account permantly?"),
                            primaryButton: .destructive(
                                Text("Confirm"),
                                action: {
                                    print("Delete Account..")
                                    viewModel.deleteAccount()
                                    viewModel.isDeletingAccount.toggle()
                                }
                            ),
                            secondaryButton: .cancel())}
                 */
            }
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
