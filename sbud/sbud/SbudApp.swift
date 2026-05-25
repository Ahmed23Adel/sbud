//
//  sbudApp.swift
//  sbud
//
//  Created by ahmed on 05/12/2025.
//

import SwiftUI
import FirebaseCore
import GoogleSignIn
import AdelsonAuthManager
import AdelsonApiCaller
import FirebaseAuth
import FirebaseMessaging
import OSLog
import FirebaseFirestore
import SwiftData

// Note: Used to enable push notification in future
class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        FirebaseApp.configure()
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
        UIApplication.shared.registerForRemoteNotifications()
        return true
    }

    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
        Task {
            await FCMExtractor().saveFCMToken()
        }
    }

    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notifications: \(error)")
    }
    
    
}

@main
struct SbudApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var authManager = AuthenticationManager.shared
    let locationManager = LocationManager.shared
    let service = GeohashService.shared
    
    let logger = Logger(subsystem: "sbud", category: "SbudApp")
    
    init(){
        AdelsonFirebaseAuthConfig.shared = AdelsonFirebaseAuthConfig(
            appName: "sBud",
            baseUrl: "https://sbud-backend.onrender.com/api/v1/",
            fnFirebaseIdToken: {
                await FirebaseTokenExtractor().getIDToken()
            }
        )
        
    }
    
    var body: some Scene {
        WindowGroup {
            MainAppCoordinator(coordinator: MainCoordinator(
                authService: AuthenticationManager.shared,
                profileService: ProfileManager.shared))
            .onOpenURL { url in
                GIDSignIn.sharedInstance.handle(url)
            }
            .onAppear {
                Task {
                    let token = try? await Auth.auth().currentUser?.getIDToken()
                    print("🔑 TOKEN:", token ?? "nil")
                }
            }

        }
        .modelContainer(for: LocalOnGoingSession.self)

    }
}
