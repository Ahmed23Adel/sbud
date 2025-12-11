//
//  sbudApp.swift
//  sbud
//
//  Created by ahmed on 05/12/2025.
//

import SwiftUI
import FirebaseCore
import GoogleSignIn


// Note: Used to enable push notification in future
class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
      FirebaseApp.configure()
    return true
  }
}

@main
struct sbudApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var authManager = AuthenticationManager.shared
    var body: some Scene {
        WindowGroup {
            MainAppCoordinator()
            .onOpenURL{ url in
                GIDSignIn.sharedInstance.handle(url)
            }
            
        }
        
    }
}
