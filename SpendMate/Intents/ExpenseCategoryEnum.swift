//
//  ExpenseCategoryEnum.swift
//  SpendMate
//
//  Created by Berkay Dereci on 31.01.2026.
//

import Foundation
import AppIntents

@available(iOS 16.0, *)
enum ExpenseCategoryEnum: String, AppEnum {
    case food = "food"
    case transport = "transport"
    case shopping = "shopping"
    case bills = "bills"
    case health = "health"
    case entertainment = "entertainment"
    case investment = "investment"
    case subscription = "subscription"
    case other = "other"
    
    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        TypeDisplayRepresentation(name: "Category")
    }
    
    static var caseDisplayRepresentations: [ExpenseCategoryEnum: DisplayRepresentation] {
        [
            .food: DisplayRepresentation(title: "Food", subtitle: nil, image: .init(systemName: "fork.knife")),
            .transport: DisplayRepresentation(title: "Transport", subtitle: nil, image: .init(systemName: "car.fill")),
            .shopping: DisplayRepresentation(title: "Shopping", subtitle: nil, image: .init(systemName: "bag.fill")),
            .bills: DisplayRepresentation(title: "Bills", subtitle: nil, image: .init(systemName: "doc.text.fill")),
            .health: DisplayRepresentation(title: "Health", subtitle: nil, image: .init(systemName: "cross.case.fill")),
            .entertainment: DisplayRepresentation(title: "Entertainment", subtitle: nil, image: .init(systemName: "tv.fill")),
            .investment: DisplayRepresentation(title: "Investment", subtitle: nil, image: .init(systemName: "chart.line.uptrend.xyaxis")),
            .subscription: DisplayRepresentation(title: "Subscription", subtitle: nil, image: .init(systemName: "creditcard.fill")),
            .other: DisplayRepresentation(title: "Other", subtitle: nil, image: .init(systemName: "ellipsis.circle.fill"))
        ]
    }
    
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
    
    func toExpenseCategory() -> ExpenseCategory {
        switch self {
        case .food: return .food
        case .transport: return .transport
        case .shopping: return .shopping
        case .bills: return .bills
        case .health: return .health
        case .entertainment: return .entertainment
        case .investment: return .investment
        case .subscription: return .subscription
        case .other: return .other
        }
    }
}

