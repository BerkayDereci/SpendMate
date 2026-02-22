//
//  SettingsView.swift
//  SpendMate
//
//  Created by Berkay Dereci on 31.01.2026.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject private var settings = AppSettings.shared
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                // Dil Seçimi
                Section(LocalizedString.language) {
                    Picker(LocalizedString.language, selection: $settings.language) {
                        Text(LocalizedString.turkish).tag("tr")
                        Text(LocalizedString.english).tag("en")
                    }
                }
                
                // Para Birimi Seçimi
                Section(LocalizedString.currency) {
                    Picker(LocalizedString.currency, selection: $settings.currency) {
                        Text(LocalizedString.turkishLira).tag("TRY")
                        Text(LocalizedString.usDollar).tag("USD")
                        Text(LocalizedString.euro).tag("EUR")
                    }
                }
                
                // Görünüm Seçimi
                Section(LocalizedString.appearance) {
                    Picker(LocalizedString.appearance, selection: $settings.colorScheme) {
                        Text(LocalizedString.lightMode).tag("light")
                        Text(LocalizedString.darkMode).tag("dark")
                        Text(LocalizedString.systemMode).tag("system")
                    }
                }
            }
            .navigationTitle(LocalizedString.settings)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(LocalizedString.ok) {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview("Light Mode") {
    SettingsView()
}

#Preview("Dark Mode") {
    SettingsView()
        .preferredColorScheme(.dark)
}

