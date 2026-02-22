//
//  CategoryChartCard.swift
//  SpendMate
//
//  Created by Berkay Dereci on 31.01.2026.
//

import SwiftUI
import Charts

struct CategoryChartCard: View {
    let categorySums: [(category: ExpenseCategory, amount: Double)]
    let total: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(LocalizedString.categoryDistribution)
                .font(.headline)
                .foregroundColor(.primary)
            
            if categorySums.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "chart.pie")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    Text(LocalizedString.noTransactionsYet)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                Chart {
                    ForEach(categorySums, id: \.category.id) { item in
                        SectorMark(
                            angle: .value("Amount", item.amount),
                            innerRadius: .ratio(0.6),
                            angularInset: 2
                        )
                        .foregroundStyle(item.category.color)
                        .annotation(position: .overlay) {
                            if item.amount / total > 0.1 {
                                Text(String(format: "%.0f%%", (item.amount / total) * 100))
                                    .font(.caption2)
                                    .foregroundColor(.white)
                            }
                        }
                    }
                }
                .frame(height: 200)
                
                // Legend
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(categorySums, id: \.category.id) { item in
                        HStack {
                            Circle()
                                .fill(item.category.color)
                                .frame(width: 12, height: 12)
                            
                            Text(item.category.displayName)
                                .font(.caption)
                            
                            Spacer()
                            
                            Text(Currency.format(item.amount))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
        )
        .cardShadow()
    }
}

#Preview("Light Mode") {
    CategoryChartCard(
        categorySums: [
            (ExpenseCategory.food, 500),
            (ExpenseCategory.transport, 300),
            (ExpenseCategory.shopping, 200)
        ],
        total: 1000
    )
    .padding()
}

#Preview("Dark Mode") {
    CategoryChartCard(
        categorySums: [
            (ExpenseCategory.food, 500),
            (ExpenseCategory.transport, 300),
            (ExpenseCategory.shopping, 200)
        ],
        total: 1000
    )
    .padding()
    .preferredColorScheme(.dark)
}

