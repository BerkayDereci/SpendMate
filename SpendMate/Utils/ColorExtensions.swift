//
//  ColorExtensions.swift
//  SpendMate
//
//  Created by Berkay Dereci on 31.01.2026.
//

import SwiftUI

struct CardShadowModifier: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    
    func body(content: Content) -> some View {
        content.shadow(
            color: colorScheme == .dark 
                ? Color.white.opacity(0.1) 
                : Color.black.opacity(0.05),
            radius: 10,
            x: 0,
            y: 4
        )
    }
}

extension View {
    func cardShadow() -> some View {
        modifier(CardShadowModifier())
    }
}

