//
//  AnalysisViewModel.swift
//  SpendMate
//
//  Created by Berkay Dereci on 31.01.2026.
//

import Foundation

enum AnalysisPeriod: String, CaseIterable {
    case weekly
    case monthly
    case dateRange
    
    var displayName: String {
        switch self {
        case .weekly:
            return LocalizedString.weekly
        case .monthly:
            return LocalizedString.monthly
        case .dateRange:
            return LocalizedString.dateRange
        }
    }
}

struct CategoryData {
    let category: ExpenseCategory
    let amount: Double
    let period: String  // Görüntüleme için label
    let periodKey: String  // Sıralama için key (örn: "2026-W05" veya "2026-01")
}

struct IncomeCategoryData {
    let category: IncomeCategory
    let amount: Double
    let period: String  // Görüntüleme için label
    let periodKey: String  // Sıralama için key (örn: "2026-W05" veya "2026-01")
}

struct Trend {
    let isIncreasing: Bool
    let percentage: Double
    let change: Double
}

struct ChartDataPoint: Identifiable {
    let id = UUID()
    let period: String  // Görüntüleme için label
    let periodKey: String  // Sıralama için key
    let category: ExpenseCategory
    let amount: Double
}

struct IncomeChartDataPoint: Identifiable {
    let id = UUID()
    let period: String  // Görüntüleme için label
    let periodKey: String  // Sıralama için key
    let category: IncomeCategory
    let amount: Double
}

@Observable
class AnalysisViewModel {
    var selectedPeriod: AnalysisPeriod = .weekly
    var selectedTransactionType: TransactionType = .expense // Default gider
    var selectedExpenseCategories: Set<ExpenseCategory> = Set(ExpenseCategory.allCases)
    var selectedIncomeCategories: Set<IncomeCategory> = Set(IncomeCategory.allCases)
    
    // Manuel tarih aralığı
    var manualStartDate: Date?
    var manualEndDate: Date?
    
    init() {
        setupDefaultDateRange()
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
    
    var selectedCategories: Set<ExpenseCategory> {
        get {
            selectedExpenseCategories
        }
        set {
            selectedExpenseCategories = newValue
        }
    }
    
    func groupedByPeriod(_ expenses: [Expense]) -> [(period: String, data: [CategoryData])] {
        // Sadece seçilen transactionType'a göre filtrele
        var filteredExpenses = expenses.filter { $0.transactionType == selectedTransactionType }
        let calendar = Calendar.current
        
        // Tarih aralığı filtresi
        if selectedPeriod == .dateRange, let startDate = manualStartDate, let endDate = manualEndDate {
            let startOfDay = calendar.startOfDay(for: startDate)
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: endDate)) ?? endDate
            filteredExpenses = filteredExpenses.filter { expense in
                expense.date >= startOfDay && expense.date < endOfDay
            }
            
            // Tarih aralığı için tek bir period oluştur
            let formatter = DateFormatter()
            formatter.locale = LocalizedString.isTurkish ? Locale(identifier: "tr_TR") : Locale(identifier: "en_US")
            formatter.dateFormat = "d MMM"
            let startStr = formatter.string(from: startDate)
            let endStr = formatter.string(from: endDate)
            let periodLabel = "\(startStr) – \(endStr)"
            let periodKey = "\(startOfDay.timeIntervalSince1970)"
            
            if selectedTransactionType == .expense {
                let categoryGrouped = Dictionary(grouping: filteredExpenses) { $0.category }
                let categoryData = ExpenseCategory.allCases.compactMap { category -> CategoryData? in
                    let amount = categoryGrouped[category]?.reduce(0) { $0 + $1.amount } ?? 0
                    guard amount > 0 else { return nil }
                    return CategoryData(category: category, amount: amount, period: periodLabel, periodKey: periodKey)
                }
                return [(period: periodKey, data: categoryData)]
            } else {
                let categoryGrouped = Dictionary(grouping: filteredExpenses) { $0.incomeCategory }
                let categoryData = IncomeCategory.allCases.compactMap { category -> IncomeCategoryData? in
                    let amount = categoryGrouped[category]?.reduce(0) { $0 + $1.amount } ?? 0
                    guard amount > 0 else { return nil }
                    return IncomeCategoryData(category: category, amount: amount, period: periodLabel, periodKey: periodKey)
                }
                let mappedData = categoryData.map { incomeData in
                    CategoryData(category: .other, amount: incomeData.amount, period: incomeData.period, periodKey: incomeData.periodKey)
                }
                return [(period: periodKey, data: mappedData)]
            }
        }
        
