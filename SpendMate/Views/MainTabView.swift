//
//  MainTabView.swift
//  SpendMate
//
//  Created by Berkay Dereci on 31.01.2026.
//

import SwiftUI
import SwiftData

struct MainTabView: View {
    @State private var selectedTab = 0
    @State private var showAddTransaction = false
    @ObservedObject private var settings = AppSettings.shared
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            // Arka plan
            Color(.systemBackground)
                .ignoresSafeArea()
            
            // Ana içerik
            TabView(selection: $selectedTab) {
                ContentView()
                    .tag(0)
                    .background(Color(.systemBackground))
                
                AnalysisView()
                    .tag(1)
                    .background(Color(.systemBackground))
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .background(Color(.systemBackground))
            
            // Custom Tab Bar
            VStack {
                Spacer()
                HStack(spacing: 0) {
                    // Ana Sayfa butonu
                    Button {
                        selectedTab = 0
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: "wallet.bifold.fill")
                                .font(.system(size: 24))
                            Text(LocalizedString.home)
                                .font(.caption2)
                        }
                        .foregroundColor(selectedTab == 0 ? .blue : .secondary)
                        .frame(maxWidth: .infinity)
                    }
                    
                    // + Butonu (ortada, yuvarlak)
                    Button {
                        showAddTransaction = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 56, height: 56)
                            .background(
                                Circle()
                                    .fill(Color.blue)
                            )
                            .shadow(color: Color.blue.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    .offset(y: -8)
                    
                    // Analiz butonu
                    Button {
                        selectedTab = 1
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: selectedTab == 1 ? "chart.line.uptrend.xyaxis" : "chart.line.uptrend.xyaxis")
                                .font(.system(size: 24))
                            Text(LocalizedString.analysis)
                                .font(.caption2)
                        }
                        .foregroundColor(selectedTab == 1 ? .blue : .secondary)
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(
                    Rectangle()
                        .fill(Color(.systemBackground))
                        .shadow(
                            color: colorScheme == .dark 
                                ? Color.white.opacity(0.1) 
                                : Color.black.opacity(0.1),
                            radius: 10,
                            x: 0,
                            y: -2
                        )
                )
            }
        }
        .preferredColorScheme(settings.preferredColorScheme)
        .sheet(isPresented: $showAddTransaction) {
            AddTransactionView()
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
    }
}

#Preview("Light Mode") {
    MainTabView()
        .modelContainer(for: Expense.self, inMemory: true)
}

#Preview("Dark Mode") {
    MainTabView()
        .modelContainer(for: Expense.self, inMemory: true)
        .preferredColorScheme(.dark)
}

