//
//  AppShortcuts.swift
//  SpendMate
//
//  Created by Berkay Dereci on 31.01.2026.
//

import AppIntents

@available(iOS 16.0, *)
struct AppShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: AddExpenseIntent(),
            phrases: [
                "Add expense in \(.applicationName)",
                "Record expense in \(.applicationName)",
                "Log expense in \(.applicationName)"
            ],
            shortTitle: "Add Expense",
            systemImageName: "plus.circle"
        )
        
        AppShortcut(
            intent: AddIncomeIntent(),
            phrases: [
                "Add income in \(.applicationName)",
                "Record income in \(.applicationName)",
                "Log income in \(.applicationName)"
            ],
            shortTitle: "Add Income",
            systemImageName: "plus.circle.fill"
        )
        
        AppShortcut(
            intent: GetBalanceIntent(),
            phrases: [
                "What's my balance in \(.applicationName)",
                "Show balance in \(.applicationName)",
                "Get balance from \(.applicationName)"
            ],
            shortTitle: "Get Balance",
            systemImageName: "dollarsign.circle"
        )
    }
    
    static var shortcutTileColor: ShortcutTileColor = .blue
}

