//
//  WidgetData.swift
//  SpendMate
//
//  Created by Berkay Dereci on 31.01.2026.
//

import Foundation
import SwiftUI

struct WidgetData {
    let income: Double
    let expense: Double
    let netBalance: Double
    let transactionCount: Int
    let recentTransactions: [TransactionItem]
    
    static var empty: WidgetData {
        WidgetData(
            income: 0,
            expense: 0,
            netBalance: 0,
            transactionCount: 0,
            recentTransactions: []
        )
    }
    
    init(income: Double, expense: Double, netBalance: Double, transactionCount: Int, recentTransactions: [TransactionItem]) {
        self.income = income
        self.expense = expense
        self.netBalance = netBalance
        self.transactionCount = transactionCount
        self.recentTransactions = recentTransactions
    }
    
    init(from expenses: [Expense]) {
        self.income = expenses
            .filter { $0.transactionType == .income }
            .reduce(0) { $0 + $1.amount }
        
        self.expense = expenses
            .filter { $0.transactionType == .expense }
            .reduce(0) { $0 + $1.amount }
        
        self.netBalance = income - expense
        self.transactionCount = expenses.count
        
        self.recentTransactions = expenses
            .prefix(5)
            .map { TransactionItem(from: $0) }
    }
}

struct TransactionItem: Identifiable {
    let id: String
    let amount: Double
    let category: String
    let icon: String
    let isIncome: Bool
    let date: Date
    
    init(from expense: Expense) {
        self.id = UUID().uuidString
        self.amount = expense.amount
        let categoryInfo = expense.displayCategory
        self.category = categoryInfo.name
        self.icon = categoryInfo.icon
        self.isIncome = expense.transactionType == .income
        self.date = expense.date
    }
}

