//
//  SpendMateTimelineProvider.swift
//  SpendMateWidget
//
//  Created by Berkay Dereci on 31.01.2026.
//

import WidgetKit
import SwiftUI

struct SpendMateTimelineProvider: TimelineProvider {
    typealias Entry = SpendMateWidgetEntry
    
    func placeholder(in context: Context) -> SpendMateWidgetEntry {
        SpendMateWidgetEntry(date: Date(), data: .empty)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (SpendMateWidgetEntry) -> Void) {
        Task { @MainActor in
            let entry = SpendMateWidgetEntry(
                date: Date(),
                data: WidgetDataService.shared.getTodayData()
            )
            completion(entry)
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SpendMateWidgetEntry>) -> Void) {
        Task { @MainActor in
            let currentDate = Date()
            let data = WidgetDataService.shared.getTodayData()
            let entry = SpendMateWidgetEntry(date: currentDate, data: data)
            
            // Bir sonraki günün başında güncelle
            let calendar = Calendar.current
            let nextDay = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
            let nextUpdate = calendar.startOfDay(for: nextDay)
            
            // Ayrıca her 6 saatte bir de güncelle (veri değişiklikleri için)
            let sixHoursLater = calendar.date(byAdding: .hour, value: 6, to: currentDate) ?? currentDate
            let updateDate = min(nextUpdate, sixHoursLater)
            
            let timeline = Timeline(entries: [entry], policy: .after(updateDate))
            completion(timeline)
        }
    }
}

struct SpendMateWidgetEntry: TimelineEntry {
    let date: Date
    let data: WidgetData
}

