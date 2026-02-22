//
//  CategoryTrendCard.swift
//  SpendMate
//
//  Created by Berkay Dereci on 31.01.2026.
//

import SwiftUI

struct CategoryTrendCard: View {
    let trends: [(category: ExpenseCategory, trend: Trend)]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(LocalizedString.categoryTrends)
                .font(.headline)
                .foregroundColor(.primary)
            
            if trends.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    Text(LocalizedString.noTrendData)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                VStack(spacing: 12) {
                    ForEach(trends, id: \.category.id) { item in
                        HStack(spacing: 12) {
                            // Kategori ikonu
                            Image(systemName: item.category.icon)
                                .font(.title3)
                                .foregroundColor(.white)
                                .frame(width: 40, height: 40)
                                .background(
                                    Circle()
                                        .fill(item.category.color)
                                )
                            
                            // Kategori ismi
                            VStack(alignment: .leading, spacing: 4) {
                                Text(item.category.displayName)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                // Trend göstergesi
                                HStack(spacing: 4) {
                                    Image(systemName: item.trend.isIncreasing ? "arrow.up.right" : "arrow.down.right")
                                        .font(.caption)
                                        .foregroundColor(item.trend.isIncreasing ? .green : .red)
                                    
                                    Text(String(format: "%.1f%%", item.trend.percentage))
                                        .font(.caption)
                                        .foregroundColor(item.trend.isIncreasing ? .green : .red)
                                    
                                    Text("(\(item.trend.isIncreasing ? "+" : "")\(Currency.format(item.trend.change)))")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            Spacer()
                        }
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.secondarySystemBackground))
                        )
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
    CategoryTrendCard(
        trends: [
            (ExpenseCategory.food, Trend(isIncreasing: true, percentage: 15.5, change: 150)),
            (ExpenseCategory.transport, Trend(isIncreasing: false, percentage: 8.3, change: -50))
        ]
    )
    .padding()
}

#Preview("Dark Mode") {
    CategoryTrendCard(
        trends: [
            (ExpenseCategory.food, Trend(isIncreasing: true, percentage: 15.5, change: 150)),
            (ExpenseCategory.transport, Trend(isIncreasing: false, percentage: 8.3, change: -50))
        ]
    )
    .padding()
    .preferredColorScheme(.dark)
}

