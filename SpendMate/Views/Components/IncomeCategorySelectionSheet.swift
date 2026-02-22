//
//  IncomeCategorySelectionSheet.swift
//  SpendMate
//
//  Created by Berkay Dereci on 31.01.2026.
//

import SwiftUI

struct IncomeCategorySelectionSheet: View {
    @Binding var isPresented: Bool
    @Binding var selectedCategories: Set<IncomeCategory>
    let categories: [IncomeCategory]
    let title: String
    
    var body: some View {
        NavigationStack {
            List {
                // Tümü butonu
                Button {
                    let allSelected = categories.allSatisfy { selectedCategories.contains($0) }
                    if allSelected {
                        selectedCategories.removeAll()
                    } else {
                        selectedCategories = Set(categories)
                    }
                } label: {
                    HStack {
                        Image(systemName: categories.allSatisfy { selectedCategories.contains($0) } ? "checkmark.square.fill" : "square")
                            .foregroundColor(categories.allSatisfy { selectedCategories.contains($0) } ? .blue : .secondary)
                        Text(LocalizedString.all)
                    }
                }
                
                // Kategoriler
                ForEach(categories) { category in
                    Button {
                        if selectedCategories.contains(category) {
                            selectedCategories.remove(category)
                        } else {
                            selectedCategories.insert(category)
                        }
                    } label: {
                        HStack {
                            // Checkbox solda
                            Image(systemName: selectedCategories.contains(category) ? "checkmark.square.fill" : "square")
                                .foregroundColor(selectedCategories.contains(category) ? category.color : .secondary)
                            Image(systemName: category.icon)
                            Text(category.displayName)
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(LocalizedString.ok) {
                        isPresented = false
                    }
                }
            }
        }
    }
}

#Preview("Light Mode") {
    IncomeCategorySelectionSheet(
        isPresented: .constant(true),
        selectedCategories: .constant([.salary, .investment]),
        categories: IncomeCategory.allCases,
        title: LocalizedString.categories
    )
}

#Preview("Dark Mode") {
    IncomeCategorySelectionSheet(
        isPresented: .constant(true),
        selectedCategories: .constant([.salary, .investment]),
        categories: IncomeCategory.allCases,
        title: LocalizedString.categories
    )
    .preferredColorScheme(.dark)
}

