//
//  AddTransactionView.swift
//  SpendMate
//
//  Created by Berkay Dereci on 31.01.2026.
//

import SwiftUI
import SwiftData

struct AddTransactionView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab: TransactionType = .expense
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Tab Seçici
                Picker(LocalizedString.transactionType, selection: $selectedTab) {
                    ForEach(TransactionType.allCases, id: \.self) { type in
                        Text(type.displayName).tag(type)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                
                // İçerik
                if selectedTab == .expense {
                    AddEditExpenseView()
                } else {
                    AddIncomeView()
                }
            }
            .background(Color(.systemBackground))
            .navigationTitle(selectedTab == .expense ? LocalizedString.addExpense : LocalizedString.addIncome)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(LocalizedString.cancel) {
                        dismiss()
                    }
                }
            }
        }
        .background(Color(.systemBackground))
    }
}

#Preview {
    AddTransactionView()
        .modelContainer(for: Expense.self, inMemory: true)
}

