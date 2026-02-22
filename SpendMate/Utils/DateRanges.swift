//
//  DateRanges.swift
//  SpendMate
//
//  Created by Berkay Dereci on 31.01.2026.
//

import Foundation

enum PeriodType: String, CaseIterable {
    case weekly
    case monthly
    case manualRange
    
    var displayName: String {
        switch self {
        case .weekly: return LocalizedString.weekly
        case .monthly: return LocalizedString.monthly
        case .manualRange: return LocalizedString.dateRange
        }
    }
}

struct DateRange {
    let start: Date
    let end: Date
    
    var formattedRange: String {
        let formatter = DateFormatter()
        formatter.locale = LocalizedString.isTurkish ? Locale(identifier: "tr_TR") : Locale(identifier: "en_US")
        formatter.dateFormat = "d MMM"
        
        let startStr = formatter.string(from: start)
        let endStr = formatter.string(from: end)
        
        return "\(startStr) – \(endStr)"
    }
}

extension Calendar {
    func startOfWeek(for date: Date) -> Date {
        let components = dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        return self.date(from: components) ?? date
    }
    
    func startOfMonth(for date: Date) -> Date {
        let components = dateComponents([.year, .month], from: date)
        return self.date(from: components) ?? date
    }
    
    func endOfWeek(for startDate: Date) -> Date {
        return self.date(byAdding: .day, value: 7, to: startDate) ?? startDate
    }
    
    func endOfMonth(for startDate: Date) -> Date {
        return self.date(byAdding: .month, value: 1, to: startDate) ?? startDate
    }
}

struct DateRanges {
    static func range(for periodType: PeriodType, anchorDate: Date, 
                      manualStart: Date? = nil, manualEnd: Date? = nil) -> DateRange {
        let calendar = Calendar.current
        
        switch periodType {
        case .weekly:
            // Haftanın ilk günü (Pazartesi 00:00:00)
            let start = calendar.startOfWeek(for: anchorDate)
            // Haftanın son günü (Pazar 23:59:59) - bir sonraki günün başlangıcı olarak ayarla
            let weekEnd = calendar.date(byAdding: .day, value: 6, to: start) ?? start
            let end = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: weekEnd)) ?? weekEnd
            return DateRange(start: start, end: end)
        case .monthly:
            // Ayın ilk günü (00:00:00)
            let start = calendar.startOfMonth(for: anchorDate)
            // Ayın son günü - bir sonraki günün başlangıcı olarak ayarla
            let endOfMonth = calendar.date(byAdding: .month, value: 1, to: start) ?? start
            let end = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: endOfMonth)) ?? endOfMonth
            return DateRange(start: start, end: end)
        case .manualRange:
            guard let start = manualStart, let end = manualEnd else {
                // Fallback: bugünün tarihi
                let today = calendar.startOfDay(for: Date())
                let tomorrow = calendar.date(byAdding: .day, value: 1, to: today) ?? today
                return DateRange(start: today, end: tomorrow)
            }
            // Başlangıç gününün başlangıcı ve bitiş gününün sonu
            let startOfDay = calendar.startOfDay(for: start)
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: end)) ?? end
            return DateRange(start: startOfDay, end: endOfDay)
        }
    }
    
    static func rangeForMonth(year: Int, month: Int) -> DateRange {
        let calendar = Calendar.current
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = 1
        let start = calendar.date(from: components) ?? Date()
        // Ayın son günü - bir sonraki günün başlangıcı olarak ayarla
        let endOfMonth = calendar.date(byAdding: .month, value: 1, to: start) ?? Date()
        let end = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: endOfMonth)) ?? endOfMonth
        return DateRange(start: start, end: end)
    }
    
    static func monthName(for month: Int, locale: Locale? = nil) -> String {
        let formatter = DateFormatter()
        let appLocale = locale ?? (LocalizedString.isTurkish ? Locale(identifier: "tr_TR") : Locale(identifier: "en_US"))
        formatter.locale = appLocale
        formatter.dateFormat = "MMMM"
        var components = DateComponents()
        components.month = month
        components.day = 1
        if let date = Calendar.current.date(from: components) {
            return formatter.string(from: date)
        }
        return LocalizedString.isTurkish ? "Ay \(month)" : "Month \(month)"
    }
    
    static func startOfDay(for date: Date) -> Date {
        return Calendar.current.startOfDay(for: date)
    }
}

