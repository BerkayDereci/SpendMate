//
//  ExpenseRowCard.swift
//  SpendMate
//
//  Created by Berkay Dereci on 31.01.2026.
//

import SwiftUI
import SwiftData

struct ExpenseRowCard: View {
    let expense: Expense
    
    var body: some View {
        let categoryInfo = expense.displayCategory
        
        return HStack(spacing: 12) {
            // Category icon
            Image(systemName: categoryInfo.icon)
                .font(.title3)
                .foregroundColor(.white)
                .frame(width: 44, height: 44)
                .background(
                    Circle()
                        .fill(categoryInfo.color)
                )
            
            // Category name and note
            VStack(alignment: .leading, spacing: 4) {
                Text(categoryInfo.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                if !expense.note.isEmpty {
                    Text(expense.note)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                Text(expense.date, style: .time)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Amount
            Text(Currency.format(expense.amount))
                .font(.headline)
                .foregroundColor(.primary)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
        )
    }
}

#Preview("Light Mode") {
    ExpenseRowCard(
        expense: Expense(
            amount: 125.50,
            category: .food,
            note: "Öğle yemeği",
            date: Date()
        )
    )
    .padding()
}

#Preview("Dark Mode") {
    ExpenseRowCard(
        expense: Expense(
            amount: 125.50,
            category: .food,
            note: "Öğle yemeği",
            date: Date()
        )
    )
    .padding()
    .preferredColorScheme(.dark)
}

