//
//  AnalysisView.swift
//  SpendMate
//
//  Created by Berkay Dereci on 31.01.2026.
//

import SwiftUI
import SwiftData

struct AnalysisView: View {
    @Query private var allExpenses: [Expense]
    @ObservedObject private var settings = AppSettings.shared
    @State private var viewModel = AnalysisViewModel()
    @State private var showExpenseCategorySheet = false
    @State private var showIncomeCategorySheet = false
    
    private var chartData: [ChartDataPoint] {
        viewModel.getChartData(allExpenses)
    }
    
    private var incomeChartData: [IncomeChartDataPoint] {
        viewModel.getIncomeChartData(allExpenses)
    }
    
    private var trends: [(category: ExpenseCategory, trend: Trend)] {
        viewModel.getCategoryTrends(allExpenses)
    }
    
    private var incomeTrends: [(category: IncomeCategory, trend: Trend)] {
        viewModel.getIncomeCategoryTrends(allExpenses)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Transaction Type Seçici (en üstte)
                    Picker(LocalizedString.transactionType, selection: Binding(
                        get: { viewModel.selectedTransactionType },
                        set: { viewModel.selectedTransactionType = $0 }
                    )) {
                        Text(LocalizedString.expense).tag(TransactionType.expense)
                        Text(LocalizedString.income).tag(TransactionType.income)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    
                    // Filtreleme Card'ı (FilterCard benzeri)
                    VStack(spacing: 16) {
                        // Periyot Tipi (başlık yok)
                        Picker(LocalizedString.period, selection: Binding(
                            get: { viewModel.selectedPeriod },
                            set: { viewModel.selectedPeriod = $0 }
                        )) {
                            ForEach(AnalysisPeriod.allCases, id: \.self) { period in
                                Text(period.displayName).tag(period)
                            }
                        }
                        .pickerStyle(.segmented)
                        
                        // Manuel Tarih Aralığı (sadece dateRange seçildiğinde)
                        if viewModel.selectedPeriod == .dateRange {
                            HStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(LocalizedString.startDate)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    DatePicker(LocalizedString.startDate, selection: Binding(
                                        get: { viewModel.manualStartDate ?? Date() },
                                        set: { viewModel.manualStartDate = $0 }
                                    ), displayedComponents: .date)
                                    .datePickerStyle(.compact)
                                    .labelsHidden()
                                    .environment(\.locale, LocalizedString.isTurkish ? Locale(identifier: "tr_TR") : Locale(identifier: "en_US"))
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(LocalizedString.endDate)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    DatePicker(LocalizedString.endDate, selection: Binding(
                                        get: { viewModel.manualEndDate ?? Date() },
                                        set: { viewModel.manualEndDate = $0 }
                                    ), displayedComponents: .date)
                                    .datePickerStyle(.compact)
                                    .labelsHidden()
                                    .environment(\.locale, LocalizedString.isTurkish ? Locale(identifier: "tr_TR") : Locale(identifier: "en_US"))
                                }
                            }
                        }
                        
                        // Kategori Seçimi (Button ile sheet açılır)
                        if viewModel.selectedTransactionType == .expense {
                            Button {
                                showExpenseCategorySheet = true
                            } label: {
                                HStack {
                                    Image(systemName: viewModel.selectedExpenseCategories.count == ExpenseCategory.allCases.count ? "line.3.horizontal.decrease.circle" : (viewModel.selectedExpenseCategories.first?.icon ?? "line.3.horizontal.decrease.circle"))
                                    Text(categoryMenuLabel(expense: true))
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
                        } else {
                            Button {
                                showIncomeCategorySheet = true
                            } label: {
                                HStack {
                                    Image(systemName: viewModel.selectedIncomeCategories.count == IncomeCategory.allCases.count ? "line.3.horizontal.decrease.circle" : (viewModel.selectedIncomeCategories.first?.icon ?? "line.3.horizontal.decrease.circle"))
                                    Text(categoryMenuLabel(expense: false))
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
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.systemBackground))
                    )
                    .cardShadow()
                    .environment(\.locale, LocalizedString.isTurkish ? Locale(identifier: "tr_TR") : Locale(identifier: "en_US"))
                    .padding(.horizontal)
                    
                    // Grafik Kartı
                    if viewModel.selectedTransactionType == .expense {
                        AnalysisChartCard(
                            data: chartData,
                            selectedCategories: viewModel.selectedExpenseCategories,
                            period: viewModel.selectedPeriod
                        )
                        .padding(.horizontal)
                    } else {
                        IncomeAnalysisChartCard(
                            data: incomeChartData,
                            selectedCategories: viewModel.selectedIncomeCategories,
                            period: viewModel.selectedPeriod
                        )
                        .padding(.horizontal)
                    }
                    
                    // Trend Kartı
                    if viewModel.selectedTransactionType == .expense {
                        CategoryTrendCard(trends: trends)
                            .padding(.horizontal)
                    } else {
                        IncomeCategoryTrendCard(trends: incomeTrends)
                            .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .background(Color(.systemBackground))
            .safeAreaInset(edge: .bottom) {
                Color.clear.frame(height: 80)
            }
            .navigationTitle(LocalizedString.analysis)
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showExpenseCategorySheet) {
                CategorySelectionSheet(
                    isPresented: $showExpenseCategorySheet,
                    selectedCategories: $viewModel.selectedExpenseCategories,
                    categories: ExpenseCategory.allCases,
                    title: LocalizedString.categories
                )
            }
            .sheet(isPresented: $showIncomeCategorySheet) {
                IncomeCategorySelectionSheet(
                    isPresented: $showIncomeCategorySheet,
                    selectedCategories: $viewModel.selectedIncomeCategories,
                    categories: IncomeCategory.allCases,
                    title: LocalizedString.categories
                )
            }
        }
        .background(Color(.systemBackground))
    }
    
    private func categoryMenuLabel(expense: Bool) -> String {
        if expense {
            if viewModel.selectedExpenseCategories.count == ExpenseCategory.allCases.count {
                return LocalizedString.allCategories
            } else if viewModel.selectedExpenseCategories.count == 1 {
                return viewModel.selectedExpenseCategories.first?.displayName ?? LocalizedString.allCategories
            } else if viewModel.selectedExpenseCategories.isEmpty {
                return LocalizedString.allCategories
            } else {
                return "\(viewModel.selectedExpenseCategories.count) \(LocalizedString.category)"
            }
        } else {
            if viewModel.selectedIncomeCategories.count == IncomeCategory.allCases.count {
                return LocalizedString.allCategories
            } else if viewModel.selectedIncomeCategories.count == 1 {
                return viewModel.selectedIncomeCategories.first?.displayName ?? LocalizedString.allCategories
            } else if viewModel.selectedIncomeCategories.isEmpty {
                return LocalizedString.allCategories
            } else {
                return "\(viewModel.selectedIncomeCategories.count) \(LocalizedString.category)"
            }
        }
    }
}

#Preview("Light Mode") {
    AnalysisView()
        .modelContainer(for: Expense.self, inMemory: true)
}

#Preview("Dark Mode") {
    AnalysisView()
        .modelContainer(for: Expense.self, inMemory: true)
        .preferredColorScheme(.dark)
}

