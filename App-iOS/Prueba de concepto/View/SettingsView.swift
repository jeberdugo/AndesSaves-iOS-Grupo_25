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
    @State private var notificationsEnabled = false
    
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
        
        VStack {
            VStack {
                HStack {
                    Image(systemName: "dollarsign.circle")
                        .foregroundColor(.blue)
                        .padding(.leading, 16)
                        .frame(width: 30, height: 30)
                    
                    SectionView(title: "Currency")
                        .font(.headline)
                        .padding(.leading, 16)
                        .foregroundColor(functions.isDaytime ? Color.black : Color.white)
                    
                    Spacer()
                }
                
                Divider()
                
                HStack {
                    Image(systemName: "globe")
                        .foregroundColor(.blue)
                        .padding(.leading, 16)
                        .frame(width: 30, height: 30)
                    
                    SectionView(title: "Language")
                        .font(.headline)
                        .padding(.leading, 16)
                        .foregroundColor(functions.isDaytime ? Color.black : Color.white)
                    
                    Spacer()
                }
                
                Divider()
                
                HStack {
                    Image(systemName: "bell")
                        .foregroundColor(.blue)
                        .padding(.leading, 16)
                        .frame(width: 30, height: 30)
                    
                    SectionView(title: "Notifications")
                        .font(.headline)
                        .padding(.leading, 16)
                        .foregroundColor(functions.isDaytime ? Color.black : Color.white)
                    
                    Spacer()
                    
                    Toggle("", isOn: $notificationsEnabled) // Add a Toggle switch
                        .padding(.trailing, 16)
                        .foregroundColor(.blue)
                        .onChange(of: notificationsEnabled) { newValue in
                            // Handle the toggle state change here
                            if newValue {
                                requestNotificationAuthorization()
                            } else {
                                disableNotifications()
                            }
                        }
                }
            }
            Spacer()
        }
        .background(functions.isDaytime ? Color.white : Color(red: 23/255, green: 24/255, blue: 25/255))
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
