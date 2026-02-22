//
//  AddIncomeIntent.swift
//  SpendMate
//
//  Created by Berkay Dereci on 31.01.2026.
//

import AppIntents
import SwiftData
import Foundation
import WidgetKit

@available(iOS 16.0, *)
struct AddIncomeIntent: AppIntent {
    static var title: LocalizedStringResource = "Add Income"
    static var description = IntentDescription("Add a new income to SpendMate")
    static var openAppWhenRun: Bool = false
    
    @Parameter(title: "Amount")
    var amount: Double
    
    @Parameter(title: "Category")
    var category: IncomeCategoryEnum
    
    @Parameter(title: "Note")
    var note: String?
    
    static var parameterSummary: some ParameterSummary {
        Summary("Add \(\.$amount) income in \(\.$category) category")
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
        
        // IncomeCategory enum'dan IncomeCategory'a dönüştür
        let incomeCategory = category.toIncomeCategory()
        
        // Main actor'da expense oluştur ve kaydet
        try await MainActor.run {
            let context = container.mainContext
            
            // Yeni expense oluştur (type: income)
            let expense = Expense(
                amount: amount,
                category: .other, // Income için categoryRaw kullanılacak
                note: note ?? "",
                date: Date(),
                type: .income
            )
            expense.categoryRaw = incomeCategory.rawValue
            
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
                ? "\(formattedAmount) tutarında \(categoryName) kategorisinde gelir eklendi"
                : "Added \(formattedAmount) income in \(categoryName) category"
        }
        
        return .result(dialog: IntentDialog(stringLiteral: message))
    }
}

