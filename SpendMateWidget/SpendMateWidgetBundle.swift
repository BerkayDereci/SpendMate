//
//  SpendMateWidgetBundle.swift
//  SpendMateWidget
//
//  Created by Berkay Dereci on 4.02.2026.
//

import WidgetKit
import SwiftUI

@main
struct SpendMateWidgetBundle: WidgetBundle {
    var body: some Widget {
        SpendMateWidget()
        SpendMateWidgetControl()
        SpendMateWidgetLiveActivity()
    }
}
