//
//  IncomeCategoryEnum.swift
//  SpendMate
//
//  Created by Berkay Dereci on 31.01.2026.
//

import Foundation
import AppIntents

@available(iOS 16.0, *)
enum IncomeCategoryEnum: String, AppEnum {
    case salary = "salary"
    case investment = "investment"
    case gift = "gift"
    case other = "other"
    
    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        TypeDisplayRepresentation(name: "Category")
    }
    
    static var caseDisplayRepresentations: [IncomeCategoryEnum: DisplayRepresentation] {
        [
            .salary: DisplayRepresentation(title: "Salary", subtitle: nil, image: .init(systemName: "banknote.fill")),
            .investment: DisplayRepresentation(title: "Investment", subtitle: nil, image: .init(systemName: "chart.line.uptrend.xyaxis")),
            .gift: DisplayRepresentation(title: "Gift", subtitle: nil, image: .init(systemName: "gift.fill")),
            .other: DisplayRepresentation(title: "Other", subtitle: nil, image: .init(systemName: "ellipsis.circle.fill"))
        ]
    }
    
    var displayName: String {
        let isTurkish = LocalizedString.isTurkish
        switch self {
        case .salary: return isTurkish ? "Maaş" : "Salary"
        case .investment: return isTurkish ? "Yatırım" : "Investment"
        case .gift: return isTurkish ? "Bağış" : "Gift"
        case .other: return isTurkish ? "Diğer" : "Other"
        }
    }
    
    func toIncomeCategory() -> IncomeCategory {
        switch self {
        case .salary: return .salary
        case .investment: return .investment
        case .gift: return .gift
        case .other: return .other
        }
    }
}

