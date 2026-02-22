//
//  ExpenseCategory.swift
//  SpendMate
//
//  Created by Berkay Dereci on 31.01.2026.
//

import Foundation
import SwiftUI

enum ExpenseCategory: String, CaseIterable, Codable, Identifiable {
    case food = "food"
    case transport = "transport"
    case shopping = "shopping"
    case bills = "bills"
    case health = "health"
    case entertainment = "entertainment"
    case investment = "investment"
    case subscription = "subscription"
    case other = "other"
    
    var id: String { rawValue }
    
    var displayName: String {
        let isTurkish = LocalizedString.isTurkish
        switch self {
        case .food: return isTurkish ? "Yemek" : "Food"
        case .transport: return isTurkish ? "Ulaşım" : "Transport"
        case .shopping: return isTurkish ? "Alışveriş" : "Shopping"
        case .bills: return isTurkish ? "Faturalar" : "Bills"
        case .health: return isTurkish ? "Sağlık" : "Health"
        case .entertainment: return isTurkish ? "Eğlence" : "Entertainment"
        case .investment: return isTurkish ? "Yatırım" : "Investment"
        case .subscription: return isTurkish ? "Abonelik" : "Subscription"
        case .other: return isTurkish ? "Diğer" : "Other"
        }
    }
    
    var icon: String {
        switch self {
        case .food: return "fork.knife"
        case .transport: return "car.fill"
        case .shopping: return "bag.fill"
        case .bills: return "doc.text.fill"
        case .health: return "cross.case.fill"
        case .entertainment: return "tv.fill"
        case .investment: return "chart.line.uptrend.xyaxis"
        case .subscription: return "creditcard.fill"
        case .other: return "ellipsis.circle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .food: return .orange
        case .transport: return .blue
        case .shopping: return .purple
        case .bills: return .red
        case .health: return .green
        case .entertainment: return .pink
        case .investment: return .indigo
        case .subscription: return .teal
        case .other: return .gray
        }
    }
}

