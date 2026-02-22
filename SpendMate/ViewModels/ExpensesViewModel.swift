//
//  ExpensesViewModel.swift
//  SpendMate
//
//  Created by Berkay Dereci on 31.01.2026.
//

import Foundation

@Observable
class ExpensesViewModel {
    var periodType: PeriodType = .monthly {
        didSet {
            updateAnchorDateForPeriodType()
        }
    }
    var anchorDate: Date = Date()
    var selectedCategory: ExpenseCategory? = nil
    
    // Manuel tarih aralığı
    var manualStartDate: Date? = nil
    var manualEndDate: Date? = nil
    
    init() {
        updateAnchorDateForPeriodType()
        setupDefaultDateRange()
    }
    
    private func updateAnchorDateForPeriodType() {
        let calendar = Calendar.current
        let today = Date()
        
        switch periodType {
        case .weekly:
            // Bugünün haftasının başlangıcı
            anchorDate = calendar.startOfWeek(for: today)
        case .monthly:
            // Bugünün ayının başlangıcı
            anchorDate = calendar.startOfMonth(for: today)
        case .manualRange:
            // Manuel aralık için anchorDate değişmez
            break
        }
    }
    
    private func setupDefaultDateRange() {
        // Tarih aralığı için default değerleri ayarla (içinde bulunulan ayın ilk ve son günü)
        let calendar = Calendar.current
        let today = Date()
        let startOfMonth = calendar.startOfMonth(for: today)
        let endOfMonth = calendar.date(byAdding: .month, value: 1, to: startOfMonth) ?? today
        let lastDayOfMonth = calendar.date(byAdding: .day, value: -1, to: endOfMonth) ?? today
        
        manualStartDate = startOfMonth
        manualEndDate = lastDayOfMonth
    }
    
    var currentRange: DateRange {
        return DateRanges.range(
            for: periodType,
            anchorDate: anchorDate,
            manualStart: manualStartDate,
            manualEnd: manualEndDate
        )
    }
    
    func totalAmount(for expenses: [Expense]) -> Double {
        expenses.reduce(0) { $0 + $1.amount }
    }
    
    func averagePerDay(for expenses: [Expense]) -> Double {
        let range = currentRange
        let days = Calendar.current.dateComponents([.day], from: range.start, to: range.end).day ?? 1
        let total = totalAmount(for: expenses)
        return days > 0 ? total / Double(days) : 0
    }
    
    func categorySums(for expenses: [Expense]) -> [(category: ExpenseCategory, amount: Double)] {
        let grouped = Dictionary(grouping: expenses) { $0.category }
        return ExpenseCategory.allCases.map { category in
            let amount = grouped[category]?.reduce(0) { $0 + $1.amount } ?? 0
            return (category: category, amount: amount)
        }.filter { $0.amount > 0 }
    }
    
    func groupedByDay(_ expenses: [Expense]) -> [(date: Date, expenses: [Expense])] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: expenses) { expense in
            calendar.startOfDay(for: expense.date)
        }
        
        return grouped.map { (date: $0.key, expenses: $0.value) }
            .sorted { $0.date > $1.date }
    }
    
    func dayLabel(for date: Date) -> String {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.locale = LocalizedString.isTurkish ? Locale(identifier: "tr_TR") : Locale(identifier: "en_US")
        
        if calendar.isDateInToday(date) {
            return LocalizedString.today
        } else if calendar.isDateInYesterday(date) {
            return LocalizedString.yesterday
        } else {
            formatter.dateFormat = "d MMMM yyyy"
            return formatter.string(from: date)
        }
    }
    
    func dayTotal(for date: Date, expenses: [Expense]) -> Double {
        let calendar = Calendar.current
        let dayStart = calendar.startOfDay(for: date)
        let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart) ?? dayStart
        
        let dayExpenses = expenses.filter { expense in
            expense.date >= dayStart && expense.date < dayEnd
        }
        
        return totalAmount(for: dayExpenses)
    }
    
    func dayIncome(for date: Date, expenses: [Expense]) -> Double {
        let calendar = Calendar.current
        let dayStart = calendar.startOfDay(for: date)
        let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart) ?? dayStart
        
        let dayExpenses = expenses.filter { expense in
            expense.date >= dayStart && expense.date < dayEnd && expense.transactionType == .income
        }
        
        return incomeAmount(for: dayExpenses)
    }
    
    func dayExpense(for date: Date, expenses: [Expense]) -> Double {
        let calendar = Calendar.current
        let dayStart = calendar.startOfDay(for: date)
        let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart) ?? dayStart
        
        let dayExpenses = expenses.filter { expense in
            expense.date >= dayStart && expense.date < dayEnd && expense.transactionType == .expense
        }
        
        return expenseAmount(for: dayExpenses)
    }
    
    func incomeAmount(for expenses: [Expense]) -> Double {
        expenses.filter { $0.transactionType == .income }
            .reduce(0) { $0 + $1.amount }
    }
    
    func expenseAmount(for expenses: [Expense]) -> Double {
        expenses.filter { $0.transactionType == .expense }
            .reduce(0) { $0 + $1.amount }
    }
    
    func netBalance(for expenses: [Expense]) -> Double {
        incomeAmount(for: expenses) - expenseAmount(for: expenses)
    }
}

