//
//  LargeWidgetView.swift
//  SpendMateWidget
//
//  Created by Berkay Dereci on 31.01.2026.
//

import SwiftUI
import WidgetKit
import Foundation

struct LargeWidgetView: View {
    let entry: SpendMateWidgetEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Net Balance (en üstte, büyük)
            Text(Currency.format(entry.data.netBalance))
                .font(.system(size: 42, weight: .bold, design: .rounded))
                .foregroundColor(entry.data.netBalance >= 0 ? .green : .red)
            
            // Gelir ve Gider (alt satırda, küçük, yan yana)
            HStack(spacing: 16) {
                Text("+\(Currency.format(entry.data.income))")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(.green)
                
                Text("-\(Currency.format(entry.data.expense))")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(.red)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .padding(20)
        .background(Color(.systemBackground))
    }
}

