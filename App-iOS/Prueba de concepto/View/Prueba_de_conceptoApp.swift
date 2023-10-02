//
//  Prueba_de_conceptoApp.swift
//  Prueba de concepto
//
//  Created by Juan Sebastian Sanchez on 7/09/23.
//

import SwiftUI

@main
struct Prueba_de_conceptoApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        WindowGroup {
            LoginView()
        }
    }
}

class AppDelegate: UIResponder, UIApplicationDelegate {
    static var orientationLock = UIInterfaceOrientationMask.portrait
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Bloquea la orientación en modo retrato
        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
        
        return true
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        // Solo permite la orientación vertical (retrato)
        return AppDelegate.orientationLock
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Handle notification presentation here
        completionHandler([.banner, .sound, .badge]) // You can customize the presentation options
    }
    
}









