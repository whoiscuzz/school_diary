import ActivityKit
import WidgetKit
import SwiftUI

struct SchoolWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: LessonAttributes.self) { context in
            // --- ЭКРАН БЛОКИРОВКИ (Lock Screen) ---
            VStack(alignment: .leading) {
                HStack {
                    Text(context.attributes.lessonName)
                        .font(.headline)
                        .foregroundColor(.white)
                    Spacer()
                    // АВТОМАТИЧЕСКИЙ ТАЙМЕР
                    Text(timerInterval: context.state.startTime...context.state.endTime, countsDown: true)
                        .font(.monospacedDigit(.body)())
                        .foregroundColor(.green)
                }
                
                // АВТОМАТИЧЕСКИЙ ПРОГРЕСС БАР
                ProgressView(timerInterval: context.state.startTime...context.state.endTime, countsDown: false)
                    .tint(.blue)
                    .padding(.top, 2)
                
                Text("Кабинет \(context.attributes.room)")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            .padding()
            .activityBackgroundTint(Color.black.opacity(0.8))
            .activitySystemActionForegroundColor(Color.white)

        } dynamicIsland: { context in
            DynamicIsland {
                // --- РАЗВЕРНУТЫЙ ОСТРОВ (Когда держишь палец) ---
                DynamicIslandExpandedRegion(.leading) {
                    VStack(alignment: .leading) {
                        Text("Урок")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text(context.attributes.lessonName)
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    .padding(.leading, 10)
                }
                
                DynamicIslandExpandedRegion(.trailing) {
                    // ТАЙМЕР В УГЛУ
                    Text(timerInterval: context.state.startTime...context.state.endTime, countsDown: true)
                        .font(.monospacedDigit(.title3)())
                        .foregroundColor(.green)
                        .padding(.trailing, 10)
                }
                
                DynamicIslandExpandedRegion(.bottom) {
                    // БОЛЬШОЙ БАР СНИЗУ
                    VStack {
                        ProgressView(timerInterval: context.state.startTime...context.state.endTime, countsDown: false)
                            .tint(.blue)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 10)
                }
                
            } compactLeading: {
                // --- СВЕРНУТЫЙ ОСТРОВ (Слева) ---
                Text(context.attributes.lessonName)
                    .font(.caption)
                    .bold()
                    .foregroundColor(.blue)
            } compactTrailing: {
                // --- СВЕРНУТЫЙ ОСТРОВ (Справа) ---
                // Круговой таймер
                ProgressView(timerInterval: context.state.startTime...context.state.endTime, countsDown: false) {
                    Text("")
                }
                .progressViewStyle(.circular)
                .tint(.green)
            } minimal: {
                Image(systemName: "clock")
                    .foregroundColor(.green)
            }
        }
    }
}
