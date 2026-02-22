//
//  ThemeToggleButton.swift
//  SpendMate
//
//  Created by Berkay Dereci on 31.01.2026.
//

import SwiftUI

struct ThemeToggleButton: View {
    @ObservedObject private var settings = AppSettings.shared
    
    var body: some View {
        Button {
            settings.toggleColorScheme()
        } label: {
            Image(systemName: settings.iconName)
                .font(.headline)
        }
    }
}

#Preview {
    ThemeToggleButton()
}

