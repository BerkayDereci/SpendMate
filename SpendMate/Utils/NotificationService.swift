//
//  NotificationService.swift
//  SpendMate
//
//  Created by Berkay Dereci on 31.01.2026.
//

import Foundation
import UserNotifications

class NotificationService {
    static let shared = NotificationService()
    
    private let monthlyNotificationIdentifier = "monthly_summary"
    private let weeklyNotificationIdentifier = "weekly_summary"
    
    private init() {}
    
    func requestAuthorization() async -> Bool {
        let center = UNUserNotificationCenter.current()
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            return granted
        } catch {
            print("Notification authorization error: \(error)")
            return false
        }
    }
    
    func scheduleMonthlySummaryNotification() {
        let center = UNUserNotificationCenter.current()
        
        // Önce mevcut bildirimi iptal et
        center.removePendingNotificationRequests(withIdentifiers: [monthlyNotificationIdentifier])
        
        // Bildirim içeriği
        let content = UNMutableNotificationContent()
        content.title = LocalizedString.monthlySummaryTitle
        content.body = LocalizedString.monthlySummaryBody
        content.sound = .default
        content.categoryIdentifier = "MONTHLY_SUMMARY"
        
        // UserInfo: Bildirim tipi (bir önceki ay bilgisi ContentView'da hesaplanacak)
        content.userInfo = [
            "type": "monthly_summary"
        ]
        
        // Zamanlama: Her ayın 1'inde saat 09:00
        var dateComponents = DateComponents()
        dateComponents.day = 1
        dateComponents.hour = 9
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        // Bildirim isteği
        let request = UNNotificationRequest(
            identifier: monthlyNotificationIdentifier,
            content: content,
            trigger: trigger
        )
        
        center.add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            } else {
                print("Monthly summary notification scheduled")
            }
        }
    }
    
    func cancelAllNotifications() {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
    }
    
    func scheduleWeeklySummaryNotification() {
        let center = UNUserNotificationCenter.current()
        
        // Önce mevcut bildirimi iptal et
        center.removePendingNotificationRequests(withIdentifiers: [weeklyNotificationIdentifier])
        
        // Bildirim içeriği
        let content = UNMutableNotificationContent()
        content.title = LocalizedString.weeklySummaryTitle
        content.body = LocalizedString.weeklySummaryBody
        content.sound = .default
        content.categoryIdentifier = "WEEKLY_SUMMARY"
        
        // UserInfo: Bildirim tipi (bir önceki hafta bilgisi ContentView'da hesaplanacak)
        content.userInfo = [
            "type": "weekly_summary"
        ]
        
        // Zamanlama: Her Pazartesi sabah 09:00
        var dateComponents = DateComponents()
        dateComponents.weekday = 2 // Pazartesi (1 = Pazar, 2 = Pazartesi)
        dateComponents.hour = 9
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        // Bildirim isteği
        let request = UNNotificationRequest(
            identifier: weeklyNotificationIdentifier,
            content: content,
            trigger: trigger
        )
        
        center.add(request) { error in
            if let error = error {
                print("Error scheduling weekly notification: \(error)")
            } else {
                print("Weekly summary notification scheduled")
            }
        }
    }
    
    func updateNotificationSchedule() {
        // Bildirim zamanlamasını güncelle
        scheduleMonthlySummaryNotification()
        scheduleWeeklySummaryNotification()
    }
    
    func checkAuthorizationStatus() async -> UNAuthorizationStatus {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        return settings.authorizationStatus
    }
}

