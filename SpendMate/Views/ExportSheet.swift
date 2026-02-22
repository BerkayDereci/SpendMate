//
//  ExportSheet.swift
//  SpendMate
//
//  Created by Berkay Dereci on 31.01.2026.
//

import SwiftUI

struct ExportSheet: View {
    @Binding var isPresented: Bool
    @State private var selectedFormat: ExportFormat = .csv
    @State private var isExporting = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    let expenses: [Expense]
    let range: DateRange
    let total: Double
    let average: Double
    let categorySums: [(category: ExpenseCategory, amount: Double)]
    let onExport: (ExportFormat) -> Void
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Format Seçimi
                VStack(alignment: .leading, spacing: 12) {
                    Text(LocalizedString.selectFormat)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Picker("Format", selection: $selectedFormat) {
                        ForEach(ExportFormat.allCases, id: \.self) { format in
                            Text(format.rawValue).tag(format)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    Text(formatDescription)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top, 4)
                }
                .padding(.horizontal)
                
                // Özet Bilgiler
                VStack(alignment: .leading, spacing: 8) {
                    Text(LocalizedString.report)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    HStack {
                        Text(LocalizedString.transactionCount + ":")
                        Spacer()
                        Text("\(expenses.count)")
                            .fontWeight(.semibold)
                    }
                    
                    HStack {
                        Text(LocalizedString.total + ":")
                        Spacer()
                        Text(Currency.format(total))
                            .fontWeight(.semibold)
                    }
                    
                    HStack {
                        Text(LocalizedString.dateRangeLabel + ":")
                        Spacer()
                        Text(range.formattedRange)
                            .fontWeight(.semibold)
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.secondarySystemBackground))
                )
                .padding(.horizontal)
                
                Spacer()
                
                // Export Butonu
                Button {
                    export()
                } label: {
                    HStack {
                        if isExporting {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Image(systemName: "square.and.arrow.up")
                        }
                        Text(isExporting ? LocalizedString.preparing : LocalizedString.exportReport)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(isExporting ? Color.gray : Color.accentColor)
                    )
                    .foregroundColor(.white)
                    .fontWeight(.semibold)
                }
                .disabled(isExporting)
                .padding(.horizontal)
                .padding(.bottom)
            }
            .background(Color(.systemBackground))
            .navigationTitle(LocalizedString.export)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(LocalizedString.cancel) {
                        isPresented = false
                    }
                }
            }
            .alert(LocalizedString.error, isPresented: $showError) {
                Button(LocalizedString.ok, role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
        .background(Color(.systemBackground))
    }
    
    private var formatDescription: String {
        switch selectedFormat {
        case .csv:
            return LocalizedString.csvDescription
        case .pdf:
            return LocalizedString.pdfDescription
        }
    }
    
    private func export() {
        isExporting = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            onExport(selectedFormat)
            
            DispatchQueue.main.async {
                isExporting = false
                isPresented = false
            }
        }
    }
}

#Preview {
    ExportSheet(
        isPresented: .constant(true),
        expenses: [],
        range: DateRange(start: Date(), end: Date()),
        total: 0,
        average: 0,
        categorySums: [],
        onExport: { _ in }
    )
}

