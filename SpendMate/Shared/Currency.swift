//
//  Currency.swift
//  SpendMate (Shared)
//
//  Created by Berkay Dereci on 31.01.2026.
//

import Foundation

struct Currency {
    private static let currencyKey = "appCurrency"
    private static let languageKey = "appLanguage"
    
    static func format(_ amount: Double) -> String {
        // Widget extension için UserDefaults'tan direkt oku
        let currency = UserDefaults.standard.string(forKey: currencyKey) ?? "TRY"
        let language = UserDefaults.standard.string(forKey: languageKey) ?? "en"
        let isTurkish = language == "tr"
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        
        // Para birimine göre ayarla
        switch currency {
        case "USD":
            formatter.currencyCode = "USD"
            formatter.currencySymbol = "$"
            formatter.locale = Locale(identifier: "en_US")
        case "EUR":
            formatter.currencyCode = "EUR"
            formatter.currencySymbol = "€"
            formatter.locale = Locale(identifier: "en_US")
        default: // TRY
            formatter.currencyCode = "TRY"
            formatter.currencySymbol = "₺"
            formatter.locale = isTurkish ? Locale(identifier: "tr_TR") : Locale(identifier: "en_US")
        }
        
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        
        let formatted = formatter.string(from: NSNumber(value: amount))
        
        // Fallback
        if let formatted = formatted {
            return formatted
        } else {
            switch currency {
            case "USD":
                return "$0.00"
            case "EUR":
                return "€0.00"
            default:
                return isTurkish ? "₺0,00" : "₺0.00"
            }
        }
    }
    
    static func parseAmount(_ text: String) -> Double? {
        // Handle both comma and dot as decimal separator
        let cleaned = text.replacingOccurrences(of: ".", with: "")
            .replacingOccurrences(of: ",", with: ".")
            .trimmingCharacters(in: .whitespaces)
        
        return Double(cleaned)
    }
}

