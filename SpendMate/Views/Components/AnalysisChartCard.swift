//
//  AnalysisChartCard.swift
//  SpendMate
//
//  Created by Berkay Dereci on 31.01.2026.
//

import SwiftUI
import Charts

struct AnalysisChartCard: View {
    let data: [ChartDataPoint]
    let selectedCategories: Set<ExpenseCategory>
    let period: AnalysisPeriod
    
    private var hasDataForSelectedCategories: Bool {
        !selectedCategories.isEmpty && data.contains { selectedCategories.contains($0.category) }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(LocalizedString.transactionTrend)
                .font(.headline)
                .foregroundColor(.primary)
            
            if !hasDataForSelectedCategories {
                VStack(spacing: 12) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    Text(LocalizedString.noDataForSelectedCategories)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                Chart {
                    ForEach(Array(selectedCategories), id: \.id) { category in
                        let categoryData = data.filter { $0.category == category }
                            .sorted { period1, period2 in
                                period1.periodKey < period2.periodKey
                            }
                        
                        ForEach(categoryData) { point in
                            LineMark(
                                x: .value(LocalizedString.period, point.period),
                                y: .value(LocalizedString.amount, point.amount),
                                series: .value(LocalizedString.category, category.id)
                            )
                            .foregroundStyle(category.color)
                            .interpolationMethod(.catmullRom)
                            .symbol {
                                Circle()
                                    .fill(category.color)
                                    .frame(width: 6, height: 6)
                            }
                        }
                    }
                }
                .chartLegend(.hidden)
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisGridLine()
                        AxisValueLabel {
                            if let amount = value.as(Double.self) {
                                Text(formatAmount(amount))
                                    .font(.caption)
                            }
                        }
                    }
                }
                .chartXAxis {
                    AxisMarks { value in
                        AxisGridLine()
                        AxisValueLabel {
                            if let period = value.as(String.self) {
                                Text(period)
                                    .font(.caption2)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.7)
                            }
                        }
                    }
                }
                .frame(height: 350)
                
                // Legend (grid yapısında)
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 8) {
                    ForEach(Array(selectedCategories), id: \.id) { category in
                        HStack(spacing: 4) {
                            Circle()
                                .fill(category.color)
                                .frame(width: 8, height: 8)
                            Text(category.displayName)
                                .font(.caption)
                        }
                    }
                }
                .padding(.top, 8)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
        )
        .cardShadow()
    }
    
    private func formatAmount(_ amount: Double) -> String {
        if amount >= 1000 {
            return String(format: "%.0fK", amount / 1000)
        }
        return String(format: "%.0f", amount)
    }
}

#Preview("Light Mode") {
    AnalysisChartCard(
        data: [
            ChartDataPoint(period: "Ocak 2026", periodKey: "2026-01", category: .food, amount: 500),
            ChartDataPoint(period: "Şubat 2026", periodKey: "2026-02", category: .food, amount: 600),
            ChartDataPoint(period: "Ocak 2026", periodKey: "2026-01", category: .transport, amount: 300),
            ChartDataPoint(period: "Şubat 2026", periodKey: "2026-02", category: .transport, amount: 250)
        ],
        selectedCategories: [.food, .transport],
        period: .monthly
    )
    .padding()
}

#Preview("Dark Mode") {
    AnalysisChartCard(
        data: [
            ChartDataPoint(period: "Ocak 2026", periodKey: "2026-01", category: .food, amount: 500),
            ChartDataPoint(period: "Şubat 2026", periodKey: "2026-02", category: .food, amount: 600),
            ChartDataPoint(period: "Ocak 2026", periodKey: "2026-01", category: .transport, amount: 300),
            ChartDataPoint(period: "Şubat 2026", periodKey: "2026-02", category: .transport, amount: 250)
        ],
        selectedCategories: [.food, .transport],
        period: .monthly
    )
    .padding()
    .preferredColorScheme(.dark)
}

