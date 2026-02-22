//
//  SpendMateApp.swift
//  SpendMate
//
//  Created by Berkay Dereci on 31.01.2026.
//

import SwiftUI
import SwiftData
import UserNotifications
import AppIntents

@main
struct SpendMateApp: App {
    init() {
        if #available(iOS 16.0, *) {
            AppShortcuts.updateAppShortcutParameters()
        }
    }
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Expense.self,
        ])
        
        // App Group URL kullan (widget ile paylaşım için)
        let appGroupIdentifier = "group.com.spendmate.shared"
        let url: URL?
        
        if let appGroupURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: appGroupIdentifier
        ) {
            url = appGroupURL.appendingPathComponent("SpendMate.sqlite")
        } else {
            // App Group yoksa fallback (geliştirme aşamasında)
            url = nil
        }
        
        //Buraya bakılacak!!
        /*
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            url: url?.path,
            isStoredInMemoryOnly: false
        )
        */
        
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            groupContainer: .identifier(appGroupIdentifier)
        )

        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            
            // Migration: Mevcut Expense kayıtlarında type field'ı nil ise default değer ata
            let context = container.mainContext
            let descriptor = FetchDescriptor<Expense>()
            let expenses = try context.fetch(descriptor)
            
            var hasChanges = false
            for expense in expenses {
                if expense.type == nil {
                    expense.type = TransactionType.expense.rawValue
                    hasChanges = true
                }
            }
            
            if hasChanges {
                try context.save()
            }
            
            return container
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .onAppear {
                    setupNotifications()
                    if #available(iOS 16.0, *) {
                        setupAppShortcuts()
                    }
                }
        }
        .modelContainer(sharedModelContainer)
    }
    
    private func setupNotifications() {
        // Notification center delegate ayarla
        UNUserNotificationCenter.current().delegate = appDelegate
        
        Task {
            // Bildirim izni kontrolü ve isteği
            let status = await NotificationService.shared.checkAuthorizationStatus()
            
            if status == .notDetermined {
                // İlk kez açılıyorsa izin iste
                let granted = await NotificationService.shared.requestAuthorization()
                if granted {
                    NotificationService.shared.scheduleMonthlySummaryNotification()
                }
            } else if status == .authorized {
                // İzin verilmişse zamanlamayı güncelle
                NotificationService.shared.updateNotificationSchedule()
            }
        }
    }
    
    @available(iOS 16.0, *)
    private func setupAppShortcuts() {
        AppShortcuts.updateAppShortcutParameters()
    }
}

// AppDelegate for handling notification taps
class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    static var notificationUserInfo: [AnyHashable: Any]?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }
    
    // Bildirim tıklandığında çağrılır
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        
        if let type = userInfo["type"] as? String,
           type == "monthly_summary" || type == "weekly_summary" {
            AppDelegate.notificationUserInfo = userInfo
        }
        
        completionHandler()
    }
    
    // Uygulama foreground'dayken bildirim geldiğinde çağrılır
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge])
    }
}
