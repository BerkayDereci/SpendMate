//
//  TransactionType.swift
//  SpendMate
//
//  Created by Berkay Dereci on 31.01.2026.
//

import Foundation

enum TransactionType: String, Codable, CaseIterable {
    case expense = "expense"
    case income = "income"
    
    var displayName: String {
        let isTurkish = LocalizedString.isTurkish
        switch self {
        case .expense:
            return isTurkish ? "Gider" : "Expense"
        case .income:
            return isTurkish ? "Gelir" : "Income"
        }
    }
}

