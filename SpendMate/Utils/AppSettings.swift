//
//  AppSettings.swift
//  SpendMate
//
//  Created by Berkay Dereci on 31.01.2026.
//

import SwiftUI
import Combine

class AppSettings: ObservableObject {
    static let shared = AppSettings()
    
    private let colorSchemeKey = "colorScheme"
    private let languageKey = "appLanguage"
    private let currencyKey = "appCurrency"
    
    private var isInitializing = false
    
    @Published var colorScheme: String {
        didSet {
            if !isInitializing {
                UserDefaults.standard.set(colorScheme, forKey: colorSchemeKey)
            }
        }
    }
    
    @Published var language: String {
        didSet {
            if !isInitializing {
                UserDefaults.standard.set(language, forKey: languageKey)
            }
        }
    }
    
    @Published var currency: String {
        didSet {
            if !isInitializing {
                UserDefaults.standard.set(currency, forKey: currencyKey)
            }
        }
    }
    
    private init() {
        isInitializing = true
        
        // Tüm property'leri initialize et
        let savedColorScheme = UserDefaults.standard.string(forKey: colorSchemeKey) ?? "system"
        self.colorScheme = savedColorScheme
        
        // Dil için varsayılan: telefon dilini kontrol et, yoksa İngilizce
        let savedLanguage: String
        if let language = UserDefaults.standard.string(forKey: languageKey) {
            savedLanguage = language
        } else {
            let preferredLanguage = Bundle.main.preferredLocalizations.first ?? "en"
            savedLanguage = (preferredLanguage == "tr") ? "tr" : "en"
            UserDefaults.standard.set(savedLanguage, forKey: languageKey)
        }
        self.language = savedLanguage
        
        let savedCurrency = UserDefaults.standard.string(forKey: currencyKey) ?? "TRY"
        self.currency = savedCurrency
        
        isInitializing = false
    }
    
    var preferredColorScheme: ColorScheme? {
        switch colorScheme {
        case "dark":
            return .dark
        case "light":
            return .light
        default:
            return nil // system
        }
    }
    
    func toggleColorScheme() {
        switch colorScheme {
        case "system":
            colorScheme = "dark"
        case "dark":
            colorScheme = "light"
        case "light":
            colorScheme = "system"
        default:
            colorScheme = "system"
        }
    }
    
    var iconName: String {
        switch colorScheme {
        case "dark":
            return "moon.fill"
        case "light":
            return "sun.max.fill"
        default:
            return "circle.lefthalf.filled"
        }
    }
    
    func setLanguage(_ language: String) {
        self.language = language
    }
    
    func setCurrency(_ currency: String) {
        self.currency = currency
    }
    
    func setColorScheme(_ scheme: String) {
        self.colorScheme = scheme
    }
}

