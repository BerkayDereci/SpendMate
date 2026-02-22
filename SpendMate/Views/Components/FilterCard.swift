//
//  FilterCard.swift
//  SpendMate
//
//  Created by Berkay Dereci on 31.01.2026.
//

import SwiftUI

struct FilterCard: View {
    @Binding var periodType: PeriodType
    @Binding var anchorDate: Date
    @Binding var selectedCategory: ExpenseCategory?
    
    // Manuel tarih aralığı
    @Binding var manualStartDate: Date?
    @Binding var manualEndDate: Date?
    
    @ObservedObject private var settings = AppSettings.shared
    
    var body: some View {
        VStack(spacing: 16) {
            // Periyot Tipi
            Picker(LocalizedString.period, selection: $periodType) {
                Text(LocalizedString.weekly).tag(PeriodType.weekly)
                Text(LocalizedString.monthly).tag(PeriodType.monthly)
                Text(LocalizedString.dateRange).tag(PeriodType.manualRange)
            }
            .pickerStyle(.segmented)
            
            // Manuel Tarih Aralığı (sadece manualRange seçildiğinde)
            if periodType == .manualRange {
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(LocalizedString.startDate)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        DatePicker(LocalizedString.startDate, selection: Binding(
                            get: { manualStartDate ?? Date() },
                            set: { manualStartDate = $0 }
                        ), displayedComponents: .date)
                        .datePickerStyle(.compact)
                        .labelsHidden()
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text(LocalizedString.endDate)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        DatePicker(LocalizedString.endDate, selection: Binding(
                            get: { manualEndDate ?? Date() },
                            set: { manualEndDate = $0 }
                        ), displayedComponents: .date)
                        .datePickerStyle(.compact)
                        .labelsHidden()
                    }
                }
            }
            
            // Kategori Seçimi
            Menu {
                Button(LocalizedString.all) {
                    selectedCategory = nil
                }
                
                ForEach(ExpenseCategory.allCases) { category in
                    Button {
                        selectedCategory = category
                    } label: {
                        HStack {
                            Image(systemName: category.icon)
                            Text(category.displayName)
                            if selectedCategory == category {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                HStack {
                    Image(systemName: selectedCategory?.icon ?? "line.3.horizontal.decrease.circle")
                    Text(selectedCategory?.displayName ?? LocalizedString.allCategories)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .font(.caption)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.secondarySystemBackground))
                )
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
        )
        .cardShadow()
        .environment(\.locale, LocalizedString.isTurkish ? Locale(identifier: "tr_TR") : Locale(identifier: "en_US"))
    }
}

#Preview("Light Mode") {
    FilterCard(
        periodType: .constant(.monthly),
        anchorDate: .constant(Date()),
        selectedCategory: .constant(nil),
        manualStartDate: .constant(nil),
        manualEndDate: .constant(nil)
    )
    .padding()
}

#Preview("Dark Mode") {
    FilterCard(
        periodType: .constant(.monthly),
        anchorDate: .constant(Date()),
        selectedCategory: .constant(nil),
        manualStartDate: .constant(nil),
        manualEndDate: .constant(nil)
    )
    .padding()
    .preferredColorScheme(.dark)
}

