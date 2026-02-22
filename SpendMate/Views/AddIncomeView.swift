//
//  AddIncomeView.swift
//  SpendMate
//
//  Created by Berkay Dereci on 31.01.2026.
//

import SwiftUI
import SwiftData
import WidgetKit

struct AddIncomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var amountText: String = ""
    @State private var selectedCategory: IncomeCategory = .other
    @State private var note: String = ""
    @State private var date: Date = Date()
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    
    var expense: Expense?
    
    init(expense: Expense? = nil) {
        self.expense = expense
    }
    
    var body: some View {
        Form {
            Section(LocalizedString.amount) {
                TextField("0,00", text: $amountText)
                    .keyboardType(.decimalPad)
                    .onChange(of: amountText) { oldValue, newValue in
                        validateAmount()
                    }
                
                if showError {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
            
            Section(LocalizedString.category) {
                Picker(LocalizedString.category, selection: $selectedCategory) {
                    ForEach(IncomeCategory.allCases) { category in
                        HStack {
                            Image(systemName: category.icon)
                            Text(category.displayName)
                        }
                        .tag(category)
                    }
                }
            }
            
            Section(LocalizedString.date) {
                DatePicker(LocalizedString.date, selection: $date, displayedComponents: [.date, .hourAndMinute])
            }
            
            Section(LocalizedString.note) {
                TextField(LocalizedString.optionalNote, text: $note, axis: .vertical)
                    .lineLimit(3...6)
            }
        }
        .scrollContentBackground(.hidden)
        .background(Color(.systemBackground))
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button(LocalizedString.save) {
                    saveIncome()
                }
                .disabled(!isValid)
            }
        }
        .onAppear {
            if let expense = expense {
                amountText = String(format: "%.2f", expense.amount).replacingOccurrences(of: ".", with: ",")
                selectedCategory = expense.incomeCategory
                note = expense.note
                date = expense.date
            }
        }
        .environment(\.locale, LocalizedString.isTurkish ? Locale(identifier: "tr_TR") : Locale(identifier: "en_US"))
    }
    
    private var isValid: Bool {
        guard let amount = Currency.parseAmount(amountText) else { return false }
        return amount > 0
    }
    
    private func validateAmount() {
        if let amount = Currency.parseAmount(amountText) {
            if amount <= 0 {
                showError = true
                errorMessage = LocalizedString.amountMustBeGreaterThanZero
            } else {
                showError = false
            }
        } else if !amountText.isEmpty {
            showError = true
            errorMessage = LocalizedString.enterValidAmount
        } else {
            showError = false
        }
    }
    
    private func saveIncome() {
        guard let amount = Currency.parseAmount(amountText), amount > 0 else {
            return
        }
        
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
        
        if let expense = expense {
            // Update existing
            expense.amount = amount
            expense.incomeCategory = selectedCategory
            expense.note = note
            expense.date = date
            expense.transactionType = .income
        } else {
            // Create new - IncomeCategory için categoryRaw'ı direkt kullan
            let newExpense = Expense(
                amount: amount,
                category: .other, // Geçici, aşağıda override edilecek
                note: note,
                date: date,
                type: .income
            )
            newExpense.incomeCategory = selectedCategory
            modelContext.insert(newExpense)
        }
        
        do {
            try modelContext.save()
            // Widget'ı güncelle
            WidgetCenter.shared.reloadTimelines(ofKind: "SpendMateWidget")
            dismiss()
        } catch {
            errorMessage = LocalizedString.errorSaving
            showError = true
        }
    }
}

#Preview("Light Mode") {
    NavigationStack {
        AddIncomeView()
    }
    .modelContainer(for: Expense.self, inMemory: true)
}

#Preview("Dark Mode") {
    NavigationStack {
        AddIncomeView()
    }
    .modelContainer(for: Expense.self, inMemory: true)
    .preferredColorScheme(.dark)
}

