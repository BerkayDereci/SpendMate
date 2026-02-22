//
//  SpendMateWidgetLiveActivity.swift
//  SpendMateWidget
//
//  Created by Berkay Dereci on 4.02.2026.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct SpendMateWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct SpendMateWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: SpendMateWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension SpendMateWidgetAttributes {
    fileprivate static var preview: SpendMateWidgetAttributes {
        SpendMateWidgetAttributes(name: "World")
    }
}

extension SpendMateWidgetAttributes.ContentState {
    fileprivate static var smiley: SpendMateWidgetAttributes.ContentState {
        SpendMateWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: SpendMateWidgetAttributes.ContentState {
         SpendMateWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: SpendMateWidgetAttributes.preview) {
   SpendMateWidgetLiveActivity()
} contentStates: {
    SpendMateWidgetAttributes.ContentState.smiley
    SpendMateWidgetAttributes.ContentState.starEyes
}
