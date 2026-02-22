//
//  GetBalanceIntent.swift
//  SpendMate
//
//  Created by Berkay Dereci on 31.01.2026.
//

import AppIntents
import SwiftData
import Foundation

@available(iOS 16.0, *)
struct GetBalanceIntent: AppIntent {
    static var title: LocalizedStringResource = "Get Balance"
    static var description = IntentDescription("Get current balance from SpendMate")
    static var openAppWhenRun: Bool = false
    
    func perform() async throws -> some IntentResult & ReturnsValue<String> {
        // App Group container kullanarak SwiftData'ya eriş
        let appGroupIdentifier = "group.com.spendmate.shared"
        let schema = Schema([Expense.self])
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            groupContainer: .identifier(appGroupIdentifier)
        )
        
        let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
        
        // Main actor'da context'e eriş ve expense'leri fetch et
        let expenses = try await MainActor.run {
            let context = container.mainContext
            let descriptor = FetchDescriptor<Expense>()
            return try context.fetch(descriptor)
        }
        
        // Income ve Expense toplamlarını hesapla
        let income = expenses
            .filter { $0.transactionType == .income }
            .reduce(0.0) { $0 + $1.amount }
        
        let expense = expenses
            .filter { $0.transactionType == .expense }
            .reduce(0.0) { $0 + $1.amount }
        
        let balance = income - expense
        
        // Currency.format ve LocalizedString.isTurkish main actor'da, onları da sarmalayalım
        let (formattedBalance, message) = await MainActor.run {
            let formatted = Currency.format(balance)
            let isTurkish = LocalizedString.isTurkish
            let msg = isTurkish
                ? "Mevcut bakiyeniz \(formatted)"
                : "Your current balance is \(formatted)"
            return (formatted, msg)
        }
        
        return .result(value: formattedBalance, dialog: IntentDialog(stringLiteral: message))
    }
}

