//
//  Expense.swift
//  SpendMate
//
//  Created by Berkay Dereci on 31.01.2026.
//

import Foundation
import SwiftData
import SwiftUI

@Model
final class Expense {
    var amount: Double
    var categoryRaw: String
    var note: String
    var date: Date
    var type: String? // "expense" veya "income" (optional for migration)
    
    var category: ExpenseCategory {
        get {
            ExpenseCategory(rawValue: categoryRaw) ?? .other
        }
        set {
            categoryRaw = newValue.rawValue
        }
    }
    
    var incomeCategory: IncomeCategory {
        get {
            IncomeCategory(rawValue: categoryRaw) ?? .other
        }
        set {
            categoryRaw = newValue.rawValue
        }
    }
    
    var displayCategory: (name: String, icon: String, color: Color) {
        if transactionType == .income {
            let cat = incomeCategory
            return (cat.displayName, cat.icon, cat.color)
        } else {
            let cat = category
            return (cat.displayName, cat.icon, cat.color)
        }
    }
    
    var transactionType: TransactionType {
        get {
            guard let type = type else { return .expense }
            return TransactionType(rawValue: type) ?? .expense
        }
        set {
            type = newValue.rawValue
        }
    }
    
    init(amount: Double, category: ExpenseCategory, note: String, date: Date, type: TransactionType = .expense) {
        self.amount = amount
        self.categoryRaw = category.rawValue
        self.note = note
        self.date = date
        self.type = type.rawValue
    }
}

