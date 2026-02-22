//
//  SpendMateWidget.swift
//  SpendMateWidget
//
//  Created by Berkay Dereci on 31.01.2026.
//

import WidgetKit
import SwiftUI

@main
struct SpendMateWidget: Widget {
    let kind: String = "SpendMateWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: SpendMateTimelineProvider()) { entry in
            SpendMateWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("SpendMate")
        .description("Finansal özetinizi ana ekranda görüntüleyin.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

struct SpendMateWidgetEntryView: View {
    var entry: SpendMateWidgetEntry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        case .systemLarge:
            LargeWidgetView(entry: entry)
        default:
            SmallWidgetView(entry: entry)
        }
    }
}

#Preview(as: .systemSmall) {
    SpendMateWidget()
} timeline: {
    SpendMateWidgetEntry(date: Date(), data: .empty)
    SpendMateWidgetEntry(
        date: Date(),
        data: WidgetData(
            income: 5000,
            expense: 3000,
            netBalance: 2000,
            transactionCount: 15,
            recentTransactions: []
        )
    )
}

#Preview(as: .systemMedium) {
    SpendMateWidget()
} timeline: {
    SpendMateWidgetEntry(date: Date(), data: .empty)
}

#Preview(as: .systemLarge) {
    SpendMateWidget()
} timeline: {
    SpendMateWidgetEntry(date: Date(), data: .empty)
}

