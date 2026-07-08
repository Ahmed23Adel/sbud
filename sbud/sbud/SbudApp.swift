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
import FirebaseAnalytics
import BackgroundTasks
// Note: Used to enable push notification in future
class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        FirebaseApp.configure()
        Analytics.setUserID(Auth.auth().currentUser?.uid)
        if let countryCode = Locale.current.region?.identifier {
            Analytics.setUserProperty(countryCode, forName: "country")
        }
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
        UIApplication.shared.registerForRemoteNotifications()
        registerBackgroundTasks()
        return true
    }

    private func registerBackgroundTasks() {
        //I'm telling iOS what to do when it's fired in background
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: "com.sbud.event.remindersync",
            using: nil
        ) { task in
            guard let refreshTask = task as? BGAppRefreshTask else { return }
            refreshTask.expirationHandler = { refreshTask.setTaskCompleted(success: false) }
            Task {
                await EventReminderScheduler.shared.syncReminders()
                refreshTask.setTaskCompleted(success: true)
                self.scheduleNextReminderSync() // // ← submits the NEXT request
            }
        }
        scheduleNextReminderSync()
    }
    // BGTaskScheduler only keeps one pending request per identifier. Submitting a new one overwrites the old one.
    // the BGTask is just a safety net for when the user doesn't open the app.
    // otherwise it uses scenePhase
    func scheduleNextReminderSync() {
        // "iOS, please wake my app at some point after 12 hours from now, and run the handler registered for this identifier."
        let request = BGAppRefreshTaskRequest(identifier: "com.sbud.event.remindersync")
        // earliestBeginDate is a lower bound, not a schedule
        request.earliestBeginDate = Date(timeIntervalSinceNow: 12 * 60 * 60) // ~twice a day
        try? BGTaskScheduler.shared.submit(request)
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
    
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable : Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        // Passa la notifica a Firebase Auth
        if Auth.auth().canHandleNotification(userInfo) {
            completionHandler(.noData)
            return
        }
        
        
        completionHandler(.newData)
    }
    
    

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }
}

@main
struct SbudApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var authManager = AuthenticationManager.shared
    @StateObject var mainCoordinator = MainCoordinator(
        authService: AuthenticationManager.shared,
        profileService: ProfileManager.shared
    )
    @Environment(\.scenePhase) private var scenePhase
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
    
    var body: some Scene {
        WindowGroup {
            MainAppCoordinator(coordinator: MainCoordinator(
                authService: AuthenticationManager.shared,
                profileService: ProfileManager.shared))
            .onOpenURL { url in
                // 1. URL con Google Sign-In
                if GIDSignIn.sharedInstance.handle(url) {
                    return
                }
                
                // 2) (reCAPTCHA Phone Auth)
                if Auth.auth().canHandle(url) {
                    return
                }
            }
        }
    }

    var body: some Scene {
        WindowGroup {
            MainAppCoordinator(coordinator: mainCoordinator)
                .onOpenURL { url in
                    GIDSignIn.sharedInstance.handle(url)
                    mainCoordinator.handle(universalLink: url)
                }
        }
        .modelContainer(for: LocalOnGoingSession.self)
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                Task { await EventReminderScheduler.shared.syncReminders() }
            }
        }
    }
}
