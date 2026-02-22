//
//  WidgetDataService.swift
//  SpendMate
//
//  Created by Berkay Dereci on 31.01.2026.
//

import SwiftData
import Foundation

class WidgetDataService {
    static let shared = WidgetDataService()
    private let appGroupIdentifier = "group.com.spendmate.shared"
    
    func getModelContainer() -> ModelContainer? {
        let schema = Schema([Expense.self])
        
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            groupContainer: .identifier(appGroupIdentifier)
        )
        
        do {
            return try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
        } catch {
            print("Widget ModelContainer error: \(error)")
            return nil
        }
    }
    
    @MainActor
    func getTodayData() -> WidgetData {
        guard let container = getModelContainer() else {
            return WidgetData.empty
        }
        
        let context = container.mainContext
        let calendar = Calendar.current
        let today = Date()
        let startOfDay = calendar.startOfDay(for: today)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? today
        
        let descriptor = FetchDescriptor<Expense>(
            predicate: #Predicate<Expense> { expense in
                expense.date >= startOfDay && expense.date < endOfDay
            },
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        
        do {
            let expenses = try context.fetch(descriptor)
            return WidgetData(from: expenses)
        } catch {
            print("Widget data fetch error: \(error)")
            return WidgetData.empty
        }
    }
}

