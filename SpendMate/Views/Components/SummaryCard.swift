//
//  SummaryCard.swift
//  SpendMate
//
//  Created by Berkay Dereci on 31.01.2026.
//

import SwiftUI

struct SummaryCard: View {
    let income: Double
    let expense: Double
    let netBalance: Double
    let rangeLabel: String
    let expenseCount: Int
    let averagePerDay: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Net Bakiye (en üstte, büyük)
            Text(Currency.format(netBalance))
                .font(.system(size: 42, weight: .bold, design: .rounded))
                .foregroundColor(netBalance >= 0 ? .green : .red)
            
            // Gelir ve Gider (alt satırda, küçük, yan yana)
            HStack(spacing: 16) {
                Text("+\(Currency.format(income))")
                    .font(.subheadline)
                    .foregroundColor(.green)
                
                Text("-\(Currency.format(expense))")
                    .font(.subheadline)
                    .foregroundColor(.red)
            }
            
            // Tarih aralığı (sadece boş değilse göster)
            if !rangeLabel.isEmpty {
                Text(rangeLabel)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            // İstatistikler
            HStack(spacing: 16) {
                Label("\(expenseCount) \(LocalizedString.transaction)", systemImage: "list.bullet")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Label("\(LocalizedString.dailyAverage): \(Currency.format(averagePerDay))", systemImage: "calendar")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
        )
        .cardShadow()
    }
}

#Preview("Light Mode") {
    SummaryCard(
        income: 5000.00,
        expense: 3750.50,
        netBalance: 1249.50,
        rangeLabel: "1 Oca – 31 Oca",
        expenseCount: 15,
        averagePerDay: 41.68
    )
    .padding()
}

#Preview("Dark Mode") {
    SummaryCard(
        income: 5000.00,
        expense: 3750.50,
        netBalance: 1249.50,
        rangeLabel: "1 Oca – 31 Oca",
        expenseCount: 15,
        averagePerDay: 41.68
    )
    .padding()
    .preferredColorScheme(.dark)
}

