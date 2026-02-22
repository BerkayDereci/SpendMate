//
//  ContentView.swift
//  SpendMate
//
//  Created by Berkay Dereci on 31.01.2026.
//

import SwiftUI
import SwiftData
import WidgetKit

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var allExpenses: [Expense]
    @ObservedObject private var settings = AppSettings.shared
    @State private var viewModel = ExpensesViewModel()
    @State private var selectedExpense: Expense?
    @State private var showDeleteConfirmation = false
    @State private var expenseToDelete: Expense?
    @State private var showExportSheet = false
    @State private var showShareSheet = false
    @State private var showSettings = false
    @State private var shareURL: URL?
    
    private var expenses: [Expense] {
        let range = viewModel.currentRange
        
        let filtered = allExpenses.filter { expense in
            expense.date >= range.start && expense.date < range.end
        }
        
        var result = filtered
        if let category = viewModel.selectedCategory {
            result = result.filter { $0.categoryRaw == category.rawValue }
        }
        
        return result.sorted { $0.date > $1.date }
    }
    
    private var total: Double {
        viewModel.totalAmount(for: expenses)
    }
    
    private var income: Double {
        viewModel.incomeAmount(for: expenses)
    }
    
    private var expense: Double {
        viewModel.expenseAmount(for: expenses)
    }
    
    private var netBalance: Double {
        viewModel.netBalance(for: expenses)
    }
    
    private var average: Double {
        viewModel.averagePerDay(for: expenses)
    }
    
    private var categorySums: [(category: ExpenseCategory, amount: Double)] {
        viewModel.categorySums(for: expenses)
    }
    
    private var grouped: [(date: Date, expenses: [Expense])] {
        viewModel.groupedByDay(expenses)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    
                    // Summary Card
                    SummaryCard(
                        income: income,
                        expense: expense,
                        netBalance: netBalance,
                        rangeLabel: viewModel.periodType == .manualRange ? viewModel.currentRange.formattedRange : "",
                        expenseCount: expenses.count,
                        averagePerDay: average
                    )
                    .padding(.horizontal)
                    
                    // Filter Card
                    FilterCard(
                        periodType: Binding(
                            get: { viewModel.periodType },
                            set: { viewModel.periodType = $0 }
                        ),
                        anchorDate: Binding(
                            get: { viewModel.anchorDate },
                            set: { viewModel.anchorDate = $0 }
                        ),
                        selectedCategory: Binding(
                            get: { viewModel.selectedCategory },
                            set: { viewModel.selectedCategory = $0 }
                        ),
                        manualStartDate: Binding(
                            get: { viewModel.manualStartDate },
                            set: { viewModel.manualStartDate = $0 }
                        ),
                        manualEndDate: Binding(
                            get: { viewModel.manualEndDate },
                            set: { viewModel.manualEndDate = $0 }
                        )
                    )
                    .padding(.horizontal)
                    
                    // Chart Card
                    CategoryChartCard(
                        categorySums: categorySums,
                        total: total
                    )
                    .padding(.horizontal)
                    
                    // Expenses List
                    if expenses.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "tray")
                                .font(.system(size: 64))
                                .foregroundColor(.secondary)
                            Text(LocalizedString.noTransactionsInPeriod)
                                .font(.headline)
                                .foregroundColor(.secondary)
                            Text(LocalizedString.pressPlusToAdd)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 60)
                    } else {
                        VStack(alignment: .leading, spacing: 16) {
                            ForEach(grouped, id: \.date) { group in
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text(viewModel.dayLabel(for: group.date))
                                            .font(.headline)
                                            .foregroundColor(.secondary)
                                        
                                        Spacer()
                                        
                                        HStack(spacing: 8) {
                                            // Gelir (yeşil, + ile)
                                            let dayIncome = viewModel.dayIncome(for: group.date, expenses: group.expenses)
                                            if dayIncome > 0 {
                                                Text("+\(Currency.format(dayIncome))")
                                                    .font(.caption)
                                                    .foregroundColor(.green)
                                            }
                                            
                                            // Gider (kırmızı, - ile)
                                            let dayExpense = viewModel.dayExpense(for: group.date, expenses: group.expenses)
                                            if dayExpense > 0 {
                                                Text("-\(Currency.format(dayExpense))")
                                                    .font(.caption)
                                                    .foregroundColor(.red)
                                            }
                                        }
                                    }
                                    .padding(.horizontal)
                                    
                                    ForEach(group.expenses) { expense in
                                        ExpenseRowCard(expense: expense)
                                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                                Button(role: .destructive) {
                                                    expenseToDelete = expense
                                                    showDeleteConfirmation = true
                                                } label: {
                                                    Label(LocalizedString.delete, systemImage: "trash")
                                                }
                                            }
                                            .onTapGesture {
                                                selectedExpense = expense
                                            }
                                            .padding(.horizontal)
                                    }
                                }
                            }
                        }
                        .padding(.bottom, 100)
                    }
                }
                .padding(.vertical)
            }
            .background(Color(.systemBackground))
            .safeAreaInset(edge: .bottom) {
                Color.clear.frame(height: 80)
            }
            .navigationTitle("SpendMate")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    HStack {
                        Button {
                            showSettings = true
                        } label: {
                            Image(systemName: "gearshape")
                                .font(.headline)
                        }
                        
                        if !expenses.isEmpty {
                            Button {
                                showExportSheet = true
                            } label: {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.headline)
                            }
                        }
                    }
                }
            }
            .sheet(item: $selectedExpense) { expense in
                NavigationStack {
                    AddEditExpenseView(expense: expense)
                }
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showExportSheet) {
                ExportSheet(
                    isPresented: $showExportSheet,
                    expenses: expenses,
                    range: viewModel.currentRange,
                    total: total,
                    average: average,
                    categorySums: categorySums,
                    onExport: { format in
                        handleExport(format: format)
                    }
                )
            }
            .sheet(isPresented: $showShareSheet) {
                if let url = shareURL {
                    ShareSheet(activityItems: [url])
                } else {
                    EmptyView()
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .alert(
                LocalizedString.deleteConfirmationTitle,
                isPresented: $showDeleteConfirmation,
                presenting: expenseToDelete
            ) { expense in
                Button(LocalizedString.yes, role: .destructive) {
                    deleteExpense(expense)
                }
                Button(LocalizedString.no, role: .cancel) { }
            } message: { _ in
                Text(LocalizedString.deleteConfirmationMessage)
            }
            .onAppear {
                handleNotificationTap()
            }
        }
        .background(Color(.systemBackground))
    }
    
    private func deleteExpense(_ expense: Expense) {
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
        
        modelContext.delete(expense)
        try? modelContext.save()
        // Widget'ı güncelle
        WidgetCenter.shared.reloadTimelines(ofKind: "SpendMateWidget")
    }
    
    private func handleExport(format: ExportFormat) {
        let url: URL?
        
        switch format {
        case .csv:
            url = ExportService.exportToCSV(
                expenses: expenses,
                range: viewModel.currentRange,
                total: total,
                average: average
            )
        case .pdf:
            url = ExportService.exportToPDF(
                expenses: expenses,
                range: viewModel.currentRange,
                total: total,
                average: average,
                categorySums: categorySums
            )
        }
        
        if let fileURL = url {
            shareURL = fileURL
            showShareSheet = true
        }
    }
    
    private func handleNotificationTap() {
        // Bildirim tıklama durumunu kontrol et
        if let userInfo = AppDelegate.notificationUserInfo,
           let type = userInfo["type"] as? String {
            
            if type == "monthly_summary" {
                // Bir önceki ayın bilgilerini hesapla
                let calendar = Calendar.current
                let now = Date()
                let previousMonth = calendar.date(byAdding: .month, value: -1, to: now) ?? now
                // Bir önceki ayın başlangıcını anchorDate olarak ayarla
                viewModel.anchorDate = calendar.startOfMonth(for: previousMonth)
                viewModel.periodType = .monthly
            } else if type == "weekly_summary" {
                // Bir önceki haftanın PDF raporunu oluştur ve paylaş
                let calendar = Calendar.current
                let now = Date()
                let previousWeekStart = calendar.date(byAdding: .weekOfYear, value: -1, to: calendar.startOfWeek(for: now)) ?? now
                let previousWeekEnd = calendar.date(byAdding: .day, value: 7, to: previousWeekStart) ?? now
                
                let previousWeekRange = DateRange(start: previousWeekStart, end: previousWeekEnd)
                
                // Önceki haftanın işlemlerini filtrele
                let previousWeekExpenses = allExpenses.filter { expense in
                    expense.date >= previousWeekRange.start && expense.date < previousWeekRange.end
                }.sorted { $0.date > $1.date }
                
                if !previousWeekExpenses.isEmpty {
                    let previousWeekTotal = viewModel.totalAmount(for: previousWeekExpenses)
                    let previousWeekAverage = viewModel.averagePerDay(for: previousWeekExpenses)
                    let previousWeekCategorySums = viewModel.categorySums(for: previousWeekExpenses)
                    
                    // PDF oluştur
                    if let pdfURL = ExportService.exportToPDF(
                        expenses: previousWeekExpenses,
                        range: previousWeekRange,
                        total: previousWeekTotal,
                        average: previousWeekAverage,
                        categorySums: previousWeekCategorySums
                    ) {
                        shareURL = pdfURL
                        showShareSheet = true
                    }
                }
            }
            
            // Notification userInfo'sunu temizle
            AppDelegate.notificationUserInfo = nil
        }
    }
}

// ShareSheet wrapper for UIActivityViewController
struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: nil
        )
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // No update needed
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Expense.self, inMemory: true)
}
