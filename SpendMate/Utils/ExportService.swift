//
//  ExportService.swift
//  SpendMate
//
//  Created by Berkay Dereci on 31.01.2026.
//

import Foundation
import UIKit

enum ExportFormat: String, CaseIterable {
    case csv = "CSV"
    case pdf = "PDF"
}

class ExportService {
    static func exportToCSV(
        expenses: [Expense],
        range: DateRange,
        total: Double,
        average: Double
    ) -> URL? {
        let header = "\(LocalizedString.dateColumn),\(LocalizedString.categoryColumn),\(LocalizedString.amountColumn),\(LocalizedString.noteColumn)\n"
        var csvContent = header
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = LocalizedString.isTurkish ? Locale(identifier: "tr_TR") : Locale(identifier: "en_US")
        dateFormatter.dateFormat = "dd.MM.yyyy HH:mm"
        
        for expense in expenses {
            let dateStr = dateFormatter.string(from: expense.date)
            let categoryStr = expense.category.displayName
            let amountStr = String(format: "%.2f", expense.amount)
            let noteStr = expense.note.replacingOccurrences(of: ",", with: ";")
            
            csvContent += "\(dateStr),\(categoryStr),\(amountStr),\(noteStr)\n"
        }
        
        csvContent += "---\n"
        csvContent += "\(LocalizedString.total): \(Currency.format(total))\n"
        csvContent += "\(LocalizedString.transactionCount): \(expenses.count)\n"
        csvContent += "\(LocalizedString.dailyAverage): \(Currency.format(average))\n"
        csvContent += "\(LocalizedString.dateRangeLabel): \(range.formattedRange)\n"
        
        // UTF-8 BOM ekle (Excel uyumluluğu için)
        let bom = "\u{FEFF}"
        let csvData = (bom + csvContent).data(using: .utf8)
        
        guard let data = csvData else { return nil }
        
        let fileName = generateFileName(extension: "csv")
        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        do {
            try data.write(to: fileURL)
            return fileURL
        } catch {
            print("CSV export error: \(error)")
            return nil
        }
    }
    
    static func exportToPDF(
        expenses: [Expense],
        range: DateRange,
        total: Double,
        average: Double,
        categorySums: [(category: ExpenseCategory, amount: Double)]
    ) -> URL? {
        let pageSize = CGSize(width: 595, height: 842) // A4
        let margin: CGFloat = 40
        let contentWidth = pageSize.width - (margin * 2)
        
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(origin: .zero, size: pageSize))
        
