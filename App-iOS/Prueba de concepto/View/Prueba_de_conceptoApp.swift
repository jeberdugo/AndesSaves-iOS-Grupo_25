//
//  Prueba_de_conceptoApp.swift
//  Prueba de concepto
//
//  Created by Juan Sebastian Sanchez on 7/09/23.
//

import SwiftUI
import FirebaseCore

@main
struct Prueba_de_conceptoApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject var loginViewModel = LoginViewModel()
    @StateObject var networkMonitor = NetworkMonitor()
    @State private var show = true;
    
    var body: some Scene {
        WindowGroup {
            LoginView().environmentObject(loginViewModel)
                .overlay(
                                    Group {
                                        if !networkMonitor.isConnected && show{
                                            HStack {

                                                VStack {
                                                    HStack {
                                                        Text("No Internet Connection. Transactions and budgets can be shown later.")
                                                            .foregroundColor(.white)
                                                            .padding()
                                                            .background(Color.red)
                                                            .cornerRadius(10)

                                                        Button(action: {
                                                            withAnimation {
                                                                self.show = false
                                                            }
                                                        }) {
                                                            Image(systemName: "xmark")
                                                                .foregroundColor(.white)
                                                                .padding()
                                                        }
                                                    }
                                                    .background(Color.red)
                                                    .cornerRadius(10)
                                                    Spacer()
                                                }
                                            }
                                            .transition(.move(edge: .top))
                                            .animation(.spring())

                                        }
                                    }
                                )
                .onAppear {
                    appDelegate.orientationLock = .portrait
                }
        }
    }
}

class AppDelegate: UIResponder, UIApplicationDelegate {
    var orientationLock = UIInterfaceOrientationMask.all

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return orientationLock
    }
    



    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Handle notification presentation here
        completionHandler([.banner, .sound, .badge]) // You can customize the presentation options
    }
}
