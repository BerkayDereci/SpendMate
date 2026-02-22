//
//  AddExpenseIntent.swift
//  SpendMate
//
//  Created by Berkay Dereci on 31.01.2026.
//

import AppIntents
import SwiftData
import Foundation
import WidgetKit

@available(iOS 16.0, *)
struct AddExpenseIntent: AppIntent {
    static var title: LocalizedStringResource = "Add Expense"
    static var description = IntentDescription("Add a new expense to SpendMate")
    static var openAppWhenRun: Bool = false
    
    @Parameter(title: "Amount")
    var amount: Double
    
    @Parameter(title: "Category")
    var category: ExpenseCategoryEnum
    
    @Parameter(title: "Note")
    var note: String?
    
    static var parameterSummary: some ParameterSummary {
        Summary("Add \(\.$amount) expense in \(\.$category) category")
    }
    
    func perform() async throws -> some IntentResult {
        // App Group container kullanarak SwiftData'ya eriş
        let appGroupIdentifier = "group.com.spendmate.shared"
        let schema = Schema([Expense.self])
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            groupContainer: .identifier(appGroupIdentifier)
        )
        
        let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
        
        // ExpenseCategory enum'dan ExpenseCategory'a dönüştür
        let expenseCategory = category.toExpenseCategory()
        
        // Main actor'da expense oluştur ve kaydet
        try await MainActor.run {
            let context = container.mainContext
            
            // Yeni expense oluştur
            let expense = Expense(
                amount: amount,
                category: expenseCategory,
                note: note ?? "",
                date: Date(),
                type: .expense
            )
            
            context.insert(expense)
            try context.save()
        }
        
        // Widget'ı güncelle
        WidgetCenter.shared.reloadTimelines(ofKind: "SpendMateWidget")
        
        // Başarı mesajı (main actor'da)
        let message = await MainActor.run {
            let formattedAmount = Currency.format(amount)
            let categoryName = category.displayName
            let isTurkish = LocalizedString.isTurkish
            
            return isTurkish 
                ? "\(formattedAmount) tutarında \(categoryName) kategorisinde gider eklendi"
                : "Added \(formattedAmount) expense in \(categoryName) category"
        }
        
        return .result(dialog: IntentDialog(stringLiteral: message))
    }
}