        let fileName = generateFileName(extension: "pdf")
        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        do {
            try renderer.writePDF(to: fileURL) { context in
                context.beginPage()
                
                var yPosition: CGFloat = margin
                
                // Başlık
                let titleAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.boldSystemFont(ofSize: 24),
                    .foregroundColor: UIColor.label
                ]
                let title = LocalizedString.reportTitle
                let titleSize = title.size(withAttributes: titleAttributes)
                title.draw(at: CGPoint(x: margin, y: yPosition), withAttributes: titleAttributes)
                yPosition += titleSize.height + 10
                
                // Tarih aralığı
                let rangeAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 14),
                    .foregroundColor: UIColor.secondaryLabel
                ]
                let rangeText = range.formattedRange
                let rangeSize = rangeText.size(withAttributes: rangeAttributes)
                rangeText.draw(at: CGPoint(x: margin, y: yPosition), withAttributes: rangeAttributes)
                yPosition += rangeSize.height + 20
                
                // Özet Bölümü
                yPosition = drawSection(
                    context: context,
                    title: LocalizedString.summary,
                    yPosition: yPosition,
                    margin: margin,
                    contentWidth: contentWidth
                )
                
                let summaryAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 12),
                    .foregroundColor: UIColor.label
                ]
                
                let totalText = "\(LocalizedString.total): \(Currency.format(total))"
                totalText.draw(at: CGPoint(x: margin + 10, y: yPosition), withAttributes: summaryAttributes)
                yPosition += 20
                
                let countText = "\(LocalizedString.transactionCount): \(expenses.count)"
                countText.draw(at: CGPoint(x: margin + 10, y: yPosition), withAttributes: summaryAttributes)
                yPosition += 20
                
                let avgText = "\(LocalizedString.dailyAverage): \(Currency.format(average))"
                avgText.draw(at: CGPoint(x: margin + 10, y: yPosition), withAttributes: summaryAttributes)
                yPosition += 30
                
                // Kategori Dağılımı
                if !categorySums.isEmpty {
                    yPosition = drawSection(
                        context: context,
                        title: LocalizedString.categoryDistribution,
                        yPosition: yPosition,
                        margin: margin,
                        contentWidth: contentWidth
                    )
                    
                    let tableHeaderAttributes: [NSAttributedString.Key: Any] = [
                        .font: UIFont.boldSystemFont(ofSize: 11),
                        .foregroundColor: UIColor.label
                    ]
                    
                    let categoryHeader = LocalizedString.categoryColumn
                    let amountHeader = LocalizedString.amountColumn
                    let percentHeader = LocalizedString.percentage
                    
                    categoryHeader.draw(at: CGPoint(x: margin + 10, y: yPosition), withAttributes: tableHeaderAttributes)
                    amountHeader.draw(at: CGPoint(x: margin + 200, y: yPosition), withAttributes: tableHeaderAttributes)
                    percentHeader.draw(at: CGPoint(x: margin + 350, y: yPosition), withAttributes: tableHeaderAttributes)
                    yPosition += 20
                    
                    for item in categorySums {
                        let percent = (item.amount / total) * 100
                        let categoryText = item.category.displayName
                        let amountText = Currency.format(item.amount)
                        let percentText = String(format: "%.1f%%", percent)
                        
                        categoryText.draw(at: CGPoint(x: margin + 10, y: yPosition), withAttributes: summaryAttributes)
                        amountText.draw(at: CGPoint(x: margin + 200, y: yPosition), withAttributes: summaryAttributes)
                        percentText.draw(at: CGPoint(x: margin + 350, y: yPosition), withAttributes: summaryAttributes)
                        yPosition += 18
                    }
                    
                    yPosition += 20
                }
                
                // İşlem Listesi
                yPosition = drawSection(
                    context: context,
                    title: LocalizedString.transactionList,
                    yPosition: yPosition,
                    margin: margin,
                    contentWidth: contentWidth
                )
                
                let dateFormatter = DateFormatter()
                dateFormatter.locale = LocalizedString.isTurkish ? Locale(identifier: "tr_TR") : Locale(identifier: "en_US")
                dateFormatter.dateFormat = "dd.MM.yyyy HH:mm"
                
                let listHeaderAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.boldSystemFont(ofSize: 11),
                    .foregroundColor: UIColor.label
                ]
                
                LocalizedString.dateColumn.draw(at: CGPoint(x: margin + 10, y: yPosition), withAttributes: listHeaderAttributes)
                LocalizedString.categoryColumn.draw(at: CGPoint(x: margin + 150, y: yPosition), withAttributes: listHeaderAttributes)
                LocalizedString.amountColumn.draw(at: CGPoint(x: margin + 280, y: yPosition), withAttributes: listHeaderAttributes)
                LocalizedString.noteColumn.draw(at: CGPoint(x: margin + 380, y: yPosition), withAttributes: listHeaderAttributes)
                yPosition += 20
                
                let calendar = Calendar.current
                var currentDay: Date?
                
                for expense in expenses {
                    let expenseDay = calendar.startOfDay(for: expense.date)
                    
                    // Yeni gün başladıysa gün başlığı ekle
                    if currentDay != expenseDay {
                        currentDay = expenseDay
                        let dayFormatter = DateFormatter()
                        dayFormatter.locale = LocalizedString.isTurkish ? Locale(identifier: "tr_TR") : Locale(identifier: "en_US")
                        let dayText: String
                        if calendar.isDateInToday(expenseDay) {
                            dayText = LocalizedString.today
                        } else if calendar.isDateInYesterday(expenseDay) {
                            dayText = LocalizedString.yesterday
                        } else {
                            dayFormatter.dateFormat = "d MMMM yyyy"
                            dayText = dayFormatter.string(from: expenseDay)
                        }
                        let dayAttributes: [NSAttributedString.Key: Any] = [
                            .font: UIFont.boldSystemFont(ofSize: 11),
                            .foregroundColor: UIColor.secondaryLabel
                        ]
                        dayText.draw(at: CGPoint(x: margin + 10, y: yPosition), withAttributes: dayAttributes)
                        yPosition += 18
                    }
                    
                    // Sayfa kontrolü
                    if yPosition > pageSize.height - margin - 50 {
                        context.beginPage()
                        yPosition = margin
                    }
                    
                    let dateStr = dateFormatter.string(from: expense.date)
                    let categoryStr = expense.category.displayName
                    let amountStr = Currency.format(expense.amount)
                    let noteStr = expense.note.isEmpty ? "-" : expense.note
                    
                    dateStr.draw(at: CGPoint(x: margin + 10, y: yPosition), withAttributes: summaryAttributes)
                    categoryStr.draw(at: CGPoint(x: margin + 150, y: yPosition), withAttributes: summaryAttributes)
                    amountStr.draw(at: CGPoint(x: margin + 280, y: yPosition), withAttributes: summaryAttributes)
                    
                    // Not çok uzunsa kısalt
                    let maxNoteWidth: CGFloat = 150
                    let noteSize = noteStr.size(withAttributes: summaryAttributes)
                    if noteSize.width > maxNoteWidth {
                        let truncatedNote = String(noteStr.prefix(20)) + "..."
                        truncatedNote.draw(at: CGPoint(x: margin + 380, y: yPosition), withAttributes: summaryAttributes)
                    } else {
                        noteStr.draw(at: CGPoint(x: margin + 380, y: yPosition), withAttributes: summaryAttributes)
                    }
                    
                    yPosition += 16
                }
            }
            
            return fileURL
        } catch {
            print("PDF export error: \(error)")
            return nil
        }
    }
    
    private static func drawSection(
        context: UIGraphicsPDFRendererContext,
        title: String,
        yPosition: CGFloat,
        margin: CGFloat,
        contentWidth: CGFloat
    ) -> CGFloat {
        let sectionAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 16),
            .foregroundColor: UIColor.label
        ]
        
        let titleSize = title.size(withAttributes: sectionAttributes)
        title.draw(at: CGPoint(x: margin, y: yPosition), withAttributes: sectionAttributes)
        
        // Alt çizgi
        let lineY = yPosition + titleSize.height + 5
        context.cgContext.move(to: CGPoint(x: margin, y: lineY))
        context.cgContext.addLine(to: CGPoint(x: margin + contentWidth, y: lineY))
        context.cgContext.setStrokeColor(UIColor.separator.cgColor)
        context.cgContext.setLineWidth(1)
        context.cgContext.strokePath()
        
        return lineY + 15
    }
    
    private static func generateFileName(extension ext: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd_HHmmss"
        let timestamp = dateFormatter.string(from: Date())
        return "SpendMate_\(timestamp).\(ext)"
    }
}

