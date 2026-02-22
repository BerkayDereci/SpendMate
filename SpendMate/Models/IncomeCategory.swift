//
//  IncomeCategory.swift
//  SpendMate
//
//  Created by Berkay Dereci on 31.01.2026.
//

import Foundation
import SwiftUI

enum IncomeCategory: String, CaseIterable, Codable, Identifiable {
    case salary = "salary"
    case investment = "investment"
    case gift = "gift"
    case other = "other"
    
    var id: String { rawValue }
    
    var displayName: String {
        let isTurkish = LocalizedString.isTurkish
        switch self {
        case .salary: return isTurkish ? "Maaş" : "Salary"
        case .investment: return isTurkish ? "Yatırım" : "Investment"
        case .gift: return isTurkish ? "Bağış" : "Gift"
        case .other: return isTurkish ? "Diğer" : "Other"
        }
    }
    
    var icon: String {
        switch self {
        case .salary: return "banknote.fill"
        case .investment: return "chart.line.uptrend.xyaxis"
        case .gift: return "gift.fill"
        case .other: return "ellipsis.circle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .salary: return .green
        case .investment: return .blue
        case .gift: return .purple
        case .other: return .gray
        }
    }
}

