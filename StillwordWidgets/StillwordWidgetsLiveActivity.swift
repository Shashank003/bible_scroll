//
//  StillwordWidgetsLiveActivity.swift
//  StillwordWidgets
//
//  Created by Admin on 25/11/26.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct StillwordWidgetsAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct StillwordWidgetsLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: StillwordWidgetsAttributes.self) { context in
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

extension StillwordWidgetsAttributes {
    fileprivate static var preview: StillwordWidgetsAttributes {
        StillwordWidgetsAttributes(name: "World")
    }
}

extension StillwordWidgetsAttributes.ContentState {
    fileprivate static var smiley: StillwordWidgetsAttributes.ContentState {
        StillwordWidgetsAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: StillwordWidgetsAttributes.ContentState {
         StillwordWidgetsAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: StillwordWidgetsAttributes.preview) {
   StillwordWidgetsLiveActivity()
} contentStates: {
    StillwordWidgetsAttributes.ContentState.smiley
    StillwordWidgetsAttributes.ContentState.starEyes
}
