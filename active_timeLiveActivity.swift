//
//  active_timeLiveActivity.swift
//  active_time
//
//  Created by Анна on 9.12.25.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct active_timeAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct active_timeLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: active_timeAttributes.self) { context in
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

extension active_timeAttributes {
    fileprivate static var preview: active_timeAttributes {
        active_timeAttributes(name: "World")
    }
}

extension active_timeAttributes.ContentState {
    fileprivate static var smiley: active_timeAttributes.ContentState {
        active_timeAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: active_timeAttributes.ContentState {
         active_timeAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: active_timeAttributes.preview) {
   active_timeLiveActivity()
} contentStates: {
    active_timeAttributes.ContentState.smiley
    active_timeAttributes.ContentState.starEyes
}
