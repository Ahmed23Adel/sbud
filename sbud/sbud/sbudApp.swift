//
//  sbudApp.swift
//  sbud
//
//  Created by ahmed on 05/12/2025.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth
import GoogleSignIn
import AdelsonAuthManager

// Note: Used to enable push notification in future
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        application.registerForRemoteNotifications()
        return true
    }

    
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Auth.auth().setAPNSToken(deviceToken, type: .unknown)
    }

    
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if Auth.auth().canHandleNotification(userInfo) {
            completionHandler(.noData)
            return
        }
        completionHandler(.newData)
    }

    
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        if Auth.auth().canHandle(url) { return true }
        return GIDSignIn.sharedInstance.handle(url) // ✅ Mantieni Google Sign-In
    }
}

@main
struct SbudApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var authManager = AuthenticationManager.shared
    let locationManager = LocationManager.shared
    let service = GeohashService.shared
    
    init(){
        AdelsonFirebaseAuthConfig.shared = AdelsonFirebaseAuthConfig(
            appName: "sBud",
            baseUrl: "https://sbud-backend.onrender.com/api/v1/",
            fnFirebaseIdToken: FirebaseTokenExtractor().getIDToken)
    }
    var body: some Scene {
        WindowGroup {
            MainAppCoordinator()
            .onOpenURL { url in
                GIDSignIn.sharedInstance.handle(url)
            }

        }

    }
}