        if selectedPeriod == .weekly {
            // Haftalara göre grupla
            let grouped = Dictionary(grouping: filteredExpenses) { expense in
                let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: expense.date)
                let year = components.year ?? 0
                let week = components.weekOfYear ?? 0
                return "\(year)-W\(String(format: "%02d", week))"
            }
            
            return grouped.map { (weekKey, weekExpenses) in
                // Hafta etiketi oluştur (bir kez) - kısa format
                let weekStart = weekExpenses.first?.date ?? Date()
                let weekStartComponents = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: weekStart)
                let weekStartDate = calendar.date(from: weekStartComponents) ?? weekStart
                let weekEndDate = calendar.date(byAdding: .day, value: 6, to: weekStartDate) ?? weekStart
                
                let formatter = DateFormatter()
                formatter.locale = LocalizedString.isTurkish ? Locale(identifier: "tr_TR") : Locale(identifier: "en_US")
                formatter.dateFormat = "d MMM"
                // Daha kısa format: Sadece başlangıç tarihi
                let periodLabel = formatter.string(from: weekStartDate)
                
                if selectedTransactionType == .expense {
                    // ExpenseCategory için
                    let categoryGrouped = Dictionary(grouping: weekExpenses) { $0.category }
                    let categoryData = ExpenseCategory.allCases.compactMap { category -> CategoryData? in
                        let amount = categoryGrouped[category]?.reduce(0) { $0 + $1.amount } ?? 0
                        guard amount > 0 else { return nil }
                        return CategoryData(category: category, amount: amount, period: periodLabel, periodKey: weekKey)
                    }
                    return (period: weekKey, data: categoryData)
                } else {
                    // IncomeCategory için
                    let categoryGrouped = Dictionary(grouping: weekExpenses) { $0.incomeCategory }
                    let categoryData = IncomeCategory.allCases.compactMap { category -> IncomeCategoryData? in
                        let amount = categoryGrouped[category]?.reduce(0) { $0 + $1.amount } ?? 0
                        guard amount > 0 else { return nil }
                        return IncomeCategoryData(category: category, amount: amount, period: periodLabel, periodKey: weekKey)
                    }
                    // IncomeCategoryData'yı CategoryData'ya map et (geçici çözüm)
                    let mappedData = categoryData.map { incomeData in
                        // IncomeCategory'yi ExpenseCategory'ye map et (geçici)
                        // Bu geçici bir çözüm, daha sonra düzeltilecek
                        CategoryData(category: .other, amount: incomeData.amount, period: incomeData.period, periodKey: incomeData.periodKey)
                    }
                    return (period: weekKey, data: mappedData)
                }
            }
            .sorted { $0.period < $1.period }
        } else {
            // Aylara göre grupla
            let grouped = Dictionary(grouping: filteredExpenses) { expense in
                let components = calendar.dateComponents([.year, .month], from: expense.date)
                return "\(components.year ?? 0)-\(String(format: "%02d", components.month ?? 0))"
            }
            
            return grouped.map { (monthKey, monthExpenses) in
                // Ay etiketi oluştur
                let monthStart = monthExpenses.first?.date ?? Date()
                let monthComponents = calendar.dateComponents([.year, .month], from: monthStart)
                let month = monthComponents.month ?? 1
                let year = monthComponents.year ?? 2026
                let monthName = DateRanges.monthName(for: month)
                let periodLabel = "\(monthName) \(year)"
                
                if selectedTransactionType == .expense {
                    // ExpenseCategory için
                    let categoryGrouped = Dictionary(grouping: monthExpenses) { $0.category }
                    let categoryData = ExpenseCategory.allCases.compactMap { category -> CategoryData? in
                        let amount = categoryGrouped[category]?.reduce(0) { $0 + $1.amount } ?? 0
                        guard amount > 0 else { return nil }
                        return CategoryData(category: category, amount: amount, period: periodLabel, periodKey: monthKey)
                    }
                    return (period: monthKey, data: categoryData)
                } else {
                    // IncomeCategory için
                    let categoryGrouped = Dictionary(grouping: monthExpenses) { $0.incomeCategory }
                    let categoryData = IncomeCategory.allCases.compactMap { category -> IncomeCategoryData? in
                        let amount = categoryGrouped[category]?.reduce(0) { $0 + $1.amount } ?? 0
                        guard amount > 0 else { return nil }
                        return IncomeCategoryData(category: category, amount: amount, period: periodLabel, periodKey: monthKey)
                    }
                    // IncomeCategoryData'yı CategoryData'ya map et (geçici çözüm)
                    let mappedData = categoryData.map { incomeData in
                        CategoryData(category: .other, amount: incomeData.amount, period: incomeData.period, periodKey: incomeData.periodKey)
                    }
                    return (period: monthKey, data: mappedData)
                }
            }
            .sorted { $0.period < $1.period }
        }
    }
    
    func getChartData(_ expenses: [Expense]) -> [ChartDataPoint] {
        // Sadece seçilen transactionType'a göre filtrele
        let filteredExpenses = expenses.filter { $0.transactionType == selectedTransactionType }
        let grouped = groupedByPeriod(filteredExpenses)
        
        if selectedTransactionType == .expense {
            let chartData = grouped.flatMap { periodData in
                periodData.data.map { categoryData in
                    ChartDataPoint(
                        period: categoryData.period,
                        periodKey: categoryData.periodKey,
                        category: categoryData.category,
                        amount: categoryData.amount
                    )
                }
            }
            return chartData.sorted { $0.periodKey < $1.periodKey }
        } else {
            // IncomeCategory için - IncomeChartDataPoint oluştur
            // Ama ChartDataPoint ExpenseCategory bekliyor, bu yüzden geçici olarak .other kullan
            let chartData = grouped.flatMap { periodData in
                periodData.data.map { categoryData in
                    ChartDataPoint(
                        period: categoryData.period,
                        periodKey: categoryData.periodKey,
                        category: categoryData.category, // Geçici olarak .other, daha sonra düzeltilecek
                        amount: categoryData.amount
                    )
                }
            }
            return chartData.sorted { $0.periodKey < $1.periodKey }
        }
    }
    
    func getIncomeChartData(_ expenses: [Expense]) -> [IncomeChartDataPoint] {
        // IncomeCategory için ayrı fonksiyon
        var filteredExpenses = expenses.filter { $0.transactionType == .income }
        let calendar = Calendar.current
        
        // Tarih aralığı filtresi
        if selectedPeriod == .dateRange, let startDate = manualStartDate, let endDate = manualEndDate {
            let startOfDay = calendar.startOfDay(for: startDate)
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: endDate)) ?? endDate
            filteredExpenses = filteredExpenses.filter { expense in
                expense.date >= startOfDay && expense.date < endOfDay
            }
            
            // Tarih aralığı için tek bir period oluştur
            let formatter = DateFormatter()
            formatter.locale = LocalizedString.isTurkish ? Locale(identifier: "tr_TR") : Locale(identifier: "en_US")
            formatter.dateFormat = "d MMM"
            let startStr = formatter.string(from: startDate)
            let endStr = formatter.string(from: endDate)
            let periodLabel = "\(startStr) – \(endStr)"
            let periodKey = "\(startOfDay.timeIntervalSince1970)"
            
            let categoryGrouped = Dictionary(grouping: filteredExpenses) { $0.incomeCategory }
            let categoryData = IncomeCategory.allCases.compactMap { category -> IncomeCategoryData? in
                let amount = categoryGrouped[category]?.reduce(0) { $0 + $1.amount } ?? 0
                guard amount > 0 else { return nil }
                return IncomeCategoryData(category: category, amount: amount, period: periodLabel, periodKey: periodKey)
            }
            
            let chartData = categoryData.map { categoryData in
                IncomeChartDataPoint(
                    period: categoryData.period,
                    periodKey: categoryData.periodKey,
                    category: categoryData.category,
                    amount: categoryData.amount
                )
            }
            return chartData.sorted { $0.periodKey < $1.periodKey }
        }
        
        let grouped: [(periodKey: String, data: [IncomeCategoryData])]
        if selectedPeriod == .weekly {
            let weekGrouped = Dictionary(grouping: filteredExpenses) { expense in
                let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: expense.date)
                return "\(components.year ?? 0)-W\(String(format: "%02d", components.weekOfYear ?? 0))"
            }
            
            grouped = weekGrouped.map { (weekKey, weekExpenses) in
                let weekStart = weekExpenses.first?.date ?? Date()
                let weekStartComponents = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: weekStart)
                let weekStartDate = calendar.date(from: weekStartComponents) ?? weekStart
                
                let formatter = DateFormatter()
                formatter.locale = LocalizedString.isTurkish ? Locale(identifier: "tr_TR") : Locale(identifier: "en_US")
                formatter.dateFormat = "d MMM"
                let periodLabel = formatter.string(from: weekStartDate)
                
                let categoryGrouped = Dictionary(grouping: weekExpenses) { $0.incomeCategory }
                let categoryData = IncomeCategory.allCases.compactMap { category -> IncomeCategoryData? in
                    let amount = categoryGrouped[category]?.reduce(0) { $0 + $1.amount } ?? 0
                    guard amount > 0 else { return nil }
                    return IncomeCategoryData(category: category, amount: amount, period: periodLabel, periodKey: weekKey)
                }
                return (periodKey: weekKey, data: categoryData)
            }.sorted { $0.periodKey < $1.periodKey }
        } else {
            let monthGrouped = Dictionary(grouping: filteredExpenses) { expense in
                let components = calendar.dateComponents([.year, .month], from: expense.date)
                return "\(components.year ?? 0)-\(String(format: "%02d", components.month ?? 0))"
            }
            
            grouped = monthGrouped.map { (monthKey, monthExpenses) in
                let monthStart = monthExpenses.first?.date ?? Date()
                let monthComponents = calendar.dateComponents([.year, .month], from: monthStart)
                let month = monthComponents.month ?? 1
                let year = monthComponents.year ?? 2026
                let monthName = DateRanges.monthName(for: month)
                let periodLabel = "\(monthName) \(year)"
                
                let categoryGrouped = Dictionary(grouping: monthExpenses) { $0.incomeCategory }
                let categoryData = IncomeCategory.allCases.compactMap { category -> IncomeCategoryData? in
                    let amount = categoryGrouped[category]?.reduce(0) { $0 + $1.amount } ?? 0
                    guard amount > 0 else { return nil }
                    return IncomeCategoryData(category: category, amount: amount, period: periodLabel, periodKey: monthKey)
                }
                return (periodKey: monthKey, data: categoryData)
            }.sorted { $0.periodKey < $1.periodKey }
        }
        
        let chartData = grouped.flatMap { periodData in
            periodData.data.map { categoryData in
                IncomeChartDataPoint(
                    period: categoryData.period,
                    periodKey: categoryData.periodKey,
                    category: categoryData.category,
                    amount: categoryData.amount
                )
            }
        }
        return chartData.sorted { $0.periodKey < $1.periodKey }
    }
    
    func calculateTrend(for category: ExpenseCategory, expenses: [Expense]) -> Trend {
        // Sadece seçilen transactionType'a göre filtrele
        let filteredExpenses = expenses.filter { $0.transactionType == selectedTransactionType }
        let grouped = groupedByPeriod(filteredExpenses)
        let categoryData = grouped.flatMap { $0.data }.filter { $0.category == category }
        
        guard categoryData.count >= 2 else {
            return Trend(isIncreasing: false, percentage: 0, change: 0)
        }
        
        let sorted = categoryData.sorted { period1, period2 in
            // Period key'lerine göre sırala (year-month veya year-week formatı)
            period1.periodKey < period2.periodKey
        }
        
        guard let first = sorted.first, let last = sorted.last else {
            return Trend(isIncreasing: false, percentage: 0, change: 0)
        }
        
        let change = last.amount - first.amount
        let percentage = first.amount > 0 ? (change / first.amount) * 100 : (change > 0 ? 100 : 0)
        
        return Trend(
            isIncreasing: change > 0,
            percentage: abs(percentage),
            change: change
        )
    }
    
    func getCategoryTrends(_ expenses: [Expense]) -> [(category: ExpenseCategory, trend: Trend)] {
        // Sadece seçilen transactionType'a göre filtrele
        let filteredExpenses = expenses.filter { $0.transactionType == selectedTransactionType }
        return selectedExpenseCategories.map { category in
            (category: category, trend: calculateTrend(for: category, expenses: filteredExpenses))
        }
    }
    
    func calculateIncomeTrend(for category: IncomeCategory, expenses: [Expense]) -> Trend {
        let filteredExpenses = expenses.filter { $0.transactionType == .income }
        let calendar = Calendar.current
        
        let grouped: [(periodKey: String, data: [IncomeCategoryData])]
        if selectedPeriod == .weekly {
            let weekGrouped = Dictionary(grouping: filteredExpenses) { expense in
                let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: expense.date)
                return "\(components.year ?? 0)-W\(String(format: "%02d", components.weekOfYear ?? 0))"
            }
            
            grouped = weekGrouped.map { (weekKey, weekExpenses) in
                let weekStart = weekExpenses.first?.date ?? Date()
                let weekStartComponents = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: weekStart)
                let weekStartDate = calendar.date(from: weekStartComponents) ?? weekStart
                
                let formatter = DateFormatter()
                formatter.locale = LocalizedString.isTurkish ? Locale(identifier: "tr_TR") : Locale(identifier: "en_US")
                formatter.dateFormat = "d MMM"
                let periodLabel = formatter.string(from: weekStartDate)
                
                let categoryGrouped = Dictionary(grouping: weekExpenses) { $0.incomeCategory }
                let categoryData = IncomeCategory.allCases.compactMap { cat -> IncomeCategoryData? in
                    let amount = categoryGrouped[cat]?.reduce(0) { $0 + $1.amount } ?? 0
                    guard amount > 0 else { return nil }
                    return IncomeCategoryData(category: cat, amount: amount, period: periodLabel, periodKey: weekKey)
                }
                return (periodKey: weekKey, data: categoryData)
            }.sorted { $0.periodKey < $1.periodKey }
        } else {
            let monthGrouped = Dictionary(grouping: filteredExpenses) { expense in
                let components = calendar.dateComponents([.year, .month], from: expense.date)
                return "\(components.year ?? 0)-\(String(format: "%02d", components.month ?? 0))"
            }
            
            grouped = monthGrouped.map { (monthKey, monthExpenses) in
                let monthStart = monthExpenses.first?.date ?? Date()
                let monthComponents = calendar.dateComponents([.year, .month], from: monthStart)
                let month = monthComponents.month ?? 1
                let year = monthComponents.year ?? 2026
                let monthName = DateRanges.monthName(for: month)
                let periodLabel = "\(monthName) \(year)"
                
                let categoryGrouped = Dictionary(grouping: monthExpenses) { $0.incomeCategory }
                let categoryData = IncomeCategory.allCases.compactMap { cat -> IncomeCategoryData? in
                    let amount = categoryGrouped[cat]?.reduce(0) { $0 + $1.amount } ?? 0
                    guard amount > 0 else { return nil }
                    return IncomeCategoryData(category: cat, amount: amount, period: periodLabel, periodKey: monthKey)
                }
                return (periodKey: monthKey, data: categoryData)
            }.sorted { $0.periodKey < $1.periodKey }
        }
        
        let categoryData = grouped.flatMap { $0.data }.filter { $0.category == category }
        
        guard categoryData.count >= 2 else {
            return Trend(isIncreasing: false, percentage: 0, change: 0)
        }
        
        let sorted = categoryData.sorted { period1, period2 in
            period1.periodKey < period2.periodKey
        }
        
        guard let first = sorted.first, let last = sorted.last else {
            return Trend(isIncreasing: false, percentage: 0, change: 0)
        }
        
        let change = last.amount - first.amount
        let percentage = first.amount > 0 ? (change / first.amount) * 100 : (change > 0 ? 100 : 0)
        
        return Trend(
            isIncreasing: change > 0,
            percentage: abs(percentage),
            change: change
        )
    }
    
    func getIncomeCategoryTrends(_ expenses: [Expense]) -> [(category: IncomeCategory, trend: Trend)] {
        let filteredExpenses = expenses.filter { $0.transactionType == .income }
        return selectedIncomeCategories.map { category in
            (category: category, trend: calculateIncomeTrend(for: category, expenses: filteredExpenses))
        }
    }
}

